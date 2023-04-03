namespace :scrape do
  desc 'scrape dese site for admin data'
  task admin: :environment do
    puts 'scraping data from dese'
    scrapers = [Dese::OneAOne, Dese::OneAThree, Dese::TwoAOne, Dese::TwoCOne, Dese::ThreeAOne, Dese::ThreeATwo,
                Dese::ThreeBOne, Dese::ThreeBTwo, Dese::FourAOne, Dese::FourBTwo, Dese::FourDOne, Dese::FiveCOne, Dese::FiveDTwo]
    scrapers.each do |scraper|
      scraper.new.run_all
    end
  end

  desc 'scrape dese site for teacher staffing information'
  task enrollment: :environment do
    Dese::ThreeATwo.new.scrape_enrollments(filepath: Rails.root.join('data', 'enrollment', 'enrollment.csv'))
  end

  desc 'scrape dese site for student staffing information'
  task staffing: :environment do
    Dese::Staffing.new.run_all
  end
end
