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

## Einbinden auf Debian

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

sudo apt-get update && sudo apt-get install ltsp6-session-tuning
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
| `trixie` | `ltsp6-session-tuning` | 1.0.0 |
| `bookworm` | `ltsp-client`, `ltsp-client-core` | 5.18.12-3 |

`ltsp6-session-tuning` configures a host that carries many desktop sessions at
once: it moves each session's cache off the network home directory, turns off
window manager compositing (an xrdp session has no GPU, so compositing runs on
the CPU once per session), and raises the inotify limits a full Xfce session
spends freely. Its `README.Debian` also records what was deliberately *not*
set after being measured as already correct on Debian 13 — worth reading
before adding more tuning.

The archive lives on the `main` branch, which is an orphan branch holding only
`dists/`, `pool/` and the public key, published by GitHub Pages.
`server/tools/build-apt-repo` regenerates and signs it.

## Documentation

| Document | Contents |
|---|---|
| [`server/doc/HOWTO-lab-from-scratch`](server/doc/HOWTO-lab-from-scratch) | The whole lab in nine steps, with the acceptance tests and the traps sorted by the symptom they present as |
| [`server/doc/RDP-loadbalancer-HA`](server/doc/RDP-loadbalancer-HA) | Load balancing and high availability for the RDP entry point, and why a stick-table rather than a source hash |
| [`server/doc/PXE-network-boot-test`](server/doc/PXE-network-boot-test) | The boot chain, measured end to end |
| [`server/doc/NBD-toram`](server/doc/NBD-toram) | Running the client image from RAM |

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
