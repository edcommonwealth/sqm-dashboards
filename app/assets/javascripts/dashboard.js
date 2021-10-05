document.addEventListener("DOMContentLoaded", function() {
  document.querySelector('#select-school').addEventListener('change', (event) => {
    window.location = event.target.value;
  });

  document.querySelector('#select-district').addEventListener('change', (event) => {
    window.location = event.target.value;
  });
});
