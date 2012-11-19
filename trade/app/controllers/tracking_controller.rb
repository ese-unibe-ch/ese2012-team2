require_relative 'base_secure_controller'

class TrackingController < BaseSecureController

  post '/track/:type/:track_id' do
    trackee = nil
    if params[:type] == "user"
      trackee = @data.user_by_name(params[:track_id])
    end
    @active_user.track trackee
    redirect back
  end

  post '/untrack/:track_id' do
    trackee = @data.trackee_by_tracker_and_id(@active_user, params[:track_id])
    @active_user.untrack trackee
    redirect back
  end
end