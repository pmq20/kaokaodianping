var Topics = {
  editCover : function(el){
    $(el).hover(function(){
      $(".edit",$(this)).show();
    }, function(){
      $(".edit",$(this)).hide();
    });
    $(".edit a",$(el)).click(function(el){
        $.facebox({ div : "#edit_topic_cover" });
        return false;
    });
  },

  follow : function(el, id,small){
    if(!logined){  //add 2011-11-8 by lesanc.li
      userLogin();
      return false;
    }
    App.loading();
    $(el).attr("onclick", "return false;");
    var uid=(encodeURIComponent)?encodeURIComponent(id):id; //add 2011-9-23 by lesanc.li modify 2011-10-8 lesanc.li
    $.get("/topics/"+uid+"/follow",{}, function(res){  //modify 2011-10-8 lesanc.li
        $(el).replaceWith('<a href="#" class="flat_button '+small+'" onclick="return Topics.unfollow(this, \''+ id +'\', \''+ small +'\');">取消关注</a>');
        App.loading(false);
    });
    return false;
  },
		
  unfollow : function(el,id,small){
    if(!logined){  //add 2011-11-8 by lesanc.li
      userLogin();
      return false;
    }
    App.loading();    
    $(el).attr("onclick", "return false;");
    var uid=(encodeURIComponent)?encodeURIComponent(id):id; //add 2011-9-23 by lesanc.li modify 2011-10-8 lesanc.li
    $.get("/topics/"+uid+"/unfollow",{}, function(res){ //modify 2011-10-8 lesanc.li
        $(el).replaceWith('<a href="#" class="gray_button green_button '+small+'" onclick="return Topics.follow(this, \''+ id +'\', \''+ small +'\');">关注本话题</a>');
        App.loading(false);
    });
    return false;
  },
  //add 2011-10-11 by lesanc.li	
  hotFollow : function(el, id){
    App.loading();
    var uid=(encodeURIComponent)?encodeURIComponent(id):id; 
    $.get("/topics/"+uid+"/follow",{}, function(res){
        $(el).siblings("div").addClass("selected");
        $(el).unbind().bind("click",function(){Topics.hotUnfollow(el, id)}).text("取消关注");
        App.loading(false);
    });
    return false;
  },
	//add 2011-10-11 by lesanc.li	
  hotUnfollow : function(el, id){
    App.loading();    
    var uid=(encodeURIComponent)?encodeURIComponent(id):id;
    $.get("/topics/"+uid+"/unfollow",{}, function(res){
        $(el).siblings("div").removeClass("selected");
        $(el).unbind().bind("click",function(){Topics.hotFollow(el, id)}).text("+关注");      
        App.loading(false);
    });
    return false;
  },

  //add 2011-10-12 by lesanc.li	
  followAll : function(el){
    var folAll = $(".focListT .btnFa",el);
    var data = [];
    $(".focListB li>a", el).each(function(){
      var id=$(this).siblings("div").text();
      $(this).siblings("div").addClass("selected");
      $(this).unbind().bind("click",function(){Topics.hotUnfollow($(this), id)}).text("取消关注");
      data.push(id);
    });
    $.post("/topics_follow",{q:data.join(",")}, function(res){
      
    });
    folAll.unbind().bind("click",function(){Topics.unfollowAll(el);}).text("取消关注");
  },
	//add 2011-10-12 by lesanc.li	
  unfollowAll : function(el){
    var folAll = $(".focListT .btnFa",el);
    var data = [];
    $(".focListB li>a", el).each(function(){
      var id=$(this).siblings("div").text();
      $(this).siblings("div").removeClass("selected");
      $(this).unbind().bind("click",function(){Topics.hotFollow($(this), id)}).text("+关注"); 
      data.push(id);
    });
    $.post("/topics_unfollow",{q:data.join(",")}, function(res){
      
    });
    folAll.unbind().bind("click",function(){Topics.followAll(el);}).text("关注全部");
  },
  
  version : function(){}
}
