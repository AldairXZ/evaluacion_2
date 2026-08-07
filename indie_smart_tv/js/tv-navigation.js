window.initNavigation = () => {
    let currentIndex = 0;
    const cards = document.querySelectorAll('.game-card');

    if (cards.length === 0) return;

    window.addEventListener('keydown', (e) => {
        cards[currentIndex].classList.remove('foco-activo');

        switch (e.key) {
            case 'ArrowRight':
                if (currentIndex === 0) currentIndex = 1;
                else if (currentIndex === 2) currentIndex = 3;
                break;
            case 'ArrowLeft':
                if (currentIndex === 1) currentIndex = 0;
                else if (currentIndex === 3) currentIndex = 2;
                break;
            case 'ArrowDown':
                if (currentIndex === 0) currentIndex = 2;
                else if (currentIndex === 1) currentIndex = 3;
                break;
            case 'ArrowUp':
                if (currentIndex === 2) currentIndex = 0;
                else if (currentIndex === 3) currentIndex = 1;
                break;
        }

        cards[currentIndex].classList.add('foco-activo');
    });
};