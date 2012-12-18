class TagController  < BaseSecureController

  get "/tags/all" do
    content_type :json
    {:tags => @data.all_tags }.to_json
  end

  get "/pop_tags" do
    haml :popular_tags, :locals => {:tags => Models::Tag.get_tags_sorted_by_popularity}
  end
end