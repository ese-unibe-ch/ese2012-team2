class SearchController < BaseSecureController
  get "/search" do
    @title = "Search"
    keyword = Models::SearchRequest.splitUp(params[:keywords])
    search_request = Models::SearchRequest.create(keyword, @active_user)
    items_with_relevances = search_request.get_matching_items_with_relevances(@data.all_items)
    haml :search, :locals => {:search_request => search_request, :items_with_relevances => items_with_relevances}
  end

  get "/search_requests" do
    @title = "Subscriptions"
    search_requests = @data.search_requests_by_user(@active_user)
    haml :search_requests, :locals => {:search_requests => search_requests}
  end

  get "/delete/:search_request" do
    search_request = @data.search_request_by_id params[:search_request].to_i
    if search_request != nil && search_request.user == @active_user
      @data.remove_search_request(search_request)
    end
    redirect back
  end

  post "/research/:search_request" do
    @title = "Search"
    search_request = @data.search_request_by_id params[:search_request].to_i
    items = search_request.get_matching_items_with_relevances(@data.all_items)
    params[:keywords] = search_request.all_keywords
    haml :search, :locals => {:search_request => search_request, :items_with_relevances => items}
  end

  get "/subscribe" do
    @data.new_search_request(params[:keywords], @active_user)
    flash[:success] = "Successfully subscribed."
    redirect "/search_requests"
  end
end