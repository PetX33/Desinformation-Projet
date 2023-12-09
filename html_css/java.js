document.addEventListener('DOMContentLoaded', function () {
    var toggleButton = document.querySelector('.navbar-toggler');
    var navbarContent = document.getElementById('navbarResponsive2');
    
    // Initialiser avec le menu caché
    navbarContent.style.display = 'none';

    // Fonction pour basculer la visibilité du contenu de la navbar
    function toggleNavbar() {
        if (navbarContent.style.display === 'block') {
            navbarContent.style.display = 'none';
        } else {
            navbarContent.style.display = 'block';
        }
    }

    // Écouteur d'événements sur le bouton
    toggleButton.addEventListener('click', function () {
        toggleNavbar();
    });

    // Écouteur d'événements pour les changements de taille de la fenêtre
    window.addEventListener('resize', function() {
        if (window.innerWidth > 992) { // Ajustez 992 à la largeur où vous voulez que le menu disparaisse
            navbarContent.style.display = 'none';
        }
    });
});