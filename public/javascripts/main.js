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

// Initialize deferredPrompt for use later to show browser install prompt.
let deferredPrompt;

window.addEventListener('beforeinstallprompt', (e) => {
  // Prevent the mini-infobar from appearing on mobile
  e.preventDefault();
  // Stash the event so it can be triggered later.
  deferredPrompt = e;
  // Update UI notify the user they can install the PWA
  var shown = Cookies.get('install_shown');
  if (! shown )
  {
     InstallMe(); 
  }
  
  // Optionally, send analytics event that PWA install promo was shown.
  console.log(`'beforeinstallprompt' event was fired.`);
});

// Check that service workers are supported
if ('serviceWorker' in navigator) {
  // Use the window load event to keep the page load performant
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/service-worker.js', { scope: '/' });
  });
}


function InstallMe()
{
    Cookies.set('install_shown', 'true');
    $('#install_me').modal({show: true});
}