FactoryGirl.define do
  factory :visitor_event do
    ticket_id { rand(100000) }
    event_type { %w(entry exit entry).shuffle.first }
    happened_at { rand(15.days.ago.to_date..Date.today) + rand(9.hours..17.hours) }
    effect { event_type == 'entry' ? 1 : -1 }
  end
end
