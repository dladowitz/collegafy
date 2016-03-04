namespace :run_bot do
  desc "logs in and posts job to collge job board"
  task post__indian_head_job: :environment do
    puts "Starting up bot........"
    number_of_postings = 1

    puts "Finding colleges in database with passwords. Limiting to #{number_of_postings}"
    approved_colleges = College.where.not("password = 'nil'").limit(number_of_postings)
    puts "Found #{approved_colleges.count} colleges"

    puts "Posting jobs......."

    approved_colleges.each do |college|
      agent = Mechanize.new
      login_url = college.home_url + "/Employer.cfm"
      puts "Generating login url: #{login_url}"

      puts "Getting login page"
      agent.get login_url

      password = college.password
      puts "Filling signing form with username: dladowitz, password: #{password}"

      form = agent.page.forms[1]
      puts "Logging into form"
      form.BusCode = "dladowitz"
      form.BusPassword = password
      form.submit

      puts "Logged in"
      puts "Clicking on 'Post a new job' link"
      agent.page.links[5].click

      puts "On 'Post a Job' page"
      form = agent.page.forms.first

      puts "Filling out out job posting form"
      form.JobTitle = "Summer Camp Counselor"


    end
    puts "Shutting down bot........"
  end




  desc "TODO"
  task register_school: :environment do
  end

end
