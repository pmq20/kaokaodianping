// Like Rails DataHelper
var DateHelper = {
  timeAgoInWords: function(from) {
   return this.distanceOfTimeInWords(new Date().getTime(), from);
  },

  distanceOfTimeInWords: function(to, from) {
    seconds_ago = ((to  - from) / 1000);
    minutes_ago = Math.floor(seconds_ago / 60)

    if(minutes_ago == 0) { return "不到一分钟";}
    if(minutes_ago == 1) { return "一分钟";}
    if(minutes_ago < 45) { return minutes_ago + "分钟";}
    if(minutes_ago < 90) { return "大约一小时";}
    hours_ago  = Math.round(minutes_ago / 60);
    if(minutes_ago < 1440) { return hours_ago + "小时";}
    if(minutes_ago < 2880) { return "一天";}
    days_ago  = Math.round(minutes_ago / 1440);
    if(minutes_ago < 43200) { return days_ago + "天";}
    if(minutes_ago < 86400) { return "大约一月";}
    months_ago  = Math.round(minutes_ago / 43200);
    if(minutes_ago < 525960) { return months_ago + "月";}
    if(minutes_ago < 1051920) { return "大约一年";}
    years_ago  = Math.round(minutes_ago / 525960);
    return "超过" + years_ago + "年"
  }
}

