module QuestionsHelper

  def format_question(question_text)
    question_text.gsub("[Field-MathTeacher][Field-ScienceTeacher][Field-EnglishTeacher][Field-SocialTeacher]", "teacher")
                 .gsub("is", "iis")  
  end

end
