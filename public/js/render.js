// Generated by CoffeeScript 1.3.3
(function() {
  var render, render_template;

  render = function(data, html) {
    var hb, results;
    if (typeof data === "string") {
      data = JSON.parse(data);
      console.log(data);
    }
    hb = Handlebars.compile(html);
    results = hb(data);
    return results;
  };

  window.render = render;

  render_template = function(id, data) {
    return $("#" + id + "_html").html(render(data, ($("#" + id + "_template")[0]).innerHTML));
  };

  window.render_template = render_template;

}).call(this);
