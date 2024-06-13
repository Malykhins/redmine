# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get '/projects/:project_id/chart', :to => 'chart#show', :as => 'burndown_chart'
