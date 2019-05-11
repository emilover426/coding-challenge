let key = "AdDHczhAXdgz1SZQrYuiZS4fQQXcmlX9";
var wolfram_key = "6V23E7-Q233HG8UEJ";
var hidden_text;
var hidden_text_list = [];
var images_chosen = [];
var curBtn;
var turn = 1;
var uid;
var round;
var p1;
var p2;
var chekced;


$(function () {

    uid = getUid();
    round = getRound();
    getPlayer();
    $("#write").append(

        "<h3>"+
            ""+ findName() +"'s turn to pick a word"+
        "</h3>"
    );
    console.log(p1);
    console.log(p2);

    $('#playerScore1').text(p1);
    $('#playerScore2').text(p2);
    

    $("#goBtn").on( "click", function(event) {
        let p1 = $("#p1Name").val();
        let p2 = $("#p2Name").val();
        if (p1 === "" || p2 === "") {
            $(this).effect( "shake" );
        }
        else {
            store.set("p1",p1);
            store.set("p2",p2);
            let checked = 1;
            if ($('ageCheck1').is(":checked") && $('ageCheck1').is(":checked")) {
                store.set("check",1);
            }
            else {
                store.set("check",0);
            }
            window.location.replace("index.html");
        }
        
    });

    console.log("uid??   " + uid);
    let submit = $( ".btn-submit" );
    let word = $(".gif-popover");
    let images = "";
    let images_count = 0;
    

    let restart = $('#restartBtn');
    let addScore = $('#scoreBtn');

    

    /*
    Bootstrap Popover
    */
    $('#popover').popover({
        // trigger: "hover",
    });

    $(document).on( "click", function(event) {
        // console.log(event.target);
        $
    });

    submit.on( "click", function() {
        // Take text
        text = $("#inputText").val();
        if (text === '') {
            $( "#inputText" ).effect( "shake" );
            return;
        }
        $('input').val("");
        let append  = parser(text);
        // Append
        submit.trigger( "appendEvent", append);
        $(this).prop("disabled",true);
    });

    submit.on( "appendEvent", function(event, append) {
        $("ul").append("<li class=\"list-group-item\">" + append + "</li>");
        $('.gif-popover').popover({
            trigger: "click",
            html: true,
            placement: "right",
            // https://stackoverflow.com/questions/41124657/dynamic-bootstrap-popover-content
            content: function () {
                let gif = "";
                let q = this.innerText;
                let inner = q;
                //indexof
                hidden_text = q.toLowerCase().replace(/\W/g, '');
                hidden_text_list.push(hidden_text);
                curBtn = $(this);

                 //Wolfram Alpha API Call
                //  let wolfram_url = "https://api.wolframalpha.com/v2/query?appid="+wolfram_key+"&input=word%20"+inner+"%20inflected%20forms"+
                //  "&includepodid=Result&format=plaintext&output=json";
                //  console.log("wofffff");
                //   $.ajax({
                //     url: wolfram_url,
                //     async: false,
                //     success: function(return_words){
                //         console.log(typeof return_words);
                //         var txt = return_words;
                //         var obj = JSON.parse(txt);
                //         var plaintext = obj.queryresult.pods[0].subpods[0].plaintext;
                //         console.log(plaintext);
                //         splitText(plaintext);
                //     }
                // });
                let limit = 8;
                let offect = 0;
                let rating = "G";
                let lan = "en";
                let url = "https://api.giphy.com/v1/gifs/search?" + "api_key=" + key + "&q=" + q + "&limit=" + limit + "&offect=" +offect + "&rating=" + rating + "&lan=" + lan;
                console.log(url);
                $.ajax({
                    url: url,
                    async: false,
                    success: function(data) {
                        // clear
                        images = "";
                        // gif = "<img src=\"" + data.data.images.downsized.url + "\" class=\"img-thumbnail\">";
                        $.each(data.data, function ( index, value ) {
                            console.log( index + ": " + value.images.fixed_width_small.url );
                            images = images + "<img src=\"" + value.images.fixed_width_small.url + "\" class=\"img-thumbnail img-fluid\" alt=\"Responsive image\">";
                        });
                    }
                });
                console.log(images);
                // clear previous chosen images
                images_chosen = [];
                let f = images + "<button type=\"button\"  class=\"btn btn-outline-success\">Select</button>";
                return f;
            },
        });

        // https://stackoverflow.com/questions/36546217/using-bootstrap-popover-callback
        $(".gif-popover").on('shown.bs.popover', function () {
            $(".img-thumbnail").click(function () {
                // choose at most three gif images
                if (images_chosen.includes(this.attributes[0].value)) {
                    
                    images_chosen.remove(this.attributes[0].value);
                    $(this).removeClass("gif_blur"); 
                }
                else if (images_chosen.length < 3 && !images_chosen.includes(this.attributes[0].value)) {
                    $(this).addClass("gif_blur");
                    images_chosen.push(this.attributes[0].value);
                }
            });
            

            $(".btn-outline-success").click(function () {
                // store images_chosen through store.js
                if (images_chosen.length == 3){
                    let urls = "";
                    urls += images_chosen[0];
                    urls += " " + images_chosen[1];
                    urls += " " + images_chosen[2];
                    console.log("hidden text: " + hidden_text);
                    curBtn.html("____");
                    appendGuess();
                    $('.gif-popover').popover("hide");
                    $('.gif-popover').popover('disable');
                    
                    

                    storeWord(round,hidden_text);
                    storeUrls(round,urls);
                }
                else {
                    $(this).effect( "shake", 
                    {times:10},100);
                }
            });
        });
    });

    // ************ helper methods ***********

    $("#score1").text(getScore(1));
    addScore.on( "click", function() {
        cur = getScore(1);
        console.log("cur: " + cur);
        setScore(1,cur + 1);
        next = getScore(1);
        console.log("next: " + next);
        $("#score1").text(next);
        window.location.reload();


    });


    function setScore(uid,score) {
        store.set("uid:"+uid+"score",score);
    }

    function getScore(uid) {
        let score = store.get("uid:"+uid+"score");
        if (typeof score == "undefined") {
            return 0;
        }
        else {
            return score;
        }
    }

    function findName() {
        if (getUid() === 1) {
            return p1;
        }
        else {
            return p2;
        }
    }
    function storeWord(round,word) {
        store.set("round:"+round+"word", word); 
    }
    function storeUrls(round,urls) {
        store.set("round:"+round+"urls", urls); 
    }
    function getWord(round) {
        return store.get("round:"+round+"word");
    }
    function getCheck() {
        return store.get("check");
    }
    function getUrls(round) {
        return store.get("round:"+round+"urls");
    }
    function setUid() {
        if (uid == 1) {
            store.set("uid",2);
        }
        else {
            store.set("uid",1);
        }
    }
    function getUid() {
        let u = store.get("uid");
        if (typeof u == "undefined") {
            return 1;
        }
        else {
            return u;
        }
    }
    function getPlayer() {
        p1 = store.get("p1");
        p2 = store.get("p2");
    }
    function setRound() {
        store.set("round",round+1);    
    }
    function getRound() {
        let u = store.get("round");
        if (typeof u == "undefined") {
            return 1;
        }
        else {
            return u;
        }
    }
    loadHistory();
    function loadHistory() {
        for (round = 1; round < 20; round++) {
            let word = getWord(round);
            let u = getUrls(round);
            if(typeof word == "undefined" || typeof u == "undefined") {
                break;
            }
            
            let urls = u.split(" ");
            $("#historyBody").append(
                "<tr>" +
                "<td>" + word + "</td>" +
                "<td>" + "<img src=\"" + urls[0] + "\" class=\"img-fluid tableImage \" alt=\"Responsive image\">" + "</td>" +
                "<td>" + "<img src=\"" + urls[1] + "\" class=\"img-fluid tableImage\" alt=\"Responsive image\">" + "</td>" +
                "<td>" + "<img src=\"" + urls[2] + "\" class=\"img-fluid tableImage\" alt=\"Responsive image\">" + "</td>" +
                "</tr>"
            );
            

        }
    }
    restart.on( "click", function() {
        store.clearAll();
        window.location.replace("welcome.html");
    });

    let score1 = getScore(1);
    let score2 = getScore(2);
    $("#scoreBody").append(
        "<tr>" +
            "<td>" + score1 + "</td>" +
            "<td>" + score2 + "</td>" +
        "</tr>"
    );

    function appendGuess() {
        $("#guess-area").append('<form>' + 
        
        '<div class="form-group" id = "gifs-form">' + 
        "<img src=\"" + images_chosen.shift() + "\" class=\"img-fluid\" alt=\"Responsive image\">"+
        '</div>' +
        '<div class="form-group" id = "guess-form">' + 
            '<input autocomplete="off" type="text" class="form-control" id="guess-text" placeholder="What is the hidden word?">' +
        '</div>' +
        '<button id="guess-button" data-trigger="hover" data-content="Something" type="button" class="btn btn-primary btn-submit">' +
            'Guess!' +
        '</button>' +
        '</form>');

        //Type guess word and click on guess button. Calls isSameWord(). 
        $("#guess-button").on("click", function (){
            let guess = $("#guess-text").val();
            console.log("hidden word is:", hidden_text);
            console.log("guess word is: ",guess);
            let correct = isSameWord(hidden_text, guess);
            console.log("guess button was clicked");
            if (correct == 1){
                alert("you guessed right!");
                setUid();
                uid = getUid();
                setScore(uid,getScore(uid)+ 1);
                
                window.location.reload();
            }
            else {
                if (turn == 3) {
                   setUid();
                   alert("you lost this round :(");
 
                   window.location.reload();
                   console.log(turn);
                   return;

                }
                alert("you guessed wrong :(");
                $("#gifs-form").append("<img src=\"" + images_chosen.shift() + "\" class=\"img-fluid\" alt=\"Responsive image\">");
                turn++;
            }
        
        });
    }
});

function parser(text) {
    let split = text.trim().split(/\s+/);
    let append = "";
    $.each(split, function( index, value ) {
        console.log( index + ": " + value );
        append = append + "<a tabindex=\"0\" role=\"button\"  class=\"btn btn-outline-primary gif-popover\">" + value + "</a>";
    });
    return append;
}

function isSameWord(hidden_word_list, guess_word) {
    if (hidden_text == guess_word.toLowerCase()){
        return true;
    }
    return false;
}

function splitText(list) {
    let split_text = list.split(" | ");
    $.each(split_text,function(index, value) {
        hidden_text_list.push(value);
        console.log(value);
    });
}
Array.prototype.remove = function() {
    var what, a = arguments, L = a.length, ax;
    while (L && this.length) {
        what = a[--L];
        while ((ax = this.indexOf(what)) !== -1) {
            this.splice(ax, 1);
        }
    }
    return this;
};
