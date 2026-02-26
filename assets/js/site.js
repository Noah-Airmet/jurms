document.addEventListener('DOMContentLoaded', function () {
  var toggle = document.querySelector('.site-nav-toggle');
  var nav = document.querySelector('.site-nav');

  if (!toggle || !nav) return;

  function closeNav() {
    nav.classList.remove('is-open');
    toggle.classList.remove('site-nav-toggle--open');
    toggle.setAttribute('aria-expanded', 'false');
  }

  toggle.addEventListener('click', function () {
    var isOpen = !nav.classList.contains('is-open');

    if (isOpen) {
      nav.classList.add('is-open');
      toggle.classList.add('site-nav-toggle--open');
    } else {
      closeNav();
    }

    toggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
  });

  nav.addEventListener('click', function (event) {
    if (event.target.closest('.site-nav__link')) {
      closeNav();
    }
  });

  window.addEventListener('resize', function () {
    if (window.innerWidth > 768) {
      closeNav();
    }
  });
});

