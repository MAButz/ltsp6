// Firefox ESR on a session server - see README.Debian of ltsp6-session-tuning.
//
// The disk cache lives in $XDG_CACHE_HOME, which this package moves to
// /var/cache/ltsp6-sessions/<uid>. Firefox sizes it automatically up to 1 GB
// per profile; with many users on one host that adds up quickly. 256 MB is
// plenty for a working day. These are defaults (pref), not locks.
pref("browser.cache.disk.smart_size.enabled", false);
pref("browser.cache.disk.capacity", 262144);
