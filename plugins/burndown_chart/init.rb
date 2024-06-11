Redmine::Plugin.register :burndown_chart do
  name 'Burndown Chart plugin'
  author 'Malykhin Sergey'
  description 'This is a plugin for building a burndown chart'
  version '0.0.1'

  permission :burndown_chart, { :chart => [:show] }, :public => true
  menu :project_menu, :burndown_chart, { :controller => 'chart', :action => 'show' },
       :caption => 'График Burndown', :after => :gantt, :param => :project_id
end
