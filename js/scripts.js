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
