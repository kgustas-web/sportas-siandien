/* Network first, cache as fallback.
   Cache-first would mean every push is invisible until a version bump gets
   remembered — wrong trade for an app that is edited often and opened briefly.
   Online you always get the current build; offline you get the last good one. */
const CACHE = 'sc-v1';
const FILES = ['./', 'index.html', 'app.js', 'events.json',
               'manifest.webmanifest', 'icon-32.png', 'icon-48.png', 'icon-180.png', 'icon-192.png', 'icon-512.png'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE)
    .then(c => c.addAll(FILES)).catch(() => {})
    .then(() => self.skipWaiting()));
});

self.addEventListener('activate', e => {
  e.waitUntil(caches.keys()
    .then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});

self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  e.respondWith(
    fetch(e.request)
      .then(r => {
        const copy = r.clone();
        caches.open(CACHE).then(c => c.put(e.request, copy)).catch(() => {});
        return r;
      })
      .catch(() => caches.match(e.request).then(r => r || caches.match('index.html')))
  );
});
