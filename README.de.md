**Deutsch** · [English](README.md)

# ltsp6

LTSP 5.18, nachgezogen auf Debian 13: Thin Clients booten über das Netz in
eine grafische Anmeldung, authentifizieren sich gegen eine Samba-AD-Domäne und
führen ihre Desktopsitzung auf einem von mehreren Anwendungsservern aus —
hinter einem lastverteilten, hochverfügbaren RDP-Eingang.

Die Bestandteile sind eine GTK3-Portierung von `ldm` mit xfreerdp-Backend
([MAButz/ldm](https://github.com/MAButz/ldm)), Provisionierungsskripte für
jede Rolle in `server/tools` und ein signiertes apt-Archiv für die Pakete
dieses Projekts.

## Einbinden auf Debian

Archiv hinzufügen, dann daraus installieren:

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

`Suites:` ist die Debian-Version, auf der Sie sind — `trixie` für Debian 13,
`bookworm` für Debian 12. Im älteren einzeiligen Format lautet dieselbe
Quelle:

```sh
echo 'deb [signed-by=/etc/apt/keyrings/ltsp6.asc arch=amd64] https://mabutz.github.io/ltsp6 trixie main' \
    | sudo tee /etc/apt/sources.list.d/ltsp6.list
```

Beide Schritte sind nötig. Ohne den Schlüssel weist `apt` das Archiv ab, und
der einzige Weg daran vorbei ist `[trusted=yes]` — das schaltet die Prüfung
für **jedes** Paket dieser Quelle ab. Auf Rechnern, die Software als root
installieren, ist das keine Abkürzung, die sich lohnt. Richtig eingerichtet
holt apt `InRelease` und sagt nichts über Signaturen:

```
Get:1 https://mabutz.github.io/ltsp6 trixie InRelease [1806 B]
Get:2 https://mabutz.github.io/ltsp6 trixie/main amd64 Packages [911 B]
```

Steht dort stattdessen `The repository ... is not signed`, fehlt die Zeile
`Signed-By` oder die Schlüsseldatei. Beantworten Sie das nicht mit
`trusted=yes`.

### Was im Archiv liegt

| Suite | Paket | Version |
|---|---|---|
| `trixie` | `ltsp-server` | 6.3.19-1 |
| `trixie` | `ltsp-client-core` | 6.3.19-1 |
| `trixie` | `ldm` | 3.4.5-1 |
| `trixie` | `ltsp6-session-tuning` | 1.0.0 |
| `bookworm` | `ltsp-client`, `ltsp-client-core` | 5.18.12-3 |

Diese Zahlen wandern. Was im Archiv wirklich liegt, steht in dessen eigener
`Packages`-Datei, und die Release-Seite führt jede Fassung mit ihren
Anmerkungen — widersprechen sich diese Tabelle und das Archiv, hat das
Archiv recht.

`ltsp-server` ist `Architecture: all` und läuft auch auf Debian 12. `ldm` und
`ltsp-client-core` sind amd64, gegen die glibc von Debian 13 gebaut, und
gehören ins Client-Abbild — und das ist ein Debian-13-Chroot. Die Suite ist
danach benannt, wo gebaut wird, nicht danach, wo installiert werden darf.

`ltsp6-session-tuning` richtet einen Rechner ein, der viele Desktopsitzungen
gleichzeitig trägt: Es verlegt den Cache jeder Sitzung vom Netz-Home auf
lokale Platte, schaltet das Compositing des Fenstermanagers ab (eine
xrdp-Sitzung hat keine GPU, das Compositing läuft also auf der CPU — einmal
pro Sitzung) und hebt die inotify-Grenzen an, die eine vollständige
Xfce-Sitzung freizügig verbraucht. Sein `README.Debian` hält außerdem fest,
was **nicht** gesetzt wurde, nachdem es unter Debian 13 als schon richtig
gemessen war — lesenswert, bevor weitere Optimierungen dazukommen.

Das Archiv liegt im Branch `main`, einem Orphan-Branch, der nur `dists/`,
`pool/` und den öffentlichen Schlüssel enthält und von GitHub Pages
ausgeliefert wird. `server/tools/build-apt-repo` erzeugt und signiert es neu.
Jede Fassung ist hier außerdem als Marke abgelegt und führt dieselben
`.deb`-Dateien als Anhang.

## Ein Client-Abbild bauen

Das Abbild baut `ltsp-build-client`, und das ist der vorgesehene Weg — alles
Weitere in dieser Ablage setzt ein Abbild voraus, das daraus stammt:

```sh
ltsp-build-client \
    --base /srv/ltsp --arch amd64 --dist trixie \
    --components main,non-free-firmware \
    --apt-keys /etc/apt/keyrings/ltsp6.asc \
    --extra-mirror "https://mabutz.github.io/ltsp6 trixie main" \
    --early-packages ca-certificates,initramfs-tools \
    --late-packages console-setup,freerdp3-x11,kbd,ldm,linux-image-amd64,\
locales,ltsp-client-core,nbd-client,numlockx,tftp-hpa,x11-xserver-utils,xinit,\
xserver-xorg-core,xserver-xorg-video-all \
    --purge-chroot --no-squashfs-image
```

`--base /srv/ltsp` lässt das laufende Abbild in `/opt/ltsp` unberührt;
`ltsp-update-image` setzt das Ergebnis danach ein. Die zweite Phase und die
Fallstricke stehen im `HOWTO-lab-from-scratch`, die Optionen in
`ltsp-build-client`(8).

## Dokumentation

Die Dokumente selbst sind auf Englisch.

| Dokument | Inhalt |
|---|---|
| [`server/doc/HOWTO-lab-from-scratch`](server/doc/HOWTO-lab-from-scratch) | Das gesamte Labor in neun Schritten, mit den Abnahmetests und den Fallstricken — sortiert nach dem Symptom, mit dem sie sich zeigen |
| [`server/doc/QuickInstall`](server/doc/QuickInstall) | Ein Server, ein Client, sonst nichts — der kurze Weg |
| [`server/doc/FAQ`](server/doc/FAQ) | Symptome mit bekannter Ursache, und wo die jeweils beschrieben ist |
| [`server/doc/RDP-loadbalancer-HA`](server/doc/RDP-loadbalancer-HA) | Lastverteilung und Hochverfügbarkeit des RDP-Eingangs, und warum eine Stick-Table statt eines Quell-IP-Hashes |
| [`server/doc/PXE-network-boot-test`](server/doc/PXE-network-boot-test) | Die Bootkette, von Anfang bis Ende gemessen |
| [`server/doc/NBD-toram`](server/doc/NBD-toram) | Das Client-Abbild aus dem RAM betreiben |

Die Handbuchseiten sind die Referenz, und `lts.conf`(5) ist die umfangreichste
davon — jede Einstellung, die der Client liest, was sie bewirkt und was sie
kostet:

| Seite | Gegenstand |
|---|---|
| `lts.conf`(5) | Jede Client-Einstellung: Sitzungs-Backend, Aussehen und Sprache des Greeters, Screens, SSH-Wirtsschlüssel, Grafik, Ton, Swap, Namen |
| `ltsp-build-client`(8) | Das Abbild bauen: Spiegel, Backports, Locales, Paketlisten |
| `ltsp-info`(1) | Was ein Server hat: Chroots, TFTP-Verzeichnisse, Abbilder — und beide Stellen, aus denen ein Client seine `lts.conf` liest |
| `ltsp-update-image`(8), `ltsp-update-kernels`(8) | Abbild und Kernel einsetzen |
| `ltsp-chroot`(8), `ltsp-config`(8), `ltsp-update-sshkeys`(8) | Am Chroot arbeiten, Dienstkonfiguration schreiben, Wirtsschlüssel |
| `build-apt-repo`(8) | Das signierte Archiv von oben |
| `setup-*`(8), `provision-samba-ad-dc`(8), `build-autoinstall-iso`(8) | Je eine Seite pro Provisionierungswerkzeug |

## Provisionierungswerkzeuge

Jedes Skript richtet eine Rolle ein und prüft sein eigenes Ergebnis. In dieser
Reihenfolge ausführen; das vollständige Rezept steht im
`HOWTO-lab-from-scratch`.

| Werkzeug | Rolle |
|---|---|
| `build-autoinstall-iso` | Unbeaufsichtigtes Installationsmedium aus einem netinst-Abbild plus Preseed |
| `provision-samba-ad-dc` | Der Samba-AD-Domänencontroller |
| `setup-ltsp-root` | Abbildserver: NBD, TFTP, Proxy-DHCP, PXE |
| `setup-home-server` | Heimatverzeichnisse über NFS |
| `setup-ltsp-app` | Sitzungsserver und Domänenmitglied |
| `setup-lb-addressing` | Feste Adressierung für das keepalived-Paar |
| `build-apt-repo` | Das signierte apt-Archiv von oben |

## Lizenz

GPL-2+, wie das LTSP-Projekt, von dem es abstammt. Siehe `COPYING`.
