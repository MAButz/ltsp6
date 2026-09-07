# ltsp6 apt archive

A signed Debian archive, served over HTTPS by GitHub Pages from this branch:

```
https://mabutz.github.io/ltsp6
```

This branch carries no source code — it is an orphan branch holding only the
archive (`dists/`, `pool/`, the public key). The tooling that generates it
lives on the source branch, in `server/tools/build-apt-repo`.

## Using it on Debian

Install the archive key, then add the source. Both steps are needed: without
the key `apt` refuses the archive, and the only way around that is
`[trusted=yes]`, which switches off verification for **every** package from
this source. On machines that install software as root, that is not a corner
worth cutting.

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

sudo apt-get update
```

`Suites:` is the Debian release you are on — `trixie` for Debian 13,
`bookworm` for Debian 12.

If you prefer the older one-line format, this is the same thing:

```sh
echo 'deb [signed-by=/etc/apt/keyrings/ltsp6.asc arch=amd64] https://mabutz.github.io/ltsp6 trixie main' \
    | sudo tee /etc/apt/sources.list.d/ltsp6.list
```

Then install as usual:

```sh
sudo apt-get install ltsp6-session-tuning
```

### Checking that verification is really on

A correct setup fetches `InRelease` and says nothing about signatures:

```
Get:1 https://mabutz.github.io/ltsp6 trixie InRelease [1806 B]
Get:2 https://mabutz.github.io/ltsp6 trixie/main amd64 Packages [911 B]
```

If you see `The repository ... is not signed`, the `Signed-By` line or the
keyring file is missing. Do not answer that with `trusted=yes`.

## What is in here

| Suite | Package | Version |
|---|---|---|
| `trixie` | `ltsp6-session-tuning` | 1.0.0 |
| `bookworm` | `ltsp-client`, `ltsp-client-core` | 5.18.12-3 |

## The signing key

```
rsa4096  4FF1B90C 4FCC0560 15000513 0766F23F 20EE3FC4
LTSP6 Repository Signing Key (apt archive on GitHub Pages) <ma@butz.online>
expires 2029-09-06
```

Published here as `ltsp6-archive-keyring.asc` (armoured) and
`ltsp6-archive-keyring.gpg` (binary); `apt` reads either. The **private** half
is not in this repository and must never be committed — a signing key that has
ever been pushed has to be replaced, not deleted in a follow-up commit.

The key expires. When it does, clients report the archive as unsigned. Extend
the expiry (`gpg --quick-set-expire`) and re-run the build script so every
suite is signed again, then publish the refreshed public key.

## Publishing a new package

`db/` and `incoming/` are deliberately not tracked: reprepro's database is
local state, rebuilt from `conf/` and `pool/`, and committing a Berkeley DB
adds a binary blob on every publish for no gain.

```sh
# on a machine with reprepro, gpg and the private key available
git clone -b main https://github.com/MAButz/ltsp6.git ltsp6-apt
server/tools/build-apt-repo ltsp6-apt trixie /path/to/some-package_1.0_all.deb
cd ltsp6-apt && git add -A && git commit -m "publish some-package 1.0" && git push
```

The script writes `conf/distributions` with `SignWith`, includes the package,
re-exports and signs every suite, and verifies its own output before finishing.

## Limits worth knowing

GitHub Pages publishes at most 1 GB per site with a soft 100 GB/month of
bandwidth, and recommends keeping the source repository under 1 GB. That is
generous for configuration packages and wrong for large payloads: **every
`.deb` committed here stays in the git history forever**, so each rebuild of a
big package adds another full copy. For anything sizeable — a client image,
for instance — publish it as a GitHub Release asset instead and keep this
archive for the small packages.