var App = {
  
  // 显示进度条
  loading : function(show){
    var loadingPanel = $("#loading");
    if(show == false){
      loadingPanel.hide();
    }
    else{      
      loadingPanel.show();
    }
  },

  alert : function(msg){
    html = '<div class="alert_message">';
    html += msg;
    html += '</div>';
    $(".notice_message").remove();
    $(".alert_message").remove();
    $("#main .left_wrapper").prepend(html);
    return true;
  },

  notice : function(msg){
    html = '<div class="notice_message">';
    html += msg;
    html += '</div>';
    $(".notice_message").remove();
    $(".alert_message").remove();
    $("#main .left_wrapper").prepend(html);
    return true;
  },

  /*
   * 检查 Ajax 返回结果的登陆状态，如果是未登陆，就转向登陆页面
   * 此处要配合 ApplicationController 里面的 require_user 使用
   */
  requireUser : function(result, type){
    type = type.toLowerCase();
    if(type == "json"){
      if(result.success == false){
        location.href = "/login_to_zhaopin?redirect_path=" + encodeURIComponent(window.location.pathname);
        return false;
      }
    }
    else{
      if(result == "_nologin_"){
        location.href = "/login_to_zhaopin?redirect_path=" + encodeURIComponent(window.location.pathname);
        return false;
      }
    }
    return true;
  },

  inPlaceEdit : function(el, editor_options){
    var link = $(el);
    var linkId = link.attr("id");
    var textId = link.attr("data-text-id");
    var remote_url = link.attr("data-url");
    var editType = link.attr("data-type");
    var editRich = link.attr("data-rich");
    var editWidth = link.attr("data-width");
    var editHeight = link.attr("data-height");

    textPanel = $("#"+textId);
    link.parent().hide();

    sizeStyle = ""
    if(editWidth != undefined){
      sizeStyle += "width:"+editWidth+"px;"
    }
    if(editHeight != undefined){
      sizeStyle += "height:"+editHeight+"px;"
    }

    editHtml = '<input type="text" class="main_edit" name="value" style="'+sizeStyle+'" />';
    if (linkId.indexOf('user__tagline') > -1){  //add 2011-9-30 by lesanc.li
	  	editHtml = '<input type="text" maxlength="40" class="main_edit" name="value" style="'+sizeStyle+'" />';
	  }
    if(editType == "textarea"){
      editHtml = '<textarea name="value" style="'+sizeStyle+'"></textarea>';
      if (linkId.indexOf('topic__summary') > -1){  //add 2011-9-30 by lesanc.li
        editHtml += '<div class="limitwords">最多输入100个汉字。</div><br />';
      } else if (linkId.indexOf('ask__title') > -1){  //add 2011-11-3 by lesanc.li
        editHtml += '<div class="limitwords" style="margin:5px;">最多输入200个汉字。</div><br />';
      }
    }
    
    var csrf_token = $('meta[name=csrf-token]').attr('content'),
        csrf_param = $('meta[name=csrf-param]').attr('content');

    editPanel = $('<form action="'+remote_url+'" method="post" id="ipe_'+linkId+'" \
        data-text-id="'+textId+'" data-id="'+linkId+'" class="in_place_editing">\
                  <input type="hidden" name="id" value="'+linkId+'" /> \
                  <input type="hidden" name="'+csrf_param+'" value="'+csrf_token+'" /> \
                  '+ editHtml +' \
                  <button type="submit" class="small">保存</button>\
                  <a href="#" class="cancel">取消</a>\
                </form>');
    link.parent().after(editPanel);

	//add 2011-9-29 by lesanc.li
    if (linkId.indexOf('topic__summary') > -1 && editType == "textarea"){
      var timeId = setInterval(function(){
          if ($('.qeditor_preview').text()){
            if ($('.qeditor_preview').text().length > 100){
             $('.limitwords', editPanel).html('<span style="color:red">已超过' + ($('.qeditor_preview').text().length - 100) + '字</span>');
            }else{
             $('.limitwords', editPanel).html('还可以输入' + (100 - $('.qeditor_preview').text().length) + '字');
            }
          }
      }, 500);
      editPanel.keypress(function(event){
          event = event || window.event;
        var _etext = $('.qeditor_preview', editPanel).text();
        if (_etext.length >= 100 && $(event.target).attr('class') == 'qeditor_preview' && event.keyCode != 8){
          return false;
        }
      });

      editPanel.bind("paste", function(e){
        setTimeout(function(){
          var editPre = $('.qeditor_preview', editPanel);
          editPre.html($.trim(editPre.text().replace(/\s+/g, " ")));
          setTimeout(function(){
            if (editPre.text().length > 100){
              $('.limitwords', editPanel).html('<span style="color:red">已超过' + (editPre.text().length - 100) + '字</span>');
            } else {
              $('.limitwords', editPanel).html('还可以输入' + (100 - editPre.text().length) + '字');
            }
          }, 500);
        }, 500);
      });
    }

    //add 2011-11-3 by lesanc.li
    if (linkId.indexOf('ask__title') > -1 && editType == "textarea"){
      var txtArea =  $('textarea', editPanel);
      txtArea.bind("blur", function(){clearInterval(timeId);});
      var timeId2 = setInterval(function(){
        if (txtArea.val().length > 200){
         txtArea.next('.limitwords').html('<span style="color:red">已超过' + (txtArea.val().length - 200) + '字</span>');
        }else{
         txtArea.next('.limitwords').html('还可以输入' + (200 - txtArea.val().length) + '字');
        }
      }, 500);
      txtArea.keypress(function(event){
        event = event || window.event;
        if (txtArea.val().length >= 200 && event.keyCode != 8){
          return false;
        }
      });

      txtArea.bind("paste", function(e){
        setTimeout(function(){
          if (txtArea.val().length > 200){
            txtArea.next('.limitwords').html('<span style="color:red">已超过' + (txtArea.val().length - 200) + '字</span>');
          } else {
            txtArea.next('.limitwords').html('还可以输入' + (200 - txtArea.val().length) + '字');
          }
        }, 500);
      });
    }

    if(editType == "textarea"){
			var _html = textPanel.html();
			if (editor_options["is_mobile_device"]) {
				_html = _html.replace(/<br>/ig, "\n").replace(/<\/p>/ig, "\n").replace(/<div>/ig, "\n").replace(/<[^>]+>/ig, "");
			}
      $("textarea",editPanel).val(_html);
    }
    else{
      $("input.main_edit",editPanel).val(textPanel.text());
    }
    
    if(editRich == "true"){
      $("textarea",editPanel).qeditor(editor_options);
    }

    $("a.cancel",editPanel).click(function(){
        linkId = $(this).parent().attr("data-id");
        editPanel = $("#ipe_"+linkId);
        editPanel.prev().show();
        editPanel.remove();
        return false;
    });

    editPanel.submit(function(){
      //add 2011-9-30 by lesanc.li
      if (linkId.indexOf('topic__summary') > -1 && editType == "textarea" && $('#ipe_'+linkId+' .qeditor_preview').text() && $('#ipe_'+linkId+' .qeditor_preview').text().length > 100){ 
	  	  return false;
	    }
      if (linkId.indexOf('user__tagline') > -1 && $('#ipe_'+linkId+' .main_edit').val() && $('#ipe_'+linkId+' .main_edit').val().length > 40){
	  	  return false;
	    }
      //add 2011-11-3 by lesanc.li
      if (linkId.indexOf('ask__title') > -1 && $('textarea', editPanel).val().length > 200){
	  	  return false;
	    }
      //add 2011-11-11 by lesanc.li
      if (linkId.indexOf('ask__body') > -1 && $('textarea', editPanel).val().length > 3000){
	  	  return false;
	    }

      if (timeId){
        clearTimeout(timeId);
      }

      if (timeId2){
        clearTimeout(timeId2);
      }

	  editPanel = $(this);
      App.loading();
      $.ajax({
        url : remote_url,
        data : editPanel.serialize(),
        dataType : "text",
        type : "post",
        success : function(res){
          if(res == "_nologin_"){
            App.requireUser(res,"text");
            return;
          }
          $("#"+editPanel.attr("data-text-id")).html(res);
          $("a.cancel",editPanel).click();
          App.loading(false);
        }
      });
      return false;
    });
  },

  hideNotice : function(id){
    $("#sys_notice").fadeOut('fast');
    $.cookie("hide_notice",id, { expires : 300 });
    return false;
  },

  /**
   * Get Rails CSRF key and value
   * result:
   * { key : "", value : "" }
   */
  getCSRF : function(){
    key = $("meta[name=csrf-param]").attr("content");
    value = $("meta[name=csrf-token]").attr("content");
    return { key : key, value : value };
  },

  /**
   * 文本框帮顶自动搜索用户功能
   * input  搜索框
   * callback 回调函数
   */
  completeUser : function(input,callback){
    input.autocomplete("/search/users", {
      mincChars: 1,
      delay: 50,
      width: 206,
      scroll : false,
      formatItem : function(data, i, total){
        return Asks.completeLineUser(data,false);
      }
    });
    input.result(function(e,data,formatted){
      if(data){
        user_id = data[1];
        name = data[0];
        callback(name, user_id);
      }
    });
  },

  //add 2011-11-8 by lesanc.li
  inputLimit: function(el, n, vtype){
    var editPanel = $(el).parents("form");
    vtype = vtype || "val";
    var elLen = 0;
    if(!$(el).next('.limitwords').length)$(el).after("<div class=\"limitwords\"></div>");
    $(el).bind("blur", function(){clearInterval(timeId);});
    var timeId = setInterval(function(){
      elLen = (vtype == "val")?$(el).val().length:$(el).text().length;
      if (elLen > n){
        $(el).next('.limitwords').html('<span style="color:red">已超过' + (elLen - n) + '字</span>');
      }else{
        $(el).next('.limitwords').html('还可以输入' + (n - elLen) + '字');
      }
    }, 500);
    $(el).bind("keypress", function(event){
      event = event || window.event;
      elLen = (vtype == "val")?$(el).val().length:$(el).text().length;
      if (elLen >= n && event.keyCode != 8){
        return false;
      }
    });
    $(el).bind("paste", function(e){
      setTimeout(function(){
        if (vtype == "val"){
          $(el).val($.trim($(el).val().replace(/\s+/g, " ")).substring(0, n));
        } else {
          $(el).html($.trim($(el).text().replace(/\s+/g, " ")).substring(0, n));
        }
        setTimeout(function(){
          elLen = (vtype == "val")?$(el).val().length:$(el).text().length;
          if (elLen > n){
            $(el).next('.limitwords').html('<span style="color:red">已超过' + (elLen - n) + '字</span>');
          } else {
            $(el).next('.limitwords').html('还可以输入' + (n - elLen) + '字');
          }
        }, 500);
      }, 500);
    });
    editPanel.bind("submit", function(){
      elLen = (vtype == "val")?$(el).val().length:$(el).text().length;
      if (elLen > n){return false;}
    });
  },
  // 输入框默认提示 add 2011-11-8 by lesanc.li
  placeHolder : function(el, tips){
    $(el).bind("focus", function(){
      if($(this).val() == tips){
        $(this).val("").css("color","#000000");
      }
    }).bind("blur", function(){
      if($.trim($(this).val()) == "" || $(this).val() == tips){
        $(this).val(tips).css("color","#999999");
      }
    }).trigger("blur");
  },

  varsion : function(){
    return "1.0";
  }
}

function show_all_answer_body(log_id, answer_id) {
	$('#aws_' + log_id + '_' + answer_id).addClass("force-hide");
	$('#awb_' + log_id + '_' + answer_id).addClass("force-show");
	return false;
}

function mark_notifies_as_read(el, ids) {
	App.loading();
	$.get("/mark_notifies_as_read?ids="+ids,function(){
		App.loading(false);
		$(el).parent().parent().fadeOut();
	});
	$("#notify_badge").addClass("force-hide");
	return false;
}

function expand_notification(el, type, id) {
	var items = $("#N" + type + "_" + id + "_items");
	
	if (items.hasClass("force-show")) {
		items.removeClass("force-show");
	} else {
		items.addClass("force-show");
	}
	return false;
}
