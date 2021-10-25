require 'rails_helper'

describe CategoryPresenter do
  let(:category_presenter) do
    subcategory1 = Subcategory.new(name: 'A subcategory')
    subcategory2 = Subcategory.new(name: 'Another subcategory')

    category = SqmCategory.new(name: 'Some Category', subcategories: [subcategory1, subcategory2], description: 'A description for some Category')
    return CategoryPresenter.new(category: category)
  end

  let(:teachers_and_leadership_presenter) do
    category = SqmCategory.find_by_name("Teachers & Leadership")
    return CategoryPresenter.new(category: category)
  end

  let(:school_culture_presenter) do
    category = SqmCategory.find_by_name("School Culture")
    return CategoryPresenter.new(category: category)
  end

  let(:resources_presenter) do
    category = SqmCategory.find_by_name("Resources")
    return CategoryPresenter.new(category: category)
  end

  let(:academic_learning_presenter) do
    category = SqmCategory.find_by_name("Academic Learning")
    return CategoryPresenter.new(category: category)
  end

  let(:community_and_wellbeing_presenter) do
    category = SqmCategory.find_by_name("Community & Wellbeing")
    return CategoryPresenter.new(category: category)
  end

  it 'returns the name and description of the category' do
    expect(category_presenter.name).to eq 'Some Category'
    expect(category_presenter.description).to eq 'A description for some Category'
  end

  it 'maps subcategories to subcategory presenters' do
    expect(category_presenter.subcategories(academic_year: AcademicYear.new, school: School.new).map(&:name)).to eq ['A subcategory', 'Another subcategory']
  end

  it 'returns the correct icon for the given category' do
    expect(teachers_and_leadership_presenter.icon).to eq 'apple-alt'
    expect(school_culture_presenter.icon).to eq 'school'
    expect(resources_presenter.icon).to eq 'users-cog'
    expect(academic_learning_presenter.icon).to eq 'graduation-cap'
    expect(community_and_wellbeing_presenter.icon).to eq 'heart'
  end
end
