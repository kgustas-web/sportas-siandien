/* Network first, cache as fallback.

   The first worker shipped here was cache-first, which turned out to be a
   trap with no exit: it served a stale index.html AND a stale app.js, so
   any self-updating code added to the page could never run. The browser
   re-checks this file on navigation whatever the cache says, so the escape
   hatch has to live here — on activate, drop every old cache and reload
   whatever is open. */
const CACHE = 'sc-v3';
const FILES = ['./', 'index.html', 'app.js', 'events.json',
               'manifest.webmanifest', 'icon-32.png', 'icon-48.png',
               'icon-180.png', 'icon-192.png', 'icon-512.png'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE)
    .then(c => c.addAll(FILES)).catch(() => {})
    .then(() => self.skipWaiting()));
});

self.addEventListener('activate', e => {
  e.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)));
    await self.clients.claim();
    // Anything open is showing the previous build. Send it round again.
    const clients = await self.clients.matchAll({type: 'window'});
    for (const c of clients) {
      try { await c.navigate(c.url); } catch {}
    }
  })());
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
