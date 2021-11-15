class ChangeLegacyTablesSoTheyIncludeLegacyPrefix < ActiveRecord::Migration[6.1]
  def change
    rename_table :attempts, :legacy_attempts
    rename_table :categories, :legacy_categories
    rename_table :districts, :legacy_districts
    rename_table :questions, :legacy_questions
    rename_table :recipients, :legacy_recipients
    rename_table :recipient_lists, :legacy_recipient_lists
    rename_table :recipient_schedules, :legacy_recipient_schedules
    rename_table :schedules, :legacy_schedules
    rename_table :schools, :legacy_schools
    rename_table :school_categories, :legacy_school_categories
    rename_table :school_questions, :legacy_school_questions
    rename_table :students, :legacy_students
    rename_table :users, :legacy_users
    rename_table :user_schools, :legacy_user_schools
  end
end
