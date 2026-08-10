// Simulación de datos de la API del catálogo IndieHub (mínimo 3 campos)
const mockJuegos = [
    { id: 0, titulo: "Hollow Knight", dev: "Team Cherry", precio: "$15.00", bg: "https://ejemplo.com/hollow.jpg" },
    { id: 1, titulo: "Celeste", dev: "Maddy Makes Games", precio: "$19.99", bg: "https://ejemplo.com/celeste.jpg" },
    { id: 2, titulo: "Hades", dev: "Supergiant Games", precio: "$24.99", bg: "https://ejemplo.com/hades.jpg" },
    { id: 3, titulo: "Stardew Valley", dev: "ConcernedApe", precio: "$14.99", bg: "https://ejemplo.com/stardew.jpg" }
];

let indiceActual = 0; // Empezamos en la primera tarjeta (arriba a la izquierda)
const columnas = 2;
const filas = 2;

function renderizarGrid() {
    const grid = document.getElementById('game-grid');
    grid.innerHTML = ''; // Limpiar el grid

    mockJuegos.forEach((juego, index) => {
        // Creamos la tarjeta del juego
        const card = document.createElement('div');
        card.className = 'game-card';
        card.id = `card-${index}`;
        card.tabIndex = -1; // Permite que reciba el foco programáticamente

        // Inyectamos los 3 datos requeridos (SA.2.C)
        card.innerHTML = `
            <p class="main-data">${juego.titulo}</p>
            <p class="secondary-data">${juego.dev}</p>
            <p class="detail-data">${juego.precio}</p>
        `;
        grid.appendChild(card);
    });

    actualizarFoco();
}

function actualizarFoco() {
    // Removemos la clase activa de todas las tarjetas
    document.querySelectorAll('.game-card').forEach(card => {
        card.classList.remove('active');
    });

    // Añadimos el resplandor dorado a la tarjeta actual (SA.2.B)
    const tarjetaActiva = document.getElementById(`card-${indiceActual}`);
    if (tarjetaActiva) {
        tarjetaActiva.classList.add('active');
        tarjetaActiva.focus();
    }
}

// Actualiza el fondo cuando se presiona Enter/OK (SA.2.C)
function actualizarFondo() {
    const background = document.getElementById('media-background');
    const juegoSeleccionado = mockJuegos[indiceActual];
    
    // Fallback visual por si el recurso falla (SA.2.C)
    background.style.backgroundColor = '#1e293b'; 
    background.style.backgroundImage = `url('${juegoSeleccionado.bg}')`;
}

// Captura de eventos del teclado/D-pad (SA.2.C)
window.addEventListener('keydown', (e) => {
    switch (e.key) {
        case 'ArrowRight':
            if ((indiceActual + 1) % columnas !== 0) indiceActual++;
            break;
        case 'ArrowLeft':
            if (indiceActual % columnas !== 0) indiceActual--;
            break;
        case 'ArrowDown':
            if (indiceActual + columnas < mockJuegos.length) indiceActual += columnas;
            break;
        case 'ArrowUp':
            if (indiceActual - columnas >= 0) indiceActual -= columnas;
            break;
        case 'Enter':
            actualizarFondo();
            break;
    }
    actualizarFoco();
});

// Mostrar hora contextual en el header (SA.2.C)
setInterval(() => {
    document.getElementById('datetime').innerText = new Date().toLocaleTimeString();
}, 1000);

// Inicializar la app
window.onload = () => {
    renderizarGrid();
    actualizarFondo(); // Cargar el fondo del primer elemento por defecto
};