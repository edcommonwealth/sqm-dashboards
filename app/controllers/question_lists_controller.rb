class QuestionListsController < ApplicationController
  before_action :set_question_list, only: [:show, :edit, :update, :destroy]

  # GET /question_lists
  # GET /question_lists.json
  def index
    @question_lists = QuestionList.all
  end

  # GET /question_lists/1
  # GET /question_lists/1.json
  def show
  end

  # GET /question_lists/new
  def new
    @question_list = QuestionList.new
  end

  # GET /question_lists/1/edit
  def edit
  end

  # POST /question_lists
  # POST /question_lists.json
  def create
    @question_list = QuestionList.new(question_list_params)

    respond_to do |format|
      if @question_list.save
        format.html { redirect_to @question_list, notice: 'Question list was successfully created.' }
        format.json { render :show, status: :created, location: @question_list }
      else
        format.html { render :new }
        format.json { render json: @question_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /question_lists/1
  # PATCH/PUT /question_lists/1.json
  def update
    respond_to do |format|
      if @question_list.update(question_list_params)
        format.html { redirect_to @question_list, notice: 'Question list was successfully updated.' }
        format.json { render :show, status: :ok, location: @question_list }
      else
        format.html { render :edit }
        format.json { render json: @question_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /question_lists/1
  # DELETE /question_lists/1.json
  def destroy
    @question_list.destroy
    respond_to do |format|
      format.html { redirect_to question_lists_url, notice: 'Question list was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question_list
      @question_list = QuestionList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_list_params
      params.require(:question_list).permit(:name, :description, question_id_array: [])
    end
end
