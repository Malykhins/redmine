class AddStoryPointsToIssues < ActiveRecord::Migration[6.1]
  def change
    add_column :issues, :story_points, :integer,null: false, default: 0
  end
end
