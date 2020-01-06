// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs



function loadMoreRepositories(link) {
  var container = link.parentElement.parentElement;
  container.classList.add('loading');

  fetch(link.href).then(function(response) {
    response.text().then(function(text) {
      container.insertAdjacentHTML('afterend', text);
      container.remove();
    })
  })
}

// Basic event delegation
document.addEventListener('click', function(e) {
  var loadMoreLink = e.target.closest('.js-load-more')
  if (loadMoreLink) {
    loadMoreRepositories(loadMoreLink)
    e.preventDefault()
  }
})
