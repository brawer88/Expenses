function getEnvelopes(){
    jQuery.get('/envelopes', function(data) {
        console.log(data);
        $("#env_div").html(data["text"]);
    });
}

