module RatingsValidation
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  included do
    validates_numericality_of :awesomeness, :risk,
      message: "Must be from 0 to 10",
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 10
  end
end
