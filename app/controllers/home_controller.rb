class HomeController < ApplicationController
  def index
  end

  def track
    @count = visitor_count > 0 ? visitor_count : 0
    @chart_data = reload_chart ? chart_data : cached_chart_data
    @at_time = at_time.strftime('%d %b, %I:%M %P')
    @x_title = "#{track_params[:range]} data trend from #{from_time.strftime('%d %b')} to #{to_time.strftime('%d %b')}"
    render :track, layout: false
  end

  private

  def at_time; track_params[:at_time].blank? ? Date.today + 17.hours : Time.zone.parse(track_params[:at_time]); end
  def from_time; track_params[:from_time].blank? ? Date.today + 9.hours : Time.zone.parse(track_params[:from_time]); end
  def to_time; track_params[:to_time].blank? ? Date.today + 17.hours : Time.zone.parse(track_params[:to_time]); end
  def reload_chart; track_params[:reload_chart] && track_params[:reload_chart] == "true" ? true : false;  end

  def track_params
    @_track_params ||= params.require(:event).permit(:at_time, :from_time, :to_time, :reload_chart, :range)
  end

  def range
    return 15.minutes if track_params[:range] == '15-mins'
    return 30.minutes if track_params[:range] == 'Half-hourly'
    return 1.hour if track_params[:range] == 'Hourly'
    return 1.day if track_params[:range] == 'Daily'
    return 1.week if track_params[:range] == 'Weekly'
    1.hour
  end

  def cached_chart_data
    Rails.cache.fetch(cache_key) {
      chart_data
    }
  end

  def chart_data
    intervals = []; result = [];
    intervals << from_time
    while intervals.last <= to_time
      intervals << intervals.last + range
    end
    intervals.each do |item|
      count = VisitorEvent.where('happened_at >= ? AND happened_at <= ?', item.beginning_of_day, item).sum(:effect)
      # count = VisitorEvent.where('happened_at >= ? AND happened_at <= ?', item.beginning_of_day, item).order(:happened_at).last.try(:visitor_count)
      result << [item.strftime("%d %b, %I:%M %P"), count && count > 0 ? count : 0]
    end
    result
  end

  def sql_data
    VisitorEvent.find_by_sql("SELECT MAX(visitor_count), MAX(happened_at), floor(extract(epoch FROM happened_at)/(1 * 60)) AS timekey FROM visitor_events WHERE happened_at BETWEEN '2016-10-02 00:00:00' AND '2016-10-02 17:00:00' GROUP BY timekey;")
  end

  def visitor_count
    VisitorEvent.where('happened_at > ? AND happened_at <= ?', at_time.beginning_of_day, at_time).sum(:effect)
  end

  def cache_key
    [:chart_data, range, VisitorEvent.maximum(:updated_at), Time.zone.now.to_i/3600]
  end

end
