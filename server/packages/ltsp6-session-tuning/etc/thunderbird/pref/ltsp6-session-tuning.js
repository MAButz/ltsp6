// Thunderbird on a session server - see README.Debian of ltsp6-session-tuning.
// Same reasoning as for Firefox: keep the disk cache in
// /var/cache/ltsp6-sessions/<uid> small. Defaults (pref), not locks.
pref("browser.cache.disk.smart_size.enabled", false);
pref("browser.cache.disk.capacity", 262144);
