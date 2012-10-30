class CommentController  < BaseSecureController
  post "/add_comment/:item_id" do
    id = params[:item_id].to_i
    puts "#{@data.item_by_id(id)}"
    @data.new_comment(@data.item_by_id(id), @active_user, DateTime.now, params[:text])
    redirect "/item/#{params[:item_id]}"
  end
end