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

sudo apt-get update && sudo apt-get install ltsp6-session-tuning
```

`Suites:` ist die Debian-Version, auf der Sie sind — `trixie` für Debian 13,
`bookworm` für Debian 12. In der älteren Einzeiler-Form lautet dieselbe Quelle:

```sh
echo 'deb [signed-by=/etc/apt/keyrings/ltsp6.asc arch=amd64] https://mabutz.github.io/ltsp6 trixie main' \
    | sudo tee /etc/apt/sources.list.d/ltsp6.list
```

Beide Schritte sind nötig. Ohne den Schlüssel verweigert `apt` das Archiv, und
der einzige Weg daran vorbei ist `[trusted=yes]` — das schaltet die Prüfung
für **jedes** Paket aus dieser Quelle ab. Auf Rechnern, die Software mit
root-Rechten installieren, ist das die falsche Stelle zum Sparen. Eine
korrekte Einrichtung holt `InRelease` und sagt zu Signaturen gar nichts:

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
| `trixie` | `ltsp6-session-tuning` | 1.0.0 |
| `bookworm` | `ltsp-client`, `ltsp-client-core` | 5.18.12-3 |

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

## Dokumentation

Die Dokumente selbst sind auf Englisch.

| Dokument | Inhalt |
|---|---|
| [`server/doc/HOWTO-lab-from-scratch`](server/doc/HOWTO-lab-from-scratch) | Das gesamte Labor in neun Schritten, mit den Abnahmetests und den Fallstricken — sortiert nach dem Symptom, mit dem sie sich zeigen |
| [`server/doc/RDP-loadbalancer-HA`](server/doc/RDP-loadbalancer-HA) | Lastverteilung und Hochverfügbarkeit des RDP-Eingangs, und warum eine Stick-Table statt eines Quell-IP-Hashes |
| [`server/doc/PXE-network-boot-test`](server/doc/PXE-network-boot-test) | Die Bootkette, von Anfang bis Ende gemessen |
| [`server/doc/NBD-toram`](server/doc/NBD-toram) | Das Client-Abbild aus dem RAM betreiben |

## Provisionierungswerkzeuge

Jedes Skript richtet eine Rolle ein und prüft sein eigenes Ergebnis. In dieser
Reihenfolge ausführen; das vollständige Rezept steht in
`HOWTO-lab-from-scratch`.

| Werkzeug | Rolle |
|---|---|
| `build-autoinstall-iso` | Unbeaufsichtigtes Installationsmedium aus netinst-Abbild plus Preseed |
| `provision-samba-ad-dc` | Der Samba-AD-Domaincontroller |
| `setup-ltsp-root` | Abbild-Server: NBD, TFTP, Proxy-DHCP, PXE |
| `setup-home-server` | Home-Verzeichnisse über NFS |
| `setup-ltsp-app` | Sitzungsserver und Domänenmitglied |
| `setup-lb-addressing` | Statische Adressierung für das keepalived-Paar |
| `build-apt-repo` | Das signierte apt-Archiv von oben |

## Lizenz

GPL-2+, wie das LTSP-Projekt, von dem dies abstammt. Siehe `COPYING`.
