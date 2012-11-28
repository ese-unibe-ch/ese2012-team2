require_relative '../models/comment'

class CommentController  < BaseSecureController
  post "/add_comment/:item_id" do
    id = params[:item_id].to_i
    item = @data.item_by_id(id)
    item.add_comment Models::Comment.new(params[:text], @active_user)
    flash[:success] = "Added comment successfully"
    redirect "/item/#{params[:item_id]}"
  end
end