document.addEventListener("DOMContentLoaded", function () {
  /* Legacy custom mobile navigation support.
     Bootstrap navbar pages do not need this, but older pages may still use:
     .hamburger + .nav-menu, .menu-toggle + .nav-links, or #myTopnav.
  */

  const hamburger = document.querySelector(".hamburger");
  const navMenu = document.querySelector(".nav-menu");

  if (hamburger && navMenu) {
    hamburger.addEventListener("click", function (event) {
      event.preventDefault();
      navMenu.classList.toggle("active");
      const expanded = navMenu.classList.contains("active");
      hamburger.setAttribute("aria-expanded", expanded ? "true" : "false");
    });
  }

  const menuToggle = document.querySelector(".menu-toggle");
  const navLinks = document.querySelector(".nav-links");
  const topnav = document.getElementById("myTopnav");

  if (menuToggle && navLinks) {
    menuToggle.addEventListener("click", function () {
      navLinks.classList.toggle("active");

      if (topnav) {
        topnav.classList.toggle("responsive");
      }

      const expanded = navLinks.classList.contains("active");
      menuToggle.setAttribute("aria-expanded", expanded ? "true" : "false");
    });

    navLinks.querySelectorAll("a").forEach(function (link) {
      link.addEventListener("click", function () {
        navLinks.classList.remove("active");
        menuToggle.setAttribute("aria-expanded", "false");

        if (topnav) {
          topnav.classList.remove("responsive");
        }
      });
    });
  }

  /* Active-state highlighting for the Bootstrap navbar.
     The same nav markup is stamped into every page, so the current section is
     marked here from the URL instead of being hardcoded per file. */
  (function () {
    const here = window.location.pathname.replace(/\/index\.html$/, "/");
    const topItems = document.querySelectorAll("#navbarNav .navbar-nav > .nav-item");

    topItems.forEach(function (li) {
      const hub = li.querySelector(".nav-link");
      if (!hub) return;

      let active = false;
      li.querySelectorAll("a[href]").forEach(function (a) {
        const href = a.getAttribute("href");
        if (!href || href === "#") return;

        let p;
        try {
          p = new URL(href, window.location.origin).pathname;
        } catch (e) {
          return;
        }
        p = p.replace(/\/index\.html$/, "/");

        if (p === here) {
          active = true;
        } else if (p !== "/" && p.endsWith("/") && here.indexOf(p) === 0) {
          /* Section match, e.g. "/ntog2027/" highlights "/ntog2027/programme.html". */
          active = true;
        }
      });

      if (active) {
        hub.classList.add("active");
        hub.setAttribute("aria-current", "page");
      }
    });
  })();

  /* Smooth scroll for same-page anchor links only.
     Does not interfere with Bootstrap dropdown toggles or empty href="#" controls.
  */
  document.querySelectorAll('a[href^="#"]').forEach(function (anchor) {
    anchor.addEventListener("click", function (event) {
      const href = anchor.getAttribute("href");

      if (!href || href === "#") return;

      const targetId = href.substring(1);
      const targetElement = document.getElementById(targetId);

      if (targetElement) {
        event.preventDefault();
        targetElement.scrollIntoView({ behavior: "smooth", block: "start" });
        history.pushState(null, "", href);
      }
    });
  });

  /* Lazy loading for images using:
     <img class="lazy" data-src="image.jpg" alt="...">
  */
  const lazyImages = document.querySelectorAll("img.lazy[data-src]");

  if (lazyImages.length > 0) {
    if ("IntersectionObserver" in window) {
      const imageObserver = new IntersectionObserver(function (entries, observer) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            const img = entry.target;
            img.src = img.dataset.src;
            img.classList.remove("lazy");
            observer.unobserve(img);
          }
        });
      });

      lazyImages.forEach(function (image) {
        imageObserver.observe(image);
      });
    } else {
      lazyImages.forEach(function (image) {
        image.src = image.dataset.src;
        image.classList.remove("lazy");
      });
    }
  }

  /* Deprecated demo registration button support.
     Prefer real registration links on production pages.
  */
  const registerButton = document.getElementById("registerButton");
  if (registerButton) {
    registerButton.addEventListener("click", function () {
      alert("Registration is not yet open. Please follow NTOG updates for further information.");
    });
  }

  /* Lightweight contact-form validation.
     Only runs if a form with id="contactForm" exists.
  */
  const form = document.getElementById("contactForm");

  if (form) {
    const emailInput = form.querySelector('input[type="email"], #email');
    const submitButton = form.querySelector('button[type="submit"], #submit');

    if (emailInput && submitButton) {
      emailInput.addEventListener("input", function () {
        const valid = emailInput.checkValidity();
        emailInput.classList.toggle("is-invalid", !valid && emailInput.value.length > 0);
        submitButton.disabled = !valid;
      });
    }

    form.addEventListener("submit", function (event) {
      if (!form.checkValidity()) {
        event.preventDefault();
        event.stopPropagation();
      }

      form.classList.add("was-validated");
    });
  }
});
