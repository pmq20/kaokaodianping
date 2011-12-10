var Asks = {
  mute : function(el,id){
    App.loading();
    $.get("/asks/"+id+"/mute",{}, function(res){
        App.loading(false);
        if(!App.requireUser(res,"text")){
          return false;
        }
        // $(el).replaceWith('<span class="muted">不再显示</span>');
				$(el).parent().parent().fadeOut("fast");
    });
    return false;
  },

	unmute : function(el,id){
    App.loading();
    $.get("/asks/"+id+"/unmute",{}, function(res){
        App.loading(false);
        if(!App.requireUser(res,"text")){
          return false;
        }
        // $(el).replaceWith('<span class="muted">不再显示</span>');
				$(el).parent().parent().fadeOut("fast");
    });
    return false;
  },

	simple_follow : function(el,id){
    App.loading();
    $.get("/asks/"+id+"/follow",{}, function(res){
        App.loading(false);
        if(!App.requireUser(res,"text")){
          return false;
        }
        $(el).replaceWith('<a onclick="return Asks.simple_unfollow(this,\''+id+'\')" href="#">取消关注</a>'); //20111121 by lesanc.li
				// $(el).parent().parent().fadeOut("slow");
    });
    return false;
  },

	simple_unfollow : function(el,id){
    App.loading();
    $.get("/asks/"+id+"/unfollow",{}, function(res){
        App.loading(false);
        if(!App.requireUser(res,"text")){
          return false;
        }
		 $(el).replaceWith('<a onclick="return Asks.simple_follow(this,\'' + id + '\')" href="#">关注</a>'); //modify 2011-9-29 by lesanc.li
		//		$(el).parent().parent().fadeOut("fast");
    });
    return false;
  },

  dropdown_menu : function(el){
    html = '<ul class="menu">';
    if(ask_redirected == true){
      html += '<li><a onclick="return Asks.redirect_ask_cancel(this);" href="#">取消重定向</a></li>';
    }
    else{
      html += '<li><a onclick="return Asks.redirect_ask(this);" href="#">问题重定向</a></li>';
    }
    html += '<li><a onclick="return Asks.report(this);" href="#">举报</a></li>';
    $(el).jDialog({
      title_visiable : false,
      width : 160,
      class_name : "dropdown_menu",
      top_offset : -2,
      content : html
    });
    $(el).attr("droped",1);
    return false;
  },

  redirect_ask : function(el){
    if(!logined){  //add 2011-10-14 by lesanc.li
      userLogin();
      return false;
    }
    jDialog.close();
    $.facebox({ div : "#redirect_ask", overlay : false });
    $(".facebox_window.simple_form input.search").autocomplete("/search/asks",{
      minChars: 1,
      delay: 50,
      width: 456,
      scroll : false,
      addSearch: false
    });
    $(".facebox_window.simple_form input.search").result(function(e,data,formatted){
      if(data){
        $(".facebox_window.simple_form .r_id").val(data[1]);
        $(".facebox_window.simple_form .r_title").val(data[0]);
      }
    });
  },

  redirect_ask_save : function(el){
    App.loading();
    r_id = $(".facebox_window.simple_form .r_id").val();
    r_title = $(".facebox_window.simple_form input.r_title").val();
    if(r_id.length == ""){
      $(".facebox_window.simple_form input.search").focus();
    }
    $.get("/asks/"+ask_id+"/redirect",{ new_id : r_id }, function(res){
        App.loading(false);
        if(res == "1"){
          ask_redirected = true;
          Asks.redirected_tip(r_title,r_id, 'nr', ask_id );
          $.facebox.close();
        }
        else{
          alert("循环重定向，不允许这么关联。");
          return false;
        }
    });
    return false;
  },

  redirect_ask_cancel : function(el){
    $.get("/asks/"+ask_id+"/redirect",{ cancel : 1 });
    Asks.redirected_tip();
    ask_redirected = false;
    jDialog.close();
  },

  redirected_tip : function(title, id, type, rf_id){
    if(title == undefined){
      $("#redirected_tip").remove();
    }
    else{
      label_text = "问题已重定向到: "
      ask_link = "/asks/" + id + "?nr=1&rf=" + rf_id;
      if(type == "rf"){
        label_text = "重定向来自: ";
        ask_link = "/asks/" + id + "?nr=1";
      }
      html = '<div id="redirected_tip"><div class="container">';
      html += '<label>'+label_text+'</label><a href="'+ask_link+'">'+title+'</a>';
      html += '</div></div>';
      $("#main").before(html);
    }
  },

  /* 问题，话题，人搜索自动完成 */
  completeAll : function(el){
    input = $(el);
    input.autocomplete("/search/all",{
      mincChars: 1,
      delay: 50,
      width: 478,
      scroll : false,
      selectFirst : false,
      clickFire : true,
      hideOnNoResult : true,
      formatItem : function(data, i, total){
        klass = data[data.length - 1];
        switch(klass){
          case "Ask":
            return Asks.completeLineAsk(data, true);
            break;
          case "Topic":
            return Asks.completeLineTopic(data, true);
            break;
          case "User":
            return Asks.completeLineUser(data, true);
            break;
          default:
            return "";
            break;
        }
      }
    }).result(function(e, data, formatted){
        url = "/";
        klass = data[data.length - 1];
        switch(klass){
          case "Ask":
            url = "/asks/" + data[1];
            break;
          case "Topic":
            url = "/topics/" + data[0];
            break;
          case "User":
            url = "/users/" + data[4];
            break;
        }
        location.href = url;
        return false;
      });
  },

  completeTopic : function(el){
    $(el).autocomplete("/search/topics",{
      minChars: 1,
      delay: 50,
      width: 200,
      scroll : false,
      defaultHTML : (el.attr("id")=="searchTopic")?"":"输入文本开始搜索",
      addSearch : (el.attr("id")=="searchTopic")?false:true,
      formatItem : function(data, i, total){
        return Asks.completeLineTopic(data,false);
      }
    });
  },

  toggleShareAsk : function(el,type){ //modify 2011-11-8 by lesanc.li
    $(el).parents("#share_ask_box").find(".inner .invite").show();
		return false;
  },

  /* 邀请人回答问题 */
  completeInviteToAnswer : function(){
    input = $("#ask_to_answer");
    input.autocomplete("/search/users", {
      mincChars: 1,
      delay: 50,
      width: 206,
      scroll : false,
      defaultHTML : "输入文本开始搜索",
      noResultHTML : "未找到与“{kw}”相关的人",  // add 2011-10-19 by lesanc.li
      addSearch : false,
      formatItem : function(data, i, total){
        return Asks.completeLineUser(data,false);
      }
    });
    input.result(function(e,data,formatted){
      if(data){
        user_id = data[1];
        name = data[0];
        Asks.inviteToAnswer(data[1]);
      }
    });
  },

  /* 取消邀请 */
  cancelInviteToAnswer : function(el, id){
    var countp = $(el).parent().find(".count");
    count = parseInt(countp.text());
    if(count > 1){
      count -= 1
      countp.text(count);
    }
    else{
      $(el).parent().parent().fadeOut().remove();
    }
    $(el).before('<span class="n"></span>');
    $(el).remove();
    $.get("/asks/"+ask_id+"/invite_to_answer",{ i_id : id, drop : 1 });
    return false;
  },
  
  inviteToAnswer : function(user_id, is_drop){
    App.loading();
    $.get("/asks/"+ask_id+"/invite_to_answer.js",{ user_id : user_id, drop : is_drop }, function(data){
      /\(\'#shared_span_count\'\).html\(\' \((\d+)\)\' \)/.exec(data);    //add 2011-11-4 by lesanc.li
      if (RegExp["$1"] > 0 && $("#ask_invited_users").text().indexOf("已邀请") == -1){
        $("#ask_invited_users div").before("已邀请：<br />");
      }
    });
  },

  completeLineTopic : function(data,allow_link){
    html = "";
    cover = data[2];
    if(/http:\/\//.test(cover) == false){
      cover = "";
    }
    count = data[1];
    if(cover.length > 0){
      html += '<img class="avatar" src="'+ cover +'" />';
    }
    html += '<div class="uinfo"><p>';
    if(allow_link == true){
      html += '<a href="/topics/'+data[0]+'">'+ data[0] +'</a>';
    }
    else{
      html += '<span class="name">'+data[0]+'</span>';
    }
    html += '<span class="scate">话题</span>';
    html += '</p>';
    html += '<p class="count">'+count+' 个关注者</p></div>';
    return html;
  },

  completeLineAsk : function(data, allow_link){
    if(allow_link == false){
      return data[0]
    }
    
    html = "";
    if(data[2] != null){
      topics = data[2].split(",")
      if(topics.length > 0){
        html += '<span class="cate">'+topics[0]+'</span>';
      }
    }
    html += '<a href="/asks/'+data[1]+'">'+data[0].replace("/","")+'</a>';
    return html;
  },

  completeLineUser : function(data,allow_link){
    html = "";
    avatar = data[3];
    if(/http:\/\//.test(avatar) == false){
      avatar = "/images/" + avatar;
    }
    tagline = data[2];
    html += '<img class="avatar" src="'+ avatar +'" />';
    html += '<div class="uinfo"><p>';
    if(allow_link == true){
      html += '<a href="/users/'+data[5]+'">'+data[0]+'</a>';
    }
    else{
      html += '<span class="name">'+data[0]+'</span>';
    }
    html += '</p>';
    html += '<p class="tagline">'+tagline+'</p></div>';
    return html;
  },



  beforeSubmitComment : function(el){
    App.loading();
  },

  thankAnswer : function(el,id){
    if(!logined){  //add 2011-10-14 by lesanc.li
      userLogin();
      return false;
    }
    klasses = $(el).attr("class");
    if(klasses.indexOf("thanked") > 0){
      return false;
    }
    $(el).addClass("thanked");
    $(el).text("已感谢");
    $(el).click(function(){ return false });
    $.get("/answers/"+id+"/thank");
    return false;
  },

  spamAsk : function(el, id){
    if(!logined){  //add 2011-10-14 by lesanc.li
      userLogin();
      return false;
    }
    if(!confirm("多人评价为烂问题后，此问题将会被屏蔽，而且无法撤销！\n你确定要这么评价吗？")){
      return false;
    }

    App.loading();
    $(el).addClass("spamed");
    $.get("/asks/"+id+"/spam",function(count){
      if(!App.requireUser(count,"text")){
        return false;
      }
      $("#spams_count").text(count);
      App.loading(false);
    });
    return false;
  },

  beforeAnswer : function(el){
    $("button.submit",el).attr("disabled","disabled");
    App.loading();
  },

  spamAnswer : function(el, id){
    if(!logined){  //add 2011-10-14 by lesanc.li
      userLogin();
      return false;
    }
    App.loading();
    $(el).addClass("spamed");
    $(el).text("已提交");
    $.get("/answers/"+id+"/spam",function(count){
      if(!App.requireUser(count,"text")){
        return false;
      }
      App.loading(false);
    });
    return false;
  },

  toggleEditTopics : function(isShow){
    if(isShow){
      $(".ask .edit_topics").show();
      $(".ask .item_list").hide();
      App.placeHolder($("#searchTopic"),"输入话题");
    }
    else{
      $(".ask .item_list").show();
      $(".ask .edit_topics").hide();
    }
  },

  beforeAddTopic : function(el){
    App.loading();
  },

  addTopic : function(name){
    App.loading(false);
    if((name.trim && name.trim() == "") || typeof name == "undefined" || name == ""){ //modify 2011-9-26 by lesanc.li
      return false;
    }
    $(".ask .topics .item_list .in_place_edit").before("<a href='/topics/"+name+"' class='topic'>"+name+"</a>");
    $(".ask .topics .item_list .no_result").remove();
    exit_topic_count = $(".ask .edit_topics .items .topic").length;
    $(".ask .edit_topics .items").append('<div class="topic"> \
          <span>'+name+'</span>\
          <a href="#" onclick="Asks.removeTopic(this,'+(exit_topic_count+1)+',\''+name+'\');" class="remove"></a>\
        </div>');
  },

  removeTopic : function(el, idx, name){
    App.loading();
	  var val = $(el).parent().find('span').html(); //add 2011-9-22 by lesanc.li
    $.get("/asks/"+ask_id+"/update_topic", { name : name }, function(res){
      $(el).parent().remove();
      //$(".ask .topics .item_list .topic:nth-of-type("+(idx+1)+")").remove();
	    $(".ask .topics .item_list .topic").each(function(){ //add 2011-9-22 by lesanc.li
	      if($(this).html() == val){$(this).remove();} 
	    });
      if ($(".ask .edit_topics .items .topic").length == 0 && $("#ask_suggest_topics").length == 0 && $("#suggestTopics").length > 0){ //add 2011-10-27 by lesanc.li
        eval('var topics = '+$("#suggestTopics").text()+'');  
        Asks.showSuggestTopics(topics); 
      }

      App.loading(false);
    });
    return false;
  },

  follow : function(el){
    if(!logined){  //add 2011-11-8 by lesanc.li
      userLogin();
      return false;
    }
    App.loading();
    $(el).attr("onclick", "return false;");
    $.get("/asks/"+ask_id+"/follow",{}, function(res){
      App.loading(false);
      $(el).replaceWith('<a href="#" style="width:80px;" class="flat_button" onclick="return Asks.unfollow(this);">取消关注</a>');
    });
    return false;
  },

  unfollow : function(el){
    if(!logined){  //add 2011-11-8 by lesanc.li
      userLogin();
      return false;
    }
    App.loading();
    $(el).attr("onclick", "return false;");
    $.get("/asks/"+ask_id+"/unfollow",{}, function(res){
      App.loading(false);
      $(el).replaceWith('<a href="#" style="width:80px;" class="gray_button green_button" onclick="return Asks.follow(this);">关注此问题</a>');
    });
    return false;
  },

  toggleComments : function(type, id){
    if(!logined){  //add 2011-10-14 by lesanc.li
      userLogin();
      return false;
    }
    var el = $("#"+type+"_"+id);
    var comments = $(".comments",el);
    if(comments.length > 0){
      comments.toggle();
    }
    else{
      App.loading();
      $.ajax({url:"/comments",data:{ type : type, id : id }, success:function(html){
        $(".action",el).after(html);
        App.loading(false);
      }, dataType:"text"});
    }
    return false;
  },

  vote : function(id, type){
    if(!logined){  //add 2011-10-14 by lesanc.li
      userLogin();
      return false;
    }
    var answer = $("#answer_"+id);
    var vtype = "down";
    if(type == 1) {  //modify  2011-11-8 by lesanc.li
      vtype = "up";
      $(".vote_buttons a.vote_up",answer).attr("class", "voted_up");
      $(".vote_buttons a.voted_down",answer).attr("class", "vote_down");
    } else {
      $(".vote_buttons a.voted_up",answer).attr("class", "vote_up");
      $(".vote_buttons a.vote_down",answer).attr("class", "voted_down");
    }
    $(".action a",answer).removeClass("voted");
    $(".action a.vote_"+vtype,answer).addClass("voted");
    App.loading();
    $.get("/answers/"+id+"/vote",{ inc : type },function(res){
      res = res.replace("'","");
      if(!App.requireUser(res,"text")){
        return false;
      }
      res_a = res.split("|");
      Asks.vote_callback(id, vtype, res_a[0], res_a[1],res_a[2]);
      App.loading(false);
    });
    return false;
  },

  vote_callback : function(id, vtype, new_up_count, new_down_count,new_who){
    var answer = $("#answer_"+id);
    var answer_votes = $(".votes",answer);
    answer.attr("data-uc", new_up_count);
    answer.attr("data-dc", new_down_count);
    // add 2011-10-24 by lesanc.li
    $(".vote_buttons", answer).html($(".vote_buttons", answer).html().replace(/赞 成\(\d+\)/,"赞 成("+new_up_count+")").replace(/反 对\(\d+\)/,"反 对("+new_down_count+")"));
 
    /* Change value for visable label */
    if(answer_votes.length > 0){
      if(new_up_count <= 0){
        /* remove up vote count label if up_votes_count is zero */
        $(answer_votes).remove();
      }
      else{
        $(".num",answer_votes).text(new_up_count);
		$(".voters",answer_votes).html(new_who.replace('/<span class="voters">(.*?)</span>/i', '$1')); //add 2011-09-29 by lesanc.li
      }
    }
    else {
      if(vtype == "up"){
        $(".author",answer).after("<div class=\"votes\"><span class=\"num\">"+new_up_count+"</span>票"+'，来自'+new_who+'</div>'); //modify 2011-09-29 by lesanc.li
      }
    }

    var answers = $(".answer");
    var position_changed = false;

    for(var i =0;i<answers.length;i++){
      a = answers[i];
      /* Skip current voted Answer self */
      if($(a).attr("id") == answer.attr("id")){
        continue;
      }
      /* Get next Answer uc and dc */
      u_count = parseInt($(a).attr("data-uc"));
      d_count = parseInt($(a).attr("data-dc"));

      /* Change the Ask position */
      if(vtype == "up"){
        if(new_up_count > u_count){
          $(a).before(answer);
          position_changed = true;
          break;
        }
      }
      else{
        /* down vote */
        if(new_up_count <= u_count && new_down_count < d_count){
          $(a).after(answer);
          position_changed = true;
          break;
        }
      }
    }
    answer.fadeOut(100).fadeIn(200);
  },

  report : function(){
    if(!logined){  //add 2011-10-14 by lesanc.li
      userLogin();
      return false;
    }
    $.facebox({ div : "#report_page", overlay : false });
    jDialog.close();
    return false;
  },

  showSuggestTopics : function(topics){
    html = '<div id="ask_suggest_topics" class="ask"><div class="container"><label>根据您的问题，我们推荐这些话题(点击添加):</label>';
    for(var i=0;i<topics.length;i++) {
      html += '<a href="#" class="topic nofloat" onclick="return Asks.addSuggestTopic(this,\''+topics[i]+'\');">'+topics[i]+'</a>';
    }
    html += '<a class="silver_button silver_button_small" href="#" onclick="return Asks.closeSuggestTopics();">完成</a>'; //modify 2011-9-29 by lesanc.li
    html += "</div></div>";
html='';// ticket 509
    $("#main").before(html);
  },

  addSuggestTopic : function(el,name){
    App.loading();
    $.ajax({
      //url : "/asks/"+ask_id+"/update_topic.js?"+ csrf.key + "=" + csrf.value,
	  url : "/asks/"+ask_id+"/update_topic.js",  //add 2011-9-26 by lesanc.li
      data : {
        name : name,
        add : 1
      },
      dataType : "text",
      type : "post",
      success : function(res){
        App.loading(false);
        Asks.addTopic(name); 
        $(el).remove();
        if($("#ask_suggest_topics a.topic").length == 0){
          $("#ask_suggest_topics").remove();
        }
      }
    });
    return false;
  },
  
  closeSuggestTopics : function(){
    $("#ask_suggest_topics").fadeOut("fast",function(){ $(this).remove(); });
    return false;
  },
  
  // limit input    add 2011-9-29 by lesanc.li
  //limitWord : function(el, nums){
	//$(el).keypress(function(event){
      //if($(el).val() > 200){return false;}
	//});
  //},

  shortDetail : function(){
    $(".ask[class='ask']>.md_body").each(function(){
      var mdHtml = $(this).html();
      var mdText = $.trim($(this).text());
      if(mdText.length > 270){
        var mdSpan = $(document.createElement("span"));
        $(this).html(mdSpan.html(mdText.substring(0,270)+"。。。 "));
        var mdLink = $(document.createElement("a"));
        mdLink.text("展开").attr("href","#").css({"background":"","padding":"0"}).appendTo($(this));
        mdLink.toggle(function(){
          mdSpan.html(mdHtml);
          mdLink.text("收起");
        },function(){
          mdSpan.html(mdText.substring(0,270)+"。。。 ");
          mdLink.text("展开")
        });

      }
    });
  },

  version : function(){
  }

}


/* 添加问题 */
function addAsk(){      
  if(!logined){
    location.href = "/login";
    return false;
  }
  var txtTitle = $("#hidden_new_ask textarea:nth-of-type(1)");
  ask_search_text = $("#add_ask input").val();
  txtTitle.text(ask_search_text);
  txtTitle.focus();
  $.facebox({ div : "#hidden_new_ask", overlay : false });
  return false;
}




  function judgeEmail(sValue) {
    if (sValue == "") {
        writeFileErrMsg("请输入您的电子邮件地址");
        return false;
    }
    var CheckEmail = isemail_b(sValue);
    if (CheckEmail.length > 0) {
        writeFileErrMsg(CheckEmail);
        return false;
    }
    writeFileErrMsg("");
    return true;
  }

  function writeFileErrMsg(strMessage){
      $("#facebox .user_email_err").html(" "+strMessage).css("color", "red");
  }

function isemail_b(s) {
  // Writen by david, we can delete the before code
  if (s.length > 100) {
      //window.alert("email地址长度不能超过100位!");
      return "email地址长度不能超过100位!";
  }
  s = s.toLowerCase();
  var strSuffix = "cc|com|edu|gov|int|net|org|biz|info|pro|name|coop|al|dz|af|ar|ae|aw|om|az|eg|et|ie|ee|ad|ao|ai|ag|at|au|mo|bb|pg|bs|pk|py|ps|bh|pa|br|by|bm|bg|mp|bj|be|is|pr|ba|pl|bo|bz|bw|bt|bf|bi|bv|kp|gq|dk|de|tl|tp|tg|dm|do|ru|ec|er|fr|fo|pf|gf|tf|va|ph|fj|fi|cv|fk|gm|cg|cd|co|cr|gg|gd|gl|ge|cu|gp|gu|gy|kz|ht|kr|nl|an|hm|hn|ki|dj|kg|gn|gw|ca|gh|ga|kh|cz|zw|cm|qa|ky|km|ci|kw|cc|hr|ke|ck|lv|ls|la|lb|lt|lr|ly|li|re|lu|rw|ro|mg|im|mv|mt|mw|my|ml|mk|mh|mq|yt|mu|mr|us|um|as|vi|mn|ms|bd|pe|fm|mm|md|ma|mc|mz|mx|nr|np|ni|ne|ng|nu|no|nf|na|za|aq|gs|eu|pw|pn|pt|jp|se|ch|sv|ws|yu|sl|sn|cy|sc|sa|cx|st|sh|kn|lc|sm|pm|vc|lk|sk|si|sj|sz|sd|sr|sb|so|tj|tw|th|tz|to|tc|tt|tn|tv|tr|tm|tk|wf|vu|gt|ve|bn|ug|ua|uy|uz|es|eh|gr|hk|sg|nc|nz|hu|sy|jm|am|ac|ye|iq|ir|il|it|in|id|uk|vg|io|jo|vn|zm|je|td|gi|cl|cf|cn"
  var regu = "^[a-z0-9][_a-z0-9\-]*([\.][_a-z0-9\-]+)*@([a-z0-9\-\_]+[\.])+(" + strSuffix + ")$";
  var re = new RegExp(regu);
  if (s.search(re) != -1) {
      return "";
  } else {
      return "请输入有效合法的E-mail地址 ！";
  }
}

function trim(str) {
    regExp1 = /^ */;
    regExp2 = / *$/;
    return str.replace(regExp1, '').replace(regExp2, '');
}

// 搜索页 更多显示 add 2011-10-17 by lesanc.li
function loadResults(el, q, curpage){
  App.loading();
  $.get("/traverse/asks_from?q="+((encodeURIComponent)?encodeURIComponent(q):q)+"&current_key="+curpage,function(data){
    $(el).parent().before(data).remove();
    App.loading(false);
  });
  return false;
}

//图片大小检测 add 2011-11-1 by lesanc.li
function checkUploadImg(fileObj){
  var hint = fileObj.next("p.hint");
  hint.html("支持jpg, gif, png 格式的图片，不要超过2MB。建议图片尺寸大于100 X 100。");
  $("button[type='submit']").unbind("click");
  if (fileObj.val() == ""){
    return false;
  } else if(!(/(?:.jpeg|.png|.gif|.jpg)$/.test(fileObj.val()))){
    hint.html(hint.html().replace("支持jpg, gif, png 格式的图片","<span style=\"color:red\">支持jpg, gif, png 格式的图片</span>"));
    $("button[type='submit']").click(function(){return false;});
  } else if(fileObj.val().indexOf(":")>-1){
    var uploadImg = $("#uploadImg");
    if(!uploadImg.attr("src")){
      uploadImg = document.createElement("img");
      uploadImg = $(uploadImg);
      uploadImg.css({"position":"absolute", "visibility":"hidden"}).bind("readystatechange", function(){
        if(uploadImg[0].readyState!= "complete") return false;
        imgSize = uploadImg[0].fileSize;
        if (imgSize > 2048000){
          hint.html(hint.html().replace("不要超过2MB","<span style=\"color:red\">不要超过2MB</span>"));
          $("button[type='submit']").click(function(){return false;});
        }
      }).appendTo($("body"));
    }
    uploadImg.attr("src", fileObj.val());
  } else {
    var imgSize = (fileObj[0].files)?fileObj[0].files.item(0).fileSize:0;
    if (imgSize > 2048000){
      hint.html(hint.html().replace("不要超过2MB","<span style=\"color:red\">不要超过2MB</span>"));
      $("button[type='submit']").click(function(){return false;});
    }
  }
}

$(document).ready(function(){
  //个人页 对某人提问相关提示
  var strATU = $("#ask_to_user>form>.row textarea").val();
  $("#ask_to_user>form>.row textarea").bind("focus", function(){
    if(!logined){
      userLogin();
      return false;
    }
    App.inputLimit($(this), 200);
    $("#ask_to_user>form>div>div.row textarea").bind("focus", function(){
      App.inputLimit($(this), 3000);
    });
    if($(this).val() == strATU){
      $(this).val("").css("color","#000000");
    }
  }).bind("blur", function(){
    if($.trim($(this).val()) == "" || $(this).val() == strATU){
      $(this).val(strATU).css("color","#999999");
    }
  }).trigger("blur");
  $("#ask_to_user form").bind("submit", function(){
    if(!logined){
      userLogin();
      return false;
    }
    if($.trim($("#ask_to_user>form>.row textarea").val()) == "" || $("#ask_to_user>form>.row textarea").val() == strATU){
      return false;
    }
    return true;
  });
  // asks/new 用户提问前检测登录状态
  $("#new_ask").bind("submit", function(){
    if(!logined){
      userLogin();
      return false;
    }
  });
  // 问题补充字数限制
  $("#new_ask .qeditor_preview").bind("click", function(){
    App.inputLimit($(this), 3000, "text");
  });
  $("a.in_place_edit").bind("click", function(){
    $(".in_place_editing[data-text-id=\"ask_body\"] .qeditor_preview").bind("click", function(){
      App.inputLimit($(this), 3000, "text");
    });
  });
  $(".focListB li>a").each(function(){
    var el=$(this);
    el.attr("href","javascript:void(0)");
    var topicName = el.siblings("div").text();
    if (el.text() == "+关注"){
      el.bind("click",function(){
          if(!logined){
            userLogin();
            return false;
          }
          Topics.hotFollow(el, topicName)});
    } else if(el.text() == "取消关注"){
      el.bind("click",function(){
          if(!logined){
            userLogin();
            return false;
          }
          Topics.hotUnfollow(el, topicName)});
    }
  });
  // 欢迎页热门话题全部关注和取消 2011-10-12 by lesanc.li
  $(".focList").each(function(){
    var elAll = $(this);
    var folAll = $(".focListT .btnFa",elAll);
    folAll.attr("href","javascript:void(0)");
    if (folAll.text() == "关注全部"){
      folAll.bind("click",function(){
        if(!logined){
          userLogin();
          return false;
        }
        Topics.followAll(elAll);
      });
    } else if(folAll.text() == "取消关注"){
      folAll.bind("click",function(){
        if(!logined){
          userLogin();
          return false;
        }
        Topics.unfollowAll(elAll);
      });
    }   
  });
  // 个人页 鼠标经过个人图像事件
  var userImgEdit = $(".user_profile .uname .edit");
  $(".user_profile .uname .avatar img").hover(function(e){
    if (e.relatedTarget != $("a", userImgEdit)[0]) userImgEdit.show();
  },function(e){
    if (e.relatedTarget != $("a", userImgEdit)[0]){
      userImgEdit.hide();
    } else {
      userImgEdit.mouseout(function(e1){
        if (e1.relatedTarget != $(".user_profile .uname .avatar img")[0])$(this).hide();
      });
    }
  });
  //图片上传检测
  $("#facebox #user_avatar").live("change", function(){
    checkUploadImg($("#facebox #user_avatar"));
  });
  $("#user_avatar").bind("change", function(){
    checkUploadImg($(this));
  });
  //个人设置页 个人一句话描述输入框提示 2011-11-2 by lesanc.li
  if ($("#user_tagline").length){
    App.placeHolder($("#user_tagline"), "如：GRE大牛");
    $("#user_edit").bind("submit", function(){
      if($("#user_tagline").val() == "如：GRE大牛"){
        $("#user_tagline").val("");
      }
      if (/[^a-zA-Z0-9-_]+/.test($("#user_slug").val())){
        $("#user_slug")[0].focus();
        return false;
      }
    });
  }
  // 个人设置页 个性域名输入限制
  if ($("#user_slug").length){
    $("#user_slug").val($("#user_slug").val().replace(/[\. ]/g,"_"));
    $("#user_slug").bind("keydown", function(e){
      e = e || window.event;
      if (e.keyCode == 190 || e.keyCode == 110 || e.keyCode == 32){
        return false;
      }
    }).bind("blur", function(){
      if (/[^a-zA-Z0-9-_]+/.test($(this).val())){
        if ($("#user_slug_err").attr("id")){
          $("#user_slug_err").show();
        } else {
          $(this).after("&nbsp;&nbsp;<span id=\"user_slug_err\" style=\"color:red\">输入的格式不正确！</span>");
        }
      } else {
        $("#user_slug_err").hide();
      }
    });
  }
  // 所有问题、个人页问题补充描述截断
  Asks.shortDetail();
  // 问题页代码迁移至此 2011-10-14 by lesanc.li
  Asks.completeInviteToAnswer(); 
  $("#share_ask_box h2 a").facebox();
});