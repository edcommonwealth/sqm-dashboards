require 'rails_helper'

describe CategoryPresenter do
  let(:category_presenter) do
    subcategory1 = Subcategory.new(name: 'A subcategory')
    subcategory2 = Subcategory.new(name: 'Another subcategory')

    category = SqmCategory.new(name: 'Some Category', description: 'Some category description', subcategories: [subcategory1, subcategory2])
    return CategoryPresenter.new(category: category, academic_year: AcademicYear.new, school: School.new)
  end

  it 'returns the name of the category' do
    expect(category_presenter.name).to eq 'Some Category'
  end

  it 'returns the description of the category' do
    expect(category_presenter.description).to eq 'Some category description'
  end

  it 'maps subcategories to subcategory presenters' do
    expect(category_presenter.subcategories.map(&:name)).to eq ['A subcategory', 'Another subcategory']
  end
end
