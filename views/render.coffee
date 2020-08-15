#### HB rendering
render=(data,html)->
  if typeof(data)=="string"
    data=JSON.parse(data); console.log data
  hb=Handlebars.compile(html)
  results=hb(data)
  return results
window.render=render




#wrapper around the rendering; uses the html target convention "id_html"
# render_template("images", "33") renders images_template
render_template=(id,data)->
  $("##{id}_html").html(render(data,($("##{id}_template")[0]).innerHTML))
window.render_template=render_template


