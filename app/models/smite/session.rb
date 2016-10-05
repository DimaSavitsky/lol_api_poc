module Smite
  class Session < ApplicationRecord
    self.table_name = :smite_sessions

    scope :actual, ->() { where(arel_table[:created_at].gt(Time.now - 14.minutes)) }


  end
end