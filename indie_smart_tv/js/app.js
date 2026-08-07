document.addEventListener('DOMContentLoaded', async () => {
    try {
        const response = await fetch('http://localhost:3001/api/juegos');
        const juegos = await response.json();
        const grid = document.getElementById('grid-container');

        juegos.slice(0, 4).forEach((juego, index) => {
            const card = document.createElement('div');
            card.className = 'game-card';
            if (index === 0) card.classList.add('foco-activo');
            card.setAttribute('data-index', index);

            card.innerHTML = `
                <h2 class="titulo-juego">${juego.title}</h2>
                <p class="precio-juego">$${juego.price}</p>
            `;
            grid.appendChild(card);
        });

        window.initNavigation();
    } catch (error) {
        const grid = document.getElementById('grid-container');
        grid.innerHTML = '<h2 class="titulo-juego">Error de red</h2>';
    }
});

document.addEventListener('DOMContentLoaded', async () => {
    try {
        const response = await fetch('http://localhost:3001/api/juegos');
        const juegos = await response.json();
        const grid = document.getElementById('grid-container');

        juegos.slice(0, 4).forEach((juego, index) => {
            const card = document.createElement('div');
            card.className = 'game-card';
            if (index === 0) card.classList.add('foco-activo');
            card.setAttribute('data-index', index);

            card.innerHTML = `
                <h2 class="titulo-juego">${juego.title}</h2>
                <p class="precio-juego">$${juego.price}</p>
            `;
            grid.appendChild(card);
        });

        window.initNavigation();
    } catch (error) {
        const grid = document.getElementById('grid-container');
        grid.innerHTML = '<h2 class="titulo-juego">Error de red</h2>';
    }
});

const socket = io('http://localhost:3001');

socket.on('tv_actualizar_biblioteca', (data) => {
    const header = document.querySelector('.header-text');
    const originalText = header.innerText;
    header.innerText = data.mensaje;
    header.style.color = '#FFD700';
    
    setTimeout(() => {
        header.innerText = originalText;
        header.style.color = '#ffffff';
    }, 4000);
});

socket.on('tv_alerta_wearable', (data) => {
    const header = document.querySelector('.header-text');
    const originalText = header.innerText;
    header.innerText = "¡ALERTA!: " + data.mensaje;
    header.style.color = '#FF0055';
    
    setTimeout(() => {
        header.innerText = originalText;
        header.style.color = '#ffffff';
    }, 4000);
});