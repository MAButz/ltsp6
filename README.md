[Deutsch](README.de.md) · **English**

# ltsp6

LTSP 5.18 brought forward to Debian 13: thin clients that network-boot into a
graphical login, authenticate against a Samba AD domain, and run their desktop
session on one of several application servers behind a load-balanced,
highly available RDP entry point.

The pieces are a GTK3 port of `ldm` with an xfreerdp backend
([MAButz/ldm](https://github.com/MAButz/ldm)), provisioning scripts for every
role in `server/tools`, and a signed apt archive for the packages this project
publishes.

## Adding the archive on Debian

Add the archive, then install from it:

```sh
sudo install -d -m 755 /etc/apt/keyrings
sudo curl -fsSL -o /etc/apt/keyrings/ltsp6.asc \
    https://mabutz.github.io/ltsp6/ltsp6-archive-keyring.asc

sudo tee /etc/apt/sources.list.d/ltsp6.sources >/dev/null <<'SRC'
Types: deb
URIs: https://mabutz.github.io/ltsp6
Suites: trixie
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/ltsp6.asc
SRC

sudo apt-get update && sudo apt-get install ltsp-server
```

`Suites:` is the Debian release you are on — `trixie` for Debian 13,
`bookworm` for Debian 12. On the older one-line format the same source reads:

```sh
echo 'deb [signed-by=/etc/apt/keyrings/ltsp6.asc arch=amd64] https://mabutz.github.io/ltsp6 trixie main' \
    | sudo tee /etc/apt/sources.list.d/ltsp6.list
```

Both steps are required. Without the key `apt` refuses the archive, and the
only way around that is `[trusted=yes]`, which switches off verification for
every package from the source — on machines that install software as root,
that is not a corner worth cutting. A correct setup fetches `InRelease` and
says nothing about signatures:

```
Get:1 https://mabutz.github.io/ltsp6 trixie InRelease [1806 B]
Get:2 https://mabutz.github.io/ltsp6 trixie/main amd64 Packages [911 B]
```

If you instead see `The repository ... is not signed`, the `Signed-By` line or
the keyring file is missing. Do not answer that with `trusted=yes`.

### What the archive holds

| Suite | Package | Version |
|---|---|---|
| `trixie` | `ltsp-server` | 6.3.15-1 |
| `trixie` | `ltsp-client-core` | 6.3.15-1 |
| `trixie` | `ldm` | 3.4.4-1 |
| `trixie` | `ltsp6-session-tuning` | 1.0.0 |
| `bookworm` | `ltsp-client`, `ltsp-client-core` | 5.18.12-3 |

`ltsp-server` is `Architecture: all` and runs on Debian 12 as well; `ldm` and
`ltsp-client-core` are amd64, built against the glibc of Debian 13, and belong
in the client image, which is a Debian 13 chroot. The suite is named after
where the packages are built, not after where they may be installed.

`ltsp6-session-tuning` configures a host that carries many desktop sessions at
once: it moves each session's cache off the network home directory, turns off
window manager compositing (an xrdp session has no GPU, so compositing runs on
the CPU once per session), and raises the inotify limits a full Xfce session
spends freely. Its `README.Debian` also records what was deliberately *not*
set after being measured as already correct on Debian 13 — worth reading
before adding more tuning.

The archive lives on the `main` branch, which is an orphan branch holding only
`dists/`, `pool/` and the public key, published by GitHub Pages.
`server/tools/build-apt-repo` regenerates and signs it. Every release is also
tagged here and carries the same `.deb` files as assets.

## Building a client image

The image is built by `ltsp-build-client`, and that is the supported way —
everything else in this repository assumes an image that came out of it:

```sh
ltsp-build-client \
    --base /srv/ltsp --arch amd64 --dist trixie \
    --components main,non-free-firmware \
    --apt-keys /etc/apt/keyrings/ltsp6.asc \
    --extra-mirror "https://mabutz.github.io/ltsp6 trixie main" \
    --early-packages ca-certificates,initramfs-tools \
    --late-packages console-setup,freerdp3-x11,kbd,ldm,linux-image-amd64,\
locales,ltsp-client-core,nbd-client,tftp-hpa,x11-xserver-utils,xinit,\
xserver-xorg-core,xserver-xorg-video-all \
    --purge-chroot --no-squashfs-image
```

Building into `--base /srv/ltsp` leaves the running image in `/opt/ltsp` alone;
`ltsp-update-image` then puts the result in place. `HOWTO-lab-from-scratch`
has the second phase and the traps, `ltsp-build-client`(8) the options.

## Documentation

| Document | Contents |
|---|---|
| [`server/doc/HOWTO-lab-from-scratch`](server/doc/HOWTO-lab-from-scratch) | The whole lab in nine steps, with the acceptance tests and the traps sorted by the symptom they present as |
| [`server/doc/QuickInstall`](server/doc/QuickInstall) | One server, one client, nothing else — the short path |
| [`server/doc/FAQ`](server/doc/FAQ) | Symptoms that have a known cause, and where each one is written up |
| [`server/doc/RDP-loadbalancer-HA`](server/doc/RDP-loadbalancer-HA) | Load balancing and high availability for the RDP entry point, and why a stick-table rather than a source hash |
| [`server/doc/PXE-network-boot-test`](server/doc/PXE-network-boot-test) | The boot chain, measured end to end |
| [`server/doc/NBD-toram`](server/doc/NBD-toram) | Running the client image from RAM |

The manual pages are the reference, and `lts.conf`(5) is the largest of them —
every directive the client reads, what it does, and what it costs:

| Page | Subject |
|---|---|
| `lts.conf`(5) | Every client setting: the session backend, the greeter's appearance and language, screens, SSH host keys, graphics, sound, swap, names |
| `ltsp-build-client`(8) | Building the image: mirrors, backports, locales, package lists |
| `ltsp-info`(1) | What a server has: chroots, TFTP directories, images, and both places a client reads `lts.conf` from |
| `ltsp-update-image`(8), `ltsp-update-kernels`(8) | Putting an image and its kernels in place |
| `ltsp-chroot`(8), `ltsp-config`(8), `ltsp-update-sshkeys`(8) | Working on a chroot, writing service configuration, host keys |
| `build-apt-repo`(8) | The signed archive above |
| `setup-*`(8), `provision-samba-ad-dc`(8), `build-autoinstall-iso`(8) | One page per provisioning tool |

## Provisioning tools

Each script sets up one role and verifies its own result. Run them in this
order; `HOWTO-lab-from-scratch` has the full recipe.

| Tool | Role |
|---|---|
| `build-autoinstall-iso` | Unattended install media from a netinst image plus a preseed |
| `provision-samba-ad-dc` | The Samba AD domain controller |
| `setup-ltsp-root` | Image server: NBD, TFTP, proxy DHCP, PXE |
| `setup-home-server` | Home directories over NFS |
| `setup-ltsp-app` | Session server and domain member |
| `setup-lb-addressing` | Static addressing for the keepalived pair |
| `build-apt-repo` | The signed apt archive above |

## Licence

GPL-2+, as the LTSP project it derives from. See `COPYING`.
