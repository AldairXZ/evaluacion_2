// 1. Registro del Service Worker (SA.2.A)
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('./sw.js')
            .then(reg => console.log('SW registrado con éxito', reg.scope))
            .catch(err => console.error('Error al registrar SW', err));
    });
}

// 2. Ciclo de vida de los datos (AU.3)
function limpiarDatosAntiguos() {
    const TIEMPO_MAXIMO = 30 * 24 * 60 * 60 * 1000; // 30 días en milisegundos
    const ahora = Date.now();
    
    // La eliminación se ejecuta al iniciar la app, sin requerir acción del usuario
    for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        try {
            const item = JSON.parse(localStorage.getItem(key));
            // Si el item tiene un timestamp y tiene más de 30 días, se borra
            if (item && item.timestamp && (ahora - item.timestamp > TIEMPO_MAXIMO)) {
                localStorage.removeItem(key);
                console.log(`Dato eliminado por política de retención (30 días): ${key}`);
            }
        } catch (e) {
            // Si no es un objeto JSON válido, lo ignoramos
        }
    }
}

document.addEventListener('DOMContentLoaded', async () => {
    // Ejecutamos la limpieza automática al cargar (AU.3)
    limpiarDatosAntiguos();

    try {
        const response = await fetch('http://localhost:3001/api/juegos');
        const juegos = await response.json();
        const grid = document.getElementById('grid-container');

        // Mínimo 4 registros de la API (SA.2.C)
        juegos.slice(0, 4).forEach((juego, index) => {
            const card = document.createElement('div');
            card.className = 'game-card';
            // Ajusta la clase de foco activo según la uses en tu css
            if (index === 0) card.classList.add('active'); 
            card.setAttribute('data-index', index);
            
            // Guardamos el background para cambiarlo al enfocar (SA.2.C)
            card.setAttribute('data-bg', juego.bg || ''); 

            // Se inyectan mínimo 3 campos relevantes del caso de estudio (SA.2.C)
            card.innerHTML = `
                <p class="main-data">${juego.title}</p>
                <p class="secondary-data">${juego.developer || 'Indie Studio'}</p>
                <p class="detail-data">$${juego.price}</p>
            `;
            grid.appendChild(card);
        });

        // Inicializar la navegación D-pad externa
        if (typeof window.initNavigation === 'function') {
            window.initNavigation(); 
        }
    } catch (error) {
        // Fallback visual documentado: qué ve el usuario si la API falla (DE.3)
        const grid = document.getElementById('grid-container');
        grid.innerHTML = '<p class="main-data">Catálogo offline. Revise su conexión.</p>';
    }
});

// 3. Sincronización bidireccional y alertas en tiempo real (AU.1)
// Se incluye una autenticación mínima (token compartido)
const socket = io('http://localhost:3001', {
    auth: {
        token: "indiehub-tv-client-token" 
    }
});

socket.on('tv_actualizar_biblioteca', (data) => {
    // Apuntamos al h1 del header o a tu clase específica
    const header = document.querySelector('.tv-header h1') || document.querySelector('.header-text');
    if (!header) return;
    
    const originalText = header.textContent;
    
    // Uso de textContent en lugar de innerHTML previene payloads XSS (AU.2)
    header.textContent = data.mensaje; 
    header.style.color = '#fbbf24'; // Color de acento IndieHub
    
    setTimeout(() => {
        header.textContent = originalText;
        header.style.color = '';
    }, 4000);
});

socket.on('tv_alerta_wearable', (data) => {
    // La TV recibe la notificación enviada por el teléfono sobre los datos del Wearable (AU.1)
    const header = document.querySelector('.tv-header h1') || document.querySelector('.header-text');
    if (!header) return;
    
    const originalText = header.textContent;
    
    header.textContent = "¡ALERTA!: " + data.mensaje;
    header.style.color = '#FF0055'; 
    
    setTimeout(() => {
        header.textContent = originalText;
        header.style.color = '';
    }, 4000);
});