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
let installButton = document.createElement('button');

window.addEventListener('beforeinstallprompt', (e) => {
  // Prevent the mini-infobar from appearing on mobile
  e.preventDefault();
  // Stash the event so it can be triggered later.
  deferredPrompt = e;
  // Update UI notify the user they can install the PWA
  deferredPrompt.prompt();
  // Optionally, send analytics event that PWA install promo was shown.
  console.log(`'beforeinstallprompt' event was fired.`);
});

installButton.addEventListener('click', function(){
    deferredPrompt.prompt();
 });

let installed = false;
installButton.addEventListener('click', async function(){
    deferredPrompt.prompt();
  let result = await that.prompt.userChoice;
  if (result&&result.outcome === 'accepted') {
     installed = true;
  }
});

window.addEventListener('appinstalled', async function(e) {
    installButton.style.display = "none";
 });

// Check that service workers are supported
if ('serviceWorker' in navigator) {
  // Use the window load event to keep the page load performant
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/service-worker.js', { scope: '/' });
  });
}


