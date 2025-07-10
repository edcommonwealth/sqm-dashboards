class SocioEconomicCalculator
  def self.update_socio_economic_scores
    parent_list = [].tap do |list|
      Parent.includes(:employments, :benefit, :education).all.each do |parent|
        parent.socio_economic_status = if has_all_socio_economic_data?(parent:)
                                         socio_economic_score(parent.education, parent.benefit, parent.employments)
                                       else
                                         -1
                                       end

        list << parent
      end
    end

    Parent.import(
      parent_list,
      batch_size: 500,
      on_duplicate_key_update: :all
    )
  end

  def self.has_all_socio_economic_data?(parent:)
    parent.education.present? && parent.education.designation != "Unknown" && parent.benefit.present? && parent.benefit.designation != "Unknown" && parent.employments.any? && parent.employments.any? { |employment| employment.designation != "Unknown" }
  end

  def self.socio_economic_score(education, benefits, employment)
    return -1 if education.designation == "Unknown" || benefits.designation == "Unknown" || employment.empty? || employment.all? { |employment| employment.designation == "Unknown" }

    # Calculate the total points from employment, education, and benefits
    # Assuming each of these has a method `points` that returns a numeric value
    # If any of these are nil, we treat them as 0 points

    # Clamp the total points to be between 0 and 1
    employment_points = employment.map(&:points).sum.clamp(0, 1)
    ed_points = education&.points || 0
    benefits_points = benefits&.points || 0
    ed_points + benefits_points + employment_points
  end
end
