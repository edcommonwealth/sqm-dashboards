# TODO: move this to legacy, probably?
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
