class School < ApplicationRecord
  has_many :schedules, dependent: :destroy
  has_many :recipient_lists, dependent: :destroy
  belongs_to :district
  has_many :recipients, dependent: :destroy
  has_many :school_categories, dependent: :destroy
  has_many :user_schools, dependent: :destroy

  validates :name, presence: true

  scope :alphabetic, -> { order(name: :asc) }

  include FriendlyId
  friendly_id :name, :use => [:slugged]

  def available_responders_for(question)
    if question.for_students?
      return student_count || 1
    elsif question.for_teachers?
      return teacher_count || 1
    else
      return 1
    end
  end

  def merge_into(school_name)
    school = district.schools.where(name: school_name).first
    if school.nil?
      puts "Unable to find school named #{school_name} in district (#{district.name})"
      return
    end
    puts "Merging #{name} (#{id}) in to #{school.name} (#{school.id})"
    schedules.update_all(school_id: school.id)
    recipient_lists.update_all(school_id: school.id)
    recipients.update_all(school_id: school.id)
    school_categories.each do |school_category|
      school_category.update(school_id: school.id)
      existing_school_category = school.school_categories.for(school_category.school, school_category.category).in(school_category.year)
      if existing_school_category.present?
        if existing_school_category.attempt_count == 0 && existing_school_category.zscore.nil?
          existing_school_category.destroy
        else
          school_category.destroy
        end
      end
    end

    reload

    user_schools.update_all(school_id: school.id)

    school.school_categories.map(&:sync_aggregated_responses)

    base_categories = Category.joins(:questions).to_a.flatten.uniq
    base_categories.each do |category|
      SchoolCategory.for(school, category).each do |school_category|
        dup_school_categories = SchoolCategory.for(school, category).in(year)
        if dup_school_categories.count > 1
          dup_school_categories.each { |dsc| dsc.destroy unless dsc.id == school_category.id }
          school_category.sync_aggregated_responses
          parent = category.parent_category
          while parent != nil
            SchoolCategory.for(school, parent).in(year).valid.each do |parent_school_category|
              parent_dup_school_categories = SchoolCategory.for(school, parent).in(year)
              if parent_dup_school_categories.count > 1
                parent_dup_school_categories.each { |pdsc| pdsc.destroy unless pdsc.id == parent_school_category.id }
                parent_school_category.sync_aggregated_responses
              end
            end
            parent = parent.parent_category
          end
        end
      end
    end

    destroy
  end

end
