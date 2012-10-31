require_relative '../models/user'
require_relative '../helpers/image_helper'
require_relative '../helpers/item_validator'
require_relative 'base_secure_controller'

class LastResortController < BaseSecureController

  #PS matches any GET Route, little convenience hack
  get %r{(/.*?)+} do
     redirect "/index"
  end

end