(function() {
  window.Topics = {
    appendImageFromUpload: function(srcs) {
      var src, txtBox, _i, _len;
      txtBox = $(".topic_body_text_area");
      for (_i = 0, _len = srcs.length; _i < _len; _i++) {
        src = srcs[_i];
        txtBox.val("" + (txtBox.val()) + "[img]" + src + "[/img]\n");
      }
      txtBox.focus();
      return $("#add_image").jDialog.close();
    },
    addImageClick: function() {
      var opts;
      opts = {
        title: "插入图片",
        width: 350,
        height: 145,
        content: '<iframe src="/bbs/photos/tiny_new" frameborder="0" style="width:330px; height:145px;"></iframe>',
        close_on_body_click: false
      };
      $("#add_image").jDialog(opts);
      return false;
    },
    reply: function(floor, login) {
      var new_text, reply_body;
      reply_body = $("#reply_body");
      new_text = "#" + floor + "楼 @" + login + " ";
      if (reply_body.val().trim().length === 0) {
        new_text += '';
      } else {
        new_text = "\n" + new_text;
      }
      reply_body.focus().val(reply_body.val() + new_text);
      return false;
    },
    hightlightReply: function(floor) {
      $("#replies .reply").removeClass("light");
      return $("#reply" + floor).addClass("light");
    }
  };
  $(document).ready(function() {
    return $("textarea").bind("keydown", "ctrl+return", function(el) {
      if ($(el.target).val().trim().length > 0) {
        $("#reply form").submit();
      }
      return false;
    });
  });
}).call(this);

