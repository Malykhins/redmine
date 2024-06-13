class ChartController < ApplicationController
  unloadable

  def show
    @project = Project.find(params[:project_id])
    issues = Issue.where(:project_id => @project)

    if params[:start_date].blank? || params[:end_date].blank?
      start_date = issues.minimum(:start_date)
      end_date = issues.maximum(:closed_on).to_date
    else
      start_date =  Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
    end

    # Все задачи, попавшие в период
    in_period_issues =  Issue.where(project_id: @project)
                             .where("(start_date >= :start_date AND start_date <= :end_date) OR
                                     (closed_on >= :start_date AND closed_on <= :end_date)",
                                    start_date: start_date, end_date: end_date)

    # Общее количество Story points всех задач периода
    total_story_points = in_period_issues.sum(:story_points)

    # Закрытые задачи в периоде
    closed_issues_in_period = in_period_issues.where(status_id: 5)
                                              .order(closed_on: :asc)

    # Начальная дата для построения графика
    start_date = issues.minimum(:start_date)

    # Начальные данные для графиков
    @ideal_burndown_data = { start_date => total_story_points }
    @actual_burndown_data = { start_date => total_story_points }

    # Средняя величина story points, которая должна убывать каждый день для выполнение плана
    median_points = total_story_points / (end_date - start_date).to_f

    # Группируем по дате закрытия задач
    issues_group_by_closed_on = closed_issues_in_period.group_by { |issue| issue.closed_on.to_date }

    # Убывающие story points
    decreasing_story_points = total_story_points

    # Заполнение данных для графиков
    (start_date..end_date).each.with_index do |date, index|
      @ideal_burndown_data[date] = (total_story_points - median_points * index).round(2)

      stories_points = 0
      if issues_group_by_closed_on[date].present?
        stories_points = issues_group_by_closed_on[date].sum { |issue| issue.story_points }
      end

      @actual_burndown_data[date] = decreasing_story_points
      decreasing_story_points -= stories_points
    end
  end
end
