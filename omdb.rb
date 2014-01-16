require 'sinatra'
require 'sinatra/reloader'
require 'typhoeus'
require 'json'

get '/' do
  html = %q(
  <html><head><title>Movie Search</title></head><body>
  <h1>Find a Movie!</h1>
  <form accept-charset="UTF-8" action="/result" method="post">
    <label for="movie">Search for:</label>
    <input id="movie" name="movie" type="text" />
    <input name="commit" type="submit" value="Search" /> 
  </form></body></html>
  )
end

post '/result' do
  search_str = params[:movie]

  # Make a request to the omdb api here!
response = Typhoeus.get("www.omdbapi.com", :params => {:s => search_str})
response_str = ""
html_str = "<html><head><title>Movie Search Results</title></head><body><h1>Movie Results</h1>\n<ul>"

result = JSON.parse(response.body)

arr = result["Search"].sort{|el1, el2| el1["Year"] <=> el2["Year"]}
arr.each {|el| 
  html_str += "<ul><li><a href=/poster/#{el["imdbID"]}>#{el["Title"]} - #{el["Year"]}</a></li></ul><br>"
}
  html_str += "</body></html>"
end

get '/poster/:imdb' do |imdb_id|
  # Make another api call here to get the url of the poster.
  html_str = "<html><head><title>Movie Poster</title></head><body><h1>Movie Poster</h1>\n"
  response = Typhoeus.get("www.omdbapi.com/?i=#{imdb_id}") 

  ID_hash = JSON.parse(response.body)
  url = ID_hash["Poster"]
#  html_str += "<h3>ID = #{imdb_id}</h3><br>"
  html_str += "<img src=#{url}>"
  html_str += '<br /><a href="/">New Search</a></body></html>'

end

