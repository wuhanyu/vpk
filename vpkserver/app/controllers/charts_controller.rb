# encoding: utf-8

class ChartsController < ApplicationController

  def basic_line
    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title({ :text=>"历史活跃统计"})
      f.options[:xAxis][:categories] = ['Apples', 'Oranges', 'Pears', 'Bananas', 'Plums']
      f.series(:type=> 'spline',:name=> '历史活跃数', :data=> [3, 2.67, 3, 6.33, 3.33])
    end
  end

  def line_ajax
    @chart = Chart.line_ajax_chart
  end

  def line_labels
    @chart = Chart.line_labels_chart
  end
end
