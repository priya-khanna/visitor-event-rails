class VisitorEvent < ActiveRecord::Base
  # before_save :update_visitor_counts


  private

  def update_visitor_counts
    visitor_events = VisitorEvent.where('happened_at > ? AND happened_at < ?', self.happened_at.beginning_of_day, self.happened_at)
    visitor_events.each do |item|
      item.update_attributes(visitor_count: visitor_count_for(item))
    end
    self.visitor_count = visitor_count_for(self)
  end

  def visitor_count_for(event)
    at = event.happened_at
    entry_visitors = VisitorEvent.where(event_type: 'entry').where('happened_at > ? AND happened_at <= ?', at.beginning_of_day, at).count
    exit_visitors = VisitorEvent.where(event_type: 'exit').where('happened_at > ? AND happened_at <= ?', at.beginning_of_day, at).count
    visitor_count = entry_visitors - exit_visitors
    visitor_count > 0 ? visitor_count : 0
  end
end
