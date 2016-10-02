class VisitorEvent < ActiveRecord::Base
  def self.event_types
    %w(entry exit)
  end

  validates :event_type, inclusion: { in: self.event_types }
  validates :ticket_id, presence: true, uniqueness: true
  validates :happened_at, presence: true
end
