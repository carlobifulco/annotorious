my_directory=File.dirname(File.expand_path(__FILE__))
$LOAD_PATH << File.join(my_directory,'/lib')
$LOAD_PATH << my_directory


require "sinatra"
require 'handlebars'


$handlebars = Handlebars::Context.new




set :server, :thin

set :bind, '0.0.0.0'

set :port, 7563

####SINATRA SETUPS
set :root, File.dirname(__FILE__)
# pulling views out of public so that I can add to git --public is to vbe mounted locally on remote server
set :views, Proc.new { File.join(root, "views") }
set :public_folder, Proc.new { File.join(root, "public") }

require 'sinatra/reloader'
Dir.glob('./*.rb').each { |x| also_reload(x) }
puts "ahasdsds"


#dzi_files= Dir.glob("./public/**/*.dzi").map{|i| i.gsub("./public","")}
#Dir.glob("./public/cases/**").map{|i| i+"/"+ File.basename(i).gsub("_files", ".dzi")}.map{|i| i.gsub("./public/","")}
#cases= Dir.glob("./public/cases/**").map{|i| i.gsub("_files", "")}.map{|i| i.gsub("./public/cases/","")}
get "/test" do
  erb "<h1>hello</h1>"
end

get "/" do
  @cases=Dir.glob("./public/cases/**_files").map{|x|x.gsub("./public/cases/","").gsub("_files","")}
  text='
  <% for @case in @cases %>
  	<h6><a href="/slide/<%= @case %>"><%= @case %></h6>

  <% end %>
  '
  erb text
end


get "/slide/:slide_n" do |slide_n|
  @slide_n=slide_n
  @tile_sources_path="/cases/#{slide_n}.dzi"
  puts @tile_sources_path
  text='
  <br><br>
  <h6><%= @slide_n %></h6>
  <div id="contentDiv" class="openseadragon"></div>


<script>
window.onload = function() {
  var viewer = OpenSeadragon({
    id: "contentDiv",
    prefixUrl: "/images/",
    tileSources: "<%= @tile_sources_path %>"
  });

  // Initialize the Annotorious plugin
  var anno = OpenSeadragon.Annotorious(viewer);

  // Load annotations in W3C WebAnnotation format
  anno.loadAnnotations("annotations.w3c.json");

  // Attach handlers to listen to events
  anno.on("createAnnotation", function(a) {
    // Do something
  });
}
</script>






  '
	erb text

end

# {"@context":"http://iiif.io/api/image/2/context.json","@id":"http://localhost:8182/iiif/2/CMU-1.tiff","protocol":"http://iiif.io/api/image","width":46000,"height":32914,"sizes":[{"width":90,"height":64},{"width":180,"height":129},{"width":359,"height":257},{"width":719,"height":514},{"width":1438,"height":1029},{"width":2875,"height":2057},{"width":5750,"height":4114},{"width":11500,"height":8229}],"tiles":[{"width":512,"height":512,"scaleFactors":[1,2,4,8,16,32,64,128,256,512]}],"profile":["http://iiif.io/api/image/2/level2.json",{"formats":["jpg","tif","gif","png"],"maxArea":100000000,"qualities":["bitonal","default","gray","color"],"supports":["regionByPx","sizeByW","sizeByWhListed","cors","regionSquare","sizeByDistortedWh","canonicalLinkHeader","sizeByConfinedWh","sizeByPct","jsonldMediaType","regionByPct","rotationArbitrary","sizeByH","baseUriRedirect","rotationBy90s","profileLinkHeader","sizeByForcedWh","sizeByWh","mirroring"]}]}
get "/iiif" do
  text=<<~HEREDOC
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.6.0/dist/leaflet.css"
    integrity="sha512-xwE/Az9zrjBIphAcBb3F6JVqxf46+CDLwfLMHloNu6KEQCAWi6HcDUbeOfBIptF7tcCzusKFjFw2yuvEpDL9wQ=="
    crossorigin=""/>
    <script src="https://unpkg.com/leaflet@1.6.0/dist/leaflet.js"
      integrity="sha512-gZwIG9x3wUXg2hdXF6+rVkLF/0Vi9U8D2Ntg4Ga5I5BZpVkVxlJWbSQtXPSiUTtC0TjtGOmxa1AJPuV0CPthew=="
      crossorigin=""></script>
   <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
      <script src="https://cdn.rawgit.com/mejackreed/Leaflet-IIIF/v2.0.1/leaflet-iiif.js"></script>


      <div id="mapid" style="width: 900px; height: 900px;"></div>
      <script>
      var map = L.map('mapid', {
  center: [0, 0],
  crs: L.CRS.Simple,
  zoom: 0,
});

L.tileLayer.iiif('http://localhost:8182/iiif/2/CMU-1.tiff/info.json').addTo(map);


      </script>
  HEREDOC
 text
end


require "api"
