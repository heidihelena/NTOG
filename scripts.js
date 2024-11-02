// Countdown to event date
const eventDate = new Date("May 8, 2025 00:00:00").getTime();

const countdownTimer = setInterval(() => {
  const now = new Date().getTime();
  const timeLeft = eventDate - now;

  const days = Math.floor(timeLeft / (1000 * 60 * 60 * 24));
  const hours = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
  const minutes = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60));
  const seconds = Math.floor((timeLeft % (1000 * 60)) / 1000);

  document.getElementById("timer").innerHTML = `${days}d ${hours}h ${minutes}m ${seconds}s`;

  if (timeLeft < 0) {
    clearInterval(countdownTimer);
    document.getElementById("timer").innerHTML = "The event has started!";
  }
}, 1000);

document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("contactForm");
  const emailInput = document.getElementById("email");
  const submitButton = document.getElementById("submit");

  emailInput.addEventListener("input", (e) => {
    const emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
    if (!emailPattern.test(emailInput.value)) {
      emailInput.style.borderColor = "blue";
      submitButton.disabled = true;
    } else {
      emailInput.style.borderColor = "blue";
      submitButton.disabled = false;
    }
  });

  form.addEventListener("submit", (e) => {
    e.preventDefault(); // Prevent form from submitting
    // Further submission handling (e.g., AJAX call or displaying success message)
  });
});

document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener("click", function (e) {
    e.preventDefault();
    document.querySelector(this.getAttribute("href")).scrollIntoView({
      behavior: "smooth"
    });
  });
});

document.addEventListener("DOMContentLoaded", function() {
  const lazyImages = document.querySelectorAll("img.lazy");
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
});

document.getElementById("registerButton").addEventListener("click", function () {
  alert("Thank you for registering! A confirmation email has been sent to your address.");
});
