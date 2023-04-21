# frozen_string_literal: true

class Survey < ApplicationRecord
  enum form: {
    normal: 0,
    short: 1
  }, _default: :normal
end
