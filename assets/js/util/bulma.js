const initNavbar = () => {
  document.addEventListener('DOMContentLoaded', function () {
    // Get all "navbar-burger" elements
    const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);
    // Check if there are any nav burgers
    if ($navbarBurgers.length > 0) {
      // Add a click event on each of them
      $navbarBurgers.forEach(function ($el) {
        $el.addEventListener('click', () => {
          // Get the target from the "data-target" attribute
          const target = $el.dataset.target;
          const $target = document.getElementById(target);
          // Toggle the class on both the "navbar-burger" and the "navbar-menu"
          $el.classList.toggle('is-active');
          $target.classList.toggle('is-active');
        });
      });
    }
  });
}

const initNotificationListener = () => {
  // Notification message dismiss
  document.querySelectorAll('.notification-section .notification .delete').forEach((elem) => {
    elem.addEventListener('click', () => {
      console.log('click fire');
      const article = elem.parentNode;
      const section = article.parentNode;
      section.removeChild(article);
      if (section.innerHTML.trim() === "") {
        section.parentElement.removeChild(section);
      }
    })
  });
}

initNavbar();
initNotificationListener();
