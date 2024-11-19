document.querySelector('.hamburger').addEventListener('click', function() {
  document.querySelector('nav ul').classList.toggle('open');
});

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

// Function to handle answer selection
function selectAnswer(questionId, score) {
    // Save the score
    answers[questionId] = score;

    // Update button styles
    const buttons = document.querySelectorAll(`[data-question-id="${questionId}"] button`);
    buttons.forEach((button, index) => {
        button.classList.remove('selected');
        button.classList.add('default');
        if (index === score) {
            button.classList.add('selected');
            button.classList.remove('default');
        }
    });

    // Update the score and interpretation
    calculateScoreAndInterpret();
}
