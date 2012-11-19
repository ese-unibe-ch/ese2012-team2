require_relative 'base_secure_controller'

class TrackingController < BaseSecureController

  post '/track/:type/:id' do
    trackee = nil
    if params[:type] == "user"
      trackee = @data.user_by_name(params[:id])
    end
    if params[:type] == "item"
      trackee = @data.item_by_id(params[:id].to_i)
    end
    unless trackee.nil?
      @active_user.track trackee
    end
    redirect back
  end

  post '/untrack/:track_id' do
    trackee = @data.trackee_by_tracker_and_id(@active_user, params[:track_id])
    @active_user.untrack trackee
    redirect back
  end
end