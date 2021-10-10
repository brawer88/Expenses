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
