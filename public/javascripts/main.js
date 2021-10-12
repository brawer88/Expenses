function getEnvelopes(){
    jQuery.get('/envelopes', function(data) {
        console.log(data);
        $("#env_div").html(data["text"]);
    });
}

function getBanks(){
    jQuery.get('/banks', function(data) {
        console.log(data);
        $("#bank_div").html(data["text"]);
    });
}


// Check that service workers are supported
if ('serviceWorker' in navigator) {
  // Use the window load event to keep the page load performant
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/service-worker.js', { scope: '/' });
  });
}


