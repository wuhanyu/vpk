$(document).ready ->
  $(".edit_rec").on("ajax:success", (e, data, status, xhr) ->
    $("#messageshow").text xhr.responseText
  ).bind "ajax:error", (e, xhr, status, error) ->
    alert("出错啦！")
$(document).ready ->
  $("input[name='commit']").click ->
    $(this).hide()
