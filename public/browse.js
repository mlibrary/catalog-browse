/*
 * Select Dropdown Tips
 */
const selectDropdown = document.querySelector('.search-box-dropdown select');
const optionTips = document.querySelectorAll('p[data-option]');

selectDropdown.addEventListener('change', (event) => {
  optionTips.forEach((optionTip) => {
    const dataOptionValue = optionTip.getAttribute('data-option');
    optionTip.style.display = dataOptionValue === event.target.value ? 'initial' : 'none';
  });
});
