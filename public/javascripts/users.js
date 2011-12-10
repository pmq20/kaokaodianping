var Users = {
  follow : function(el, id, small){
    if(!logined){
      userLogin();
      return false;
    }
    App.loading();
    $(el).attr("onclick", "return false;");
    $.get("/users/"+id+"/follow",{}, function(res){
        $(el).replaceWith('<a href="#" class="flat_button '+small+'" onclick="return Users.unfollow(this, \''+ id +'\',\''+small+'\');">取消关注</a>');
        App.loading(false);
    });
    return false;
  },
  unfollow : function(el, id, small){
    if(!logined){
      userLogin();
      return false;
    }
    App.loading();
    $(el).attr("onclick", "return false;");
    $.get("/users/"+id+"/unfollow",{}, function(res){
        $(el).replaceWith('<a href="#" class="green_button '+small+'" onclick="return Users.follow(this, \''+ id +'\',\''+small+'\');">关注</a>');
        App.loading(false);
    });
    return false;
  },

  /* 不感兴趣推荐的用户或话题 */
  mute_suggest_item : function(el, type, id){
    $(el).parent().parent().fadeOut("fast");
    $.get("/mute_suggest_item", { type : type, id : id },function(res){
        App.requireUser(res);
    });
    return false;
  },

  varsion : function(){},
  
  // 隐藏或展开个人经历 add 2011-9-23 by lesanc.li
  toggleBio : function(){
	var bio = $('.user_profile .detail .bio');
	if (bio.height() > 120){
		bio.find('#user_bio').css({'height':'100px', 'width':'500px', 'display':'block', 'overflow':'hidden', 'word-break':'break-all'});
		bio.find('#user_bio').after('<div><a href="#" id="bioMore">展开</a></div>');
		$('#bioMore').css({'text-decoration':'underline', 'font-size':'12px', 'color':'#999999'});
	}
  },
  
  bioToggleMore : function(el){
	$(el).toggle(function(){
	  $('.user_profile .detail .bio #user_bio').css({'height':''});
	  $('#bioMore').html('收起');
	}, function(){
	  $('.user_profile .detail .bio #user_bio').css({'height':'100px'});
	  $('#bioMore').html('展开');
    });
  }
}

$(document).ready(function(){
  Users.toggleBio();
	Users.bioToggleMore($('#bioMore'));
});