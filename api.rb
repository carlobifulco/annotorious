#### visibility

get "/api" do
  api_urls={api_urls: (File.readlines(__FILE__)\
                        +File.readlines("./api.rb"))\
                              .grep(/"\/api_/)\
                              .map {|x| x.match(/api\S*/)\
                              .to_s.gsub('"','')}\
                              .select {|x|x.match(/[{})(]/)==nil }\
                              .uniq}
  erb $handlebars.compile("""
  <ul>
    {{#each api_urls}}
      <li> <a href=/{{this}}>{{this}} </a> </li>
    {{/each}}
  </ul>
  """).call(api_urls)
end


get "/api___________________________git_pull_etc_________" do
end

get "/api_git_pull" do
  headers('Content-Type' => "text/plain")
  `git pull`
end


get "/api_show_branch" do
  headers('Content-Type' => "text/plain")
  return `git branch`
end


get "/api_show_log" do
  headers('Content-Type' => "text/plain")
  return `git log`
end
