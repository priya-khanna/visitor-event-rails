task :set_visitor_counts => :environment do
  puts "Updating visitor count for #{VisitorEvent.count} events"

  VisitorEvent.all.each do |item|
    at = item.happened_at
    entry_visitors = VisitorEvent.where(event_type: 'entry').where('happened_at > ? AND happened_at <= ?', at.beginning_of_day, at).count
    exit_visitors = VisitorEvent.where(event_type: 'exit').where('happened_at > ? AND happened_at <= ?', at.beginning_of_day, at).count
    visitor_count = entry_visitors - exit_visitors
    visitor_count = visitor_count > 0 ? visitor_count : 0
    item.update_attributes(visitor_count: visitor_count)
  end
  puts "Done!"
end
