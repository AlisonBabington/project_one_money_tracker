require( 'sinatra' )
require( 'sinatra/contrib/all' ) if development?

get '/tags' do # index
  @tags = Tag.all()
  erb( :"tags/index" )
end


get '/tags/:id' do # show
  @tag = Tag.find_by_id(params[:id])
  erb( :"tags/show" )
end

post '/tags' do # create
  @tag = Tag.new(params)
  @tag.save()
  redirect back
end

get '/tags/:id/edit' do #edit
  @tag = Tag.find_by_id(params[:id])
  erb(:"tags/edit")
end

post '/tags/:id' do #update
  tag = Tag.new(params)
  tag.update()
  redirect to "/tags/#{tag.id}"
end

post "/tags/:id/delete" do #delete
  tag = Tag.find_by_id(params[:id])
  tag.delete()
  redirect to "/tags"
end
