class ApplicationController < ActionController::Base
  include Authentication
  include SetCurrentAccount

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
