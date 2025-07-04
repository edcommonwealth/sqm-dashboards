class SocioEconomicCalculator
  def self.update_socio_economic_scores
    parent_list = [].tap do |list|
      Parent.all.each do |parent|
        parent.socio_economic_status = socio_economic_score(parent.education, parent.benefit, parent.employments)
        list << parent
      end
    end

    Parent.import(
      parent_list,
      batch_size: 500,
      on_duplicate_key_update: :all
    )
  end

  def self.socio_economic_score(education, benefits, employment)
    employment_points = employment.map(&:points).sum.clamp(0, 1)
    ed_points = education&.points || 0
    benefits_points = benefits&.points || 0
    ed_points + benefits_points + employment_points
  end
end
