if (top.location != self.location){
    top.location.href = self.location.href;
}

$('img').addClass('img-responsive');
$('table').addClass('table table-striped table-bordered');

$('#search_btn').click(function(){
    s = $('#search-s').val();
    if(s != '') {
        location.href = "https://kiswo.com/?s=" + s;
    }
});

/**
$(".money-like .reward-button").hover(function(){
    $(".money-code").fadeIn();
    $(this).addClass("active");
},function(){
    $(".money-code").fadeOut();
    $(this).removeClass("active");
},800);
*/