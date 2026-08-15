let juegosAPI = [];
let juegosBiblioteca = [];

let filaActual = 1; 
let indiceTienda = 0;
let indiceBiblioteca = 0;
let juegoPendiente = null;

async function cargarDatosAPI() {
    try {
        const response = await fetch('http://localhost:3001/api/juegos');
        juegosAPI = await response.json();
        renderizarListas();
        actualizarFondo();
    } catch (error) {
        document.getElementById('tienda-container').innerHTML = '<p class="main-data">Offline</p>';
    }
}

function renderizarListas() {
    const gridBiblio = document.getElementById('biblioteca-container');
    gridBiblio.innerHTML = '';
    if (juegosBiblioteca.length === 0) {
        gridBiblio.innerHTML = '<p style="color: #666; font-size: 2rem; margin-left: 10px;">Aún no tienes juegos recientes.</p>';
    } else {
        juegosBiblioteca.forEach((juego, index) => {
            gridBiblio.appendChild(crearTarjetaDOM(juego, `biblio-${index}`, false));
        });
    }

    const gridTienda = document.getElementById('tienda-container');
    gridTienda.innerHTML = ''; 
    juegosAPI.forEach((juego, index) => {
        gridTienda.appendChild(crearTarjetaDOM(juego, `tienda-${index}`, true));
    });

    actualizarFoco();
}

function crearTarjetaDOM(juego, id, esTienda) {
    const card = document.createElement('div');
    card.className = 'game-card';
    card.id = id;
    
    const etiquetaSecundaria = esTienda 
        ? `<p class="detail-data">$${juego.price}</p>` 
        : `<p class="biblio-label">ADQUIRIDO</p>`;

    // Estructura HTML actualizada para el agrupador secundario (evita empalmes)
    card.innerHTML = `
        <div class="card-image" style="background-image: url('${juego.bg}')"></div>
        <div class="card-content">
            <p class="main-data" title="${juego.title}">${juego.title}</p>
            <div class="secondary-wrapper">
                <p class="secondary-data">${juego.developer || 'IndieHub'}</p>
                ${etiquetaSecundaria}
            </div>
        </div>
    `;
    return card;
}

function actualizarFoco() {
    document.querySelectorAll('.game-card').forEach(card => card.classList.remove('active'));
    
    let targetId = filaActual === 0 ? `biblio-${indiceBiblioteca}` : `tienda-${indiceTienda}`;
    const tarjetaActiva = document.getElementById(targetId);
    
    if (tarjetaActiva) {
        tarjetaActiva.classList.add('active');
        // Asegura que la tarjeta enfocada siempre esté visible en pantalla sin usar scrollbars
        tarjetaActiva.scrollIntoView({ behavior: 'smooth', inline: 'center', block: 'nearest' });
    }
}

function actualizarFondo() {
    const background = document.getElementById('media-background');
    const lista = filaActual === 0 ? juegosBiblioteca : juegosAPI;
    const idx = filaActual === 0 ? indiceBiblioteca : indiceTienda;

    if (lista.length > 0 && lista[idx]) {
        background.style.backgroundImage = `url('${lista[idx].bg}')`;
    }
}

if (window.socket) {
    window.socket.on('2fa_approved_success', () => {
        if (juegoPendiente) {
            if (!juegosBiblioteca.some(j => j.title === juegoPendiente.title)) {
                juegosBiblioteca.push(juegoPendiente);
                renderizarListas();
            }
            juegoPendiente = null;
        }
    });

    window.socket.on('juego_comprado', (juego) => {
        if (!juegosBiblioteca.some(j => j.title === juego.title)) {
            juegosBiblioteca.push(juego);
            renderizarListas();
        }
    });
}

window.addEventListener('keydown', (e) => {
    if (juegosAPI.length === 0) return;
    
    switch (e.key) {
        case 'ArrowRight':
            if (filaActual === 0 && indiceBiblioteca < juegosBiblioteca.length - 1) indiceBiblioteca++;
            if (filaActual === 1 && indiceTienda < juegosAPI.length - 1) indiceTienda++;
            break;
        case 'ArrowLeft':
            if (filaActual === 0 && indiceBiblioteca > 0) indiceBiblioteca--;
            if (filaActual === 1 && indiceTienda > 0) indiceTienda--;
            break;
        case 'ArrowDown':
            if (filaActual === 0 && juegosAPI.length > 0) filaActual = 1;
            break;
        case 'ArrowUp':
            if (filaActual === 1 && juegosBiblioteca.length > 0) {
                filaActual = 0;
                if (indiceBiblioteca >= juegosBiblioteca.length) indiceBiblioteca = juegosBiblioteca.length - 1;
            }
            break;
        case 'Enter':
            if (filaActual === 1 && window.socket && juegosAPI.length > 0) {
                juegoPendiente = juegosAPI[indiceTienda];
                window.socket.emit('tv_purchase_attempt', { juego: juegoPendiente.title });
            }
            break;
    }
    actualizarFondo();
    actualizarFoco();
});

setInterval(() => {
    document.getElementById('datetime').innerText = new Date().toLocaleTimeString();
}, 1000);

window.onload = () => {
    cargarDatosAPI(); 
};