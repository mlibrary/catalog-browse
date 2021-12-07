/*
 * Select Dropdown Tips
 */
const selectDropdown = document.querySelector('.search-box-dropdown select');
const getOptionTips = document.querySelectorAll('p[data-option]');

selectDropdown.addEventListener('change', (event) => {
  getOptionTips.forEach((optionTip) => {
    const getDataOption = optionTip.getAttribute('data-option');
    optionTip.style.display = getDataOption === event.target.value ? 'initial' : 'none';
  });
});
