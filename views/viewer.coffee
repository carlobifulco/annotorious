
$(document).ready =>
  console.log "here I am, suffering"
  options=
  	id: "contentDiv",
  	#debugMode:  true,
  	prefixUrl:       "/images/",
  	showNavigator:  true,
  	tileSources:   "/cases/CD8DAKO_05H1541-8-n1SITC_files/CD8DAKO_05H1541-8-n1SITC.dzi"
    
 
       
  window.options=options
  OpenSeadragon options
  w=$(window).width()
  h=$(window).height()
  $(".openseadragon").height(h-200).width(w)


