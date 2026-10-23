const CACHE = 'rotaja-v3';

const PRECACHE = [
  '/',
  '/index.html',
  '/flutter_bootstrap.js',
  '/main.dart.js',
  '/flutter.js',
  '/manifest.json',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png'
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c => c.addAll(PRECACHE))
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  if (e.request.url.includes('api.mapbox.com')) return;

  e.respondWith(
    fetch(e.request).then(res => {
      const clone = res.clone();
      caches.open(CACHE).then(c => c.put(e.request, clone));
      return res;
    }).catch(() => {
      return caches.match(e.request).then(r => {
        if (r) return r;
        return caches.match('/index.html');
      });
    })
  );
});   