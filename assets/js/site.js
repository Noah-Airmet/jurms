document.addEventListener('DOMContentLoaded', function () {
  var toggle = document.querySelector('.site-nav-toggle');
  var nav = document.querySelector('.site-nav');

  if (toggle && nav) {
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
  }

  var body = document.body;
  if (!body || body.getAttribute('data-theme') !== 'stained-glass') {
    return;
  }

  var reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var coarsePointer = window.matchMedia('(hover: none), (pointer: coarse)').matches;

  if (reducedMotion || coarsePointer) {
    body.setAttribute('data-spotlight', 'off');
    return;
  }

  body.setAttribute('data-spotlight', 'on');

  var targetX = window.innerWidth * 0.5;
  var targetY = window.innerHeight * 0.35;
  var currentX = targetX;
  var currentY = targetY;
  var rafId = null;

  function setSpot(x, y) {
    body.style.setProperty('--spot-x', x + 'px');
    body.style.setProperty('--spot-y', y + 'px');
  }

  function animateSpot() {
    var dx = targetX - currentX;
    var dy = targetY - currentY;
    currentX += dx * 0.16;
    currentY += dy * 0.16;
    setSpot(currentX, currentY);

    if (Math.abs(dx) > 0.2 || Math.abs(dy) > 0.2) {
      rafId = window.requestAnimationFrame(animateSpot);
    } else {
      rafId = null;
    }
  }

  function queueAnimation() {
    if (rafId == null) {
      rafId = window.requestAnimationFrame(animateSpot);
    }
  }

  window.addEventListener('pointermove', function (event) {
    targetX = event.clientX;
    targetY = event.clientY;
    body.style.setProperty('--spot-opacity', '0.24');
    body.setAttribute('data-spotlight', 'on');
    queueAnimation();
  }, { passive: true });

  window.addEventListener('pointerenter', function () {
    body.style.setProperty('--spot-opacity', '0.24');
    body.setAttribute('data-spotlight', 'on');
  });

  window.addEventListener('pointerleave', function () {
    body.style.setProperty('--spot-opacity', '0.0');
    body.setAttribute('data-spotlight', 'off');
    targetX = window.innerWidth * 0.5;
    targetY = window.innerHeight * 0.35;
    queueAnimation();
  });
});
