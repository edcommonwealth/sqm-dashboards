require 'rails_helper'

describe CategoryPresenter do
  let(:category_presenter) do
    subcategory1 = Subcategory.new(name: 'A subcategory')
    subcategory2 = Subcategory.new(name: 'Another subcategory')

    category = SqmCategory.new(name: 'Some Category', subcategories: [subcategory1, subcategory2], description: 'A description for some Category')
    return CategoryPresenter.new(category: category)
  end

  let(:teachers_and_leadership_presenter) do
    category = create(:sqm_category, name: 'Teachers & Leadership')
    return CategoryPresenter.new(category: category)
  end

  let(:school_culture_presenter) do
    category = create(:sqm_category, name: "School Culture")
    return CategoryPresenter.new(category: category)
  end

  let(:resources_presenter) do
    category = create(:sqm_category, name: "Resources")
    return CategoryPresenter.new(category: category)
  end

  let(:academic_learning_presenter) do
    category = create(:sqm_category, name: "Academic Learning")
    return CategoryPresenter.new(category: category)
  end

  let(:community_and_wellbeing_presenter) do
    category = create(:sqm_category, name: "Community & Wellbeing")
    return CategoryPresenter.new(category: category)
  end

  after :each do
    DatabaseCleaner.clean
  end

  it 'returns the name and description of the category' do
    expect(category_presenter.name).to eq 'Some Category'
    expect(category_presenter.description).to eq 'A description for some Category'
  end

  it 'maps subcategories to subcategory presenters' do
    expect(category_presenter.subcategories(academic_year: AcademicYear.new, school: School.new).map(&:name)).to eq ['A subcategory', 'Another subcategory']
  end

  it 'returns the correct icon for the given category' do
    expect(teachers_and_leadership_presenter.icon_class).to eq 'fas fa-apple-alt'
    expect(school_culture_presenter.icon_class).to eq 'fas fa-school'
    expect(resources_presenter.icon_class).to eq 'fas fa-users-cog'
    expect(academic_learning_presenter.icon_class).to eq 'fas fa-graduation-cap'
    expect(community_and_wellbeing_presenter.icon_class).to eq 'fas fa-heart'
  end

  it 'returns the correct color for the given category' do
    expect(teachers_and_leadership_presenter.icon_color_class).to eq 'color-blue'
    expect(school_culture_presenter.icon_color_class).to eq 'color-red'
    expect(resources_presenter.icon_color_class).to eq 'color-black'
    expect(academic_learning_presenter.icon_color_class).to eq 'color-lime'
    expect(community_and_wellbeing_presenter.icon_color_class).to eq 'color-teal'
  end
end
