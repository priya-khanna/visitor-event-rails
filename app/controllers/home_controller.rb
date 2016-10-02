class HomeController < ApplicationController
  def index
  end

  def track
    @count = visitor_count > 0 ? visitor_count : 0
    @chart_data = reload_chart ? chart_data : cached_chart_data
    @at_time = at_time.strftime('%d %b, %I:%M %P')
    @reload_chart = reload_chart
    render :track, layout: false

  end

  def about
  end

  private

  def at_time; track_params[:at_time].blank? ? Date.today + 17.hours : Time.zone.parse(track_params[:at_time]); end
  def from_time; track_params[:from_time].blank? ? Date.today + 9.hours : Time.zone.parse(track_params[:from_time]); end
  def to_time; track_params[:to_time].blank? ? Date.today + 17.hours : Time.zone.parse(track_params[:to_time]); end
  def reload_chart; track_params[:reload_chart] && track_params[:reload_chart] == "true" ? true : false;  end

  def track_params
    params.require(:event).permit(:at_time, :from_time, :to_time, :reload_chart, :range)
  end

  def range
    return 15.minutes if track_params[:range] == '15-mins'
    return 30.minutes if track_params[:range] == 'Half-hourly'
    return 1.hour if track_params[:range] == 'Hourly'
    return 1.day if track_params[:range] == 'Daily'
    return 1.week if track_params[:range] == 'Weekly'
    15.minutes
  end

  def cached_chart_data
    Rails.cache.fetch(cache_key) {
      chart_data
    }
  end

  def chart_data
    intervals = []
    if range < 1.day
      intervals << from_time
      while intervals.last <= to_time
        intervals << intervals.last + range
      end
    elsif range == 1.day
     intervals = (from_time..to_time).to_a
    end
    result = []
    intervals.each do |item|
      count = VisitorEvent.where('happened_at >= ? AND happened_at < ?', item.beginning_of_day, item + range).sum(:visitor_count)
      result << [item.strftime("%d %b, %I:%M %P"), count > 0 ? count : 0]
    end
    result
  end

  def visitor_count
    VisitorEvent.where('happened_at > ? AND happened_at <= ?', at_time.beginning_of_day, at_time).sum(:visitor_count)
  end

  def set_visitor_count
    VisitorEvent.all.each do |item|
      at = item.happened_at
      entry_visitors = VisitorEvent.where(event_type: 'entry').where('happened_at > ? AND happened_at <= ?', at.beginning_of_day, at).count
      exit_visitors = VisitorEvent.where(event_type: 'exit').where('happened_at > ? AND happened_at <= ?', at.beginning_of_day, at).count
      visitor_count = entry_visitors - exit_visitors
      visitor_count = visitor_count > 0 ? visitor_count : 0
      item.update_attributes(visitor_count: visitor_count)
    end
  end

  def cache_key
    [:chart_data, VisitorEvent.maximum(:updated_at), Time.zone.now.to_i/3600]
  end

end
