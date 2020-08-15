
get_case=()->
  case_n= $("#case").val()
  console.log 
  if case_n
    get_images case_n
    get_results case_n


get_images=(case_n)->
  $.get("/images/#{case_n}", (data_images)=>
    console.log "getting images=#{case_n}"
    console.log data_images
    window.data_images=data_images
    render_template("images", data_images)
    #$("#log_html").html(data)
  )

window.get_images=get_images


get_results=(case_n)->
  $.get("/results/#{case_n}", (data_results)=>
    console.log "getting results=#{case_n}"
    console.log data_results
    window.data_results=data_results
    render_template("results", data_results)
    #$("#log_html").html(data)
  )
window.get_results=get_results




$(document).ready =>
  console.log "here I am, suffering"
  $("#find").click(()->
    get_case())

  get_case()
