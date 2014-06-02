require 'sinatra'
require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')
    yield(connection)
  ensure
    connection.close
  end
end

get '/movies' do
  db_connection do |conn|
  @movies = conn.exec('SELECT movies.title, movies.id, movies.year, movies.rating, genres.name FROM movies
                      JOIN genres ON movies.genre_id = genres.id
                      ORDER BY title;')
  @movies
  end
  erb :'movies/index'
end

get '/actors' do
  db_connection do |conn|
  @actors = conn.exec('SELECT actors.name, actors.id FROM actors ORDER BY name;')
  @actors
  end
  erb :'actors/index'
end

get '/actors/:id' do
  id = params[:id]
  db_connection do |conn|
  @actors = conn.exec_params('SELECT actors.name, actors.id, movies.title, movies.year, cast_members.character
                            FROM movies
                            JOIN cast_members ON movies.id = cast_members.movie_id
                            JOIN actors ON cast_members.actor_id = actors.id
                            WHERE actors.id = $1
                            ORDER BY movies.year;', [id])
  @actors
  end
  erb :'actors/show'
end

get '/movies/:id' do
  id = params[:id]
  db_connection do |conn|
  @movies = conn.exec_params('SELECT movies.title, movies.id, movies.year, movies.rating, genres.name
                      FROM movies
                      JOIN genres ON movies.genre_id = genres.id
                      WHERE movies.id = $1', [id])
  @movies
  end
  erb :'movies/show'
end
