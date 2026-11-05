/* Défi Quiz — service worker : l'appli s'ouvre et le solo fonctionne sans Internet.
   - Page (index.html) : réseau d'abord (pour recevoir les mises à jour), cache si hors ligne.
   - Bibliothèques, polices, icônes : cache d'abord.
   - Appels à Supabase : jamais mis en cache.                                   */
const CACHE = "defiquiz-v16";
const SHELL = ["./", "./index.html", "./manifest.webmanifest", "./icon-192.png", "./icon-512.png", "./icon-maskable-192.png", "./icon-maskable-512.png", "./apple-touch-icon.png", "./legal.html",
               "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE).then(c => Promise.allSettled(SHELL.map(u => c.add(u)))).then(() => self.skipWaiting()));
});
self.addEventListener("activate", e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});
self.addEventListener("fetch", e => {
  const req = e.request;
  if(req.method !== "GET") return;
  const url = new URL(req.url);
  if(url.hostname.endsWith("supabase.co") || url.protocol.startsWith("ws")) return;

  if(req.mode === "navigate"){
    e.respondWith((async () => {
      try {
        const ctrl = new AbortController(); const t = setTimeout(() => ctrl.abort(), 5000);
        const res = await fetch(req, { signal: ctrl.signal }); clearTimeout(t);
        if(res.ok){ const c = await caches.open(CACHE); c.put("./index.html", res.clone()); }
        return res;
      } catch(err){
        return (await caches.match("./index.html")) || (await caches.match("./")) || Response.error();
      }
    })());
    return;
  }
  e.respondWith((async () => {
    const hit = await caches.match(req);
    if(hit) return hit;
    try {
      const res = await fetch(req);
      if(res.ok || res.type === "opaque"){ const c = await caches.open(CACHE); c.put(req, res.clone()); }
      return res;
    } catch(err){ return Response.error(); }
  })());
});

/* Notifications push : duels, messages, demandes d'ami, invitations */
self.addEventListener("push", e => {
  let d = {};
  try { d = e.data ? e.data.json() : {}; } catch(err){ d = { body: e.data && e.data.text() }; }
  e.waitUntil((async () => {
    // si l'appli est déjà ouverte et visible, l'alerte s'affiche dans l'appli : pas de doublon
    const wins = await self.clients.matchAll({ type: "window", includeUncontrolled: true });
    if(wins.some(w => w.visibilityState === "visible")) return;
    await self.registration.showNotification(d.title || "Défi Quiz", {
      body: d.body || "", icon: "./icon-192.png", badge: "./icon-192.png", tag: d.tag || "defiquiz", renotify: true
    });
  })());
});
self.addEventListener("notificationclick", e => {
  e.notification.close();
  const go = (e.notification.tag || "").startsWith("go:") ? e.notification.tag : "";
  e.waitUntil((async () => {
    const wins = await self.clients.matchAll({ type: "window", includeUncontrolled: true });
    if(wins.length){ await wins[0].focus(); if(go) wins[0].postMessage({ go }); return; }
    await self.clients.openWindow(go ? "./?go=" + encodeURIComponent(go) : "./");
  })());
});
