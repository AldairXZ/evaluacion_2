const CACHE_NAME = 'indiehub-tv-v2'; // Aumentamos la versión para forzar la actualización

// Archivos estáticos verificados para el modo offline (Cache First)
const STATIC_ASSETS = [
    './',
    './index.html',
    './css/styles.css',
    './js/app.js',
    './js/tv-navigation.js',
    './manifest.json'
];

// Instalación: Precargar los recursos estáticos
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            console.log('SW: Pre-cacheando estáticos (v2)');
            return cache.addAll(STATIC_ASSETS);
        })
    );
    self.skipWaiting();
});

// Activación: Limpiar cachés antiguos si cambiamos la versión
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((cacheNames) => {
            return Promise.all(
                cacheNames.map((cache) => {
                    if (cache !== CACHE_NAME) {
                        console.log('SW: Limpiando caché antigua', cache);
                        return caches.delete(cache);
                    }
                })
            );
        })
    );
    self.clients.claim();
});

// Interceptar peticiones (Fetch)
self.addEventListener('fetch', (event) => {
    const request = event.request;
    const url = new URL(request.url);

    // Identificar si es una petición a la API de datos (Network First)
    if (url.pathname.includes('/api/')) {
        event.respondWith(networkFirst(request));
    } else {
        // Para todo lo demás (estáticos), usar Cache First
        event.respondWith(cacheFirst(request));
    }
});

// Estrategia: Cache First (Prioriza la caché, si no está, va a la red)
async function cacheFirst(request) {
    const cachedResponse = await caches.match(request);
    if (cachedResponse) {
        return cachedResponse; // Retorna desde caché
    }
    try {
        const networkResponse = await fetch(request);
        const cache = await caches.open(CACHE_NAME);
        // Solo guardamos en caché si la respuesta es válida y exitosa
        if (networkResponse.ok) {
            cache.put(request, networkResponse.clone());
        }
        return networkResponse;
    } catch (error) {
        // Modo offline estricto: si falla la red y no está en caché
        console.error('SW: Falló Cache First para', request.url, error);
        return new Response('Contenido no disponible offline', {
            status: 503,
            statusText: 'Service Unavailable'
        });
    }
}

// Estrategia: Network First (Prioriza la red, si falla, va a la caché)
async function networkFirst(request) {
    try {
        const networkResponse = await fetch(request);
        const cache = await caches.open(CACHE_NAME);
        if (networkResponse.ok) {
            cache.put(request, networkResponse.clone()); // Actualiza la caché con los datos más recientes
        }
        return networkResponse;
    } catch (error) {
        // Si no hay red (offline), intenta servir los últimos datos guardados
        console.log('SW: Sin red, sirviendo desde caché API (Network First fallback)');
        const cachedResponse = await caches.match(request);
        return cachedResponse || new Response(JSON.stringify({ error: "Offline y sin datos cacheados" }), {
            headers: { 'Content-Type': 'application/json' }
        });
    }
}