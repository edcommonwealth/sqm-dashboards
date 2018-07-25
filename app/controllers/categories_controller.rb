class CategoriesController < ApplicationController
  before_action :set_school, only: [:show]
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.all
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    district = @school.district
    authenticate(district.name.downcase, "#{district.name.downcase}!")
    school_categories = SchoolCategory.for(@school, @category)
    @years = school_categories.map(&:year).map(&:to_i).sort
    @year = (params[:year] || @years.first).to_i
    @years.delete(@year)
    @school_category = school_categories.in(@year).first
    @child_school_categories = SchoolCategory.for_parent_category(@school, @category).in(@year).valid
    @questions = @category.questions.created_in(@year)
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: 'Category was successfully created.' }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: 'Category was successfully updated.' }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_url, notice: 'Category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_school
      redirect_to root_path and return false unless params.include?(:school_id)
      @school = School.friendly.find(params[:school_id])
      redirect_to root_path and return false if @school.nil?
    end

    def set_category
      @category = Category.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:name, :blurb, :description, :external_id, :parent_category_id)
    end
end
