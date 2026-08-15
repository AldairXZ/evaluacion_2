if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('./sw.js').catch(() => {});
    });
}

function limpiarDatosAntiguos() {
    const TIEMPO_MAXIMO = 30 * 24 * 60 * 60 * 1000;
    const ahora = Date.now();
    for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        try {
            const item = JSON.parse(localStorage.getItem(key));
            if (item && item.timestamp && (ahora - item.timestamp > TIEMPO_MAXIMO)) {
                localStorage.removeItem(key);
            }
        } catch (e) {}
    }
}

document.addEventListener('DOMContentLoaded', () => {
    limpiarDatosAntiguos();
});

window.socket = io('http://localhost:3001', {
    auth: { token: "indiehub-tv-client-token" }
});

window.socket.on('tv_actualizar_biblioteca', (data) => {
    const header = document.querySelector('.tv-header h1');
    if (!header) return;
    const originalText = "IndieHub";
    header.textContent = data.mensaje; 
    header.style.color = '#fbbf24'; 
    setTimeout(() => { header.textContent = originalText; header.style.color = ''; }, 4000);
});

window.socket.on('2fa_approved_success', (data) => {
    const header = document.querySelector('.tv-header h1');
    if (!header) return;
    const originalText = "IndieHub";
    header.textContent = "✅ " + data.mensaje;
    header.style.color = '#00FF00'; 
    setTimeout(() => { header.textContent = originalText; header.style.color = ''; }, 4000);
});

window.socket.on('tv_alerta_wearable', (data) => {
    const header = document.querySelector('.tv-header h1');
    if (!header) return;
    const originalText = "IndieHub";
    header.textContent = "¡ALERTA!: " + data.mensaje;
    header.style.color = '#FF0055'; 
    setTimeout(() => { header.textContent = originalText; header.style.color = ''; }, 4000);
});