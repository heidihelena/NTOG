menuToggle.addEventListener('click', toggleMenu);
menuToggle.addEventListener('touchstart', toggleMenu);

// Toggle function for responsive design
function toggleNav() {
  var x = document.getElementById("myTopnav");
  if (x.className === "topnav") {
    x.className += " responsive";
  } else {
    x.className = "topnav";
  }
}

// Select elements
const menuToggle = document.querySelector('.menu-toggle');
const navLinks = document.querySelector('.nav-links');
const links = document.querySelectorAll('.nav-links a');

// Event listener for menu toggle
menuToggle.addEventListener('click', () => {
  navLinks.classList.toggle('active');
  toggleNav(); // Call the toggleNav function when menu is clicked
});

// Event listeners for individual links (optional)
links.forEach(link => {
  link.addEventListener('click', () => {
    navLinks.classList.remove('active');
    // Reset the topnav class when a link is clicked
    document.getElementById("myTopnav").className = "topnav";
  });
});

// Ensure the DOM is fully loaded
document.addEventListener("DOMContentLoaded", function() {

  // Smooth Scroll for Anchor Links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener("click", function (e) {
      const targetId = this.getAttribute("href").substring(1);
      const targetElement = document.getElementById(targetId);

      if (targetElement) {
        e.preventDefault();
        targetElement.scrollIntoView({
          behavior: "smooth"
        });
      }
    });
  });

  // Lazy Loading Images (if any images have class 'lazy')
  const lazyImages = document.querySelectorAll("img.lazy");
  if ("IntersectionObserver" in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target;
          img.src = img.dataset.src;
          img.classList.remove("lazy");
          imageObserver.unobserve(img);
        }
      });
    });

    lazyImages.forEach(image => {
      imageObserver.observe(image);
    });
  } else {
    // Fallback for browsers that don't support IntersectionObserver
    lazyImages.forEach(image => {
      image.src = image.dataset.src;
      image.classList.remove("lazy");
    });
  }

  // Alert for Register Button (if exists)
  const registerButton = document.getElementById("registerButton");
  if (registerButton) {
    registerButton.addEventListener("click", function () {
      alert("Thank you for registering! A confirmation email has been sent to your address.");
    });
  }

  // Contact Form Validation (if a form with id 'contactForm' exists)
  const form = document.getElementById("contactForm");
  if (form) {
    const emailInput = document.getElementById("email");
    const submitButton = document.getElementById("submit");

    emailInput.addEventListener("input", (e) => {
      const emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
      if (!emailPattern.test(emailInput.value)) {
        emailInput.style.borderColor = "red";
        submitButton.disabled = true;
      } else {
        emailInput.style.borderColor = "";
        submitButton.disabled = false;
      }
    });

    form.addEventListener("submit", (e) => {
      e.preventDefault(); // Prevent form from submitting
      // Further submission handling (e.g., AJAX call or displaying success message)
    });
  }

});

