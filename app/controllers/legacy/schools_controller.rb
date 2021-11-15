module Legacy
  class SchoolsController < ApplicationController
    before_action :authenticate_user!, except: [:show]
    before_action :set_school, only: [:admin, :show, :edit, :update, :destroy]
    before_action :verify_admin, except: [:show, :create, :new]

    # GET /schools/1
    # GET /schools/1.json
    def show
      @district = @school.district
      authenticate(@district.name.downcase, "#{@district.name.downcase}!")

      @years = [2017, 2018, 2019]
      @year = (params[:year] || @years.last).to_i

      if @district.name == "Boston"
        @categories = Category.joins(:questions)
        @school_categories = SchoolCategory.where(school: @school).where(category: @categories).in(@year).to_a
      else
        @categories = Category.root
        @school_categories = @school.school_categories.for_parent_category(@school, nil).valid.in(@year).sort
      end

      missing_categories = @categories - @school_categories.map(&:category)
      missing_categories.each do |category|
        @school_categories << category.school_categories.new(school: @school, year: @year)
      end

      @school_categories = @school_categories.select { |sc| sc.year.to_i == @year }
    end

    def admin
    end

    # GET /schools/new
    def new
      @school = School.new
    end

    # GET /schools/1/edit
    def edit
    end

    # POST /schools
    # POST /schools.json
    def create
      @school = School.new(school_params)

      respond_to do |format|
        if @school.save
          format.html { redirect_to @school, notice: 'School was successfully created.' }
          format.json { render :show, status: :created, location: @school }
        else
          format.html { render :new }
          format.json { render json: @school.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /schools/1
    # PATCH/PUT /schools/1.json
    def update
      respond_to do |format|
        if @school.update(school_params)
          format.html { redirect_to @school, notice: 'School was successfully updated.' }
          format.json { render :show, status: :ok, location: @school }
        else
          format.html { render :edit }
          format.json { render json: @school.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /schools/1
    # DELETE /schools/1.json
    def destroy
      @school.destroy
      respond_to do |format|
        format.html { redirect_to legacy_schools_url, notice: 'School was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_school
      @school = School.friendly.find(params[:id] || params[:school_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def school_params
      params.require(:school).permit(:name, :district_id)
    end

  end
end
