class Poster < ActiveRecord::Base

  # Set posting limit with number_of_postings
  def self.post_to_college_central_network(job)
    number_of_postings = 30 #limits postings while testing

    puts "\n************** Starting up Posting Bot **************"

    puts "Finding colleges in database with passwords. Limiting to #{number_of_postings}"
    approved_colleges = College.where.not("password = 'nil'").limit(number_of_postings)
    puts "Found #{approved_colleges.count} colleges"

    puts "Posting jobs......."

    successfully_submited = 0
    not_successfully_submited = 0
    missing_post_new_job_link = 0
    new_job_postings_in_db = 0
    duplicate_job_posting_for_college = 0
    broken_urls = 0

    approved_colleges.each do |college|
      puts "\nCollge is: #{college.home_url}"

      if college.job_postings.where(title: job[:title], company: job[:company], desta_url: job[:desta_url]).any?
        puts "Skipping - Job has already been posted for #{job[:title]} - #{job[:company]} - #{job[:desta_url]}"
        duplicate_job_posting_for_college += 1
        next
      end

      agent = Mechanize.new
      login_url = college.home_url + "/Employer.cfm"
      puts "Generating login url: #{login_url}"

      puts "Getting login page"

      begin
          agent.get login_url
      rescue => e
        puts "Problem getting URL, skipping"
        broken_urls += 1
        puts e.message
        next
      end

      password = college.password
      puts "Filling signing form with username: dladowitz, password: #{password}"

      form = agent.page.forms[1]
      puts "Logging into form"
      form.BusCode = "dladowitz"
      form.BusPassword = password
      form.submit

      puts "Logged in"
      puts "Clicking on 'Post a new job' link"

      new_post_link = agent.page.link_with(text: "Post a New Job")

      if agent.page.link_with(text: "Post a New Job")
        puts "This is the first job posting for this school"
        new_post_link = agent.page.link_with(text: "Post a New Job")
        new_post_link.click

      elsif agent.page.link_with(text: "Post, Edit, Repost or Expire Job Postings")
        puts "Other jobs already posted to school"
        new_post_link = agent.page.link_with(text: "Post, Edit, Repost or Expire Job Postings")
        new_post_link.click
        form = agent.page.forms.first
        form.submit

      else
        puts "Error: No 'New Job' link found"
        missing_post_new_job_link += 1
        puts "Jobs NOT successfully posted: #{not_successfully_submited}"
      end

      if agent.page.body.include?("Please provide as much information as possible to receive the best response")
        puts "On 'Post a Job' page"
        form = agent.page.forms.first

        puts "Filling out out job posting form"
        form.JobTitle = job[:title]
        form.Salary = job[:salary]


        # Job Type
        job_checkbox_found = nil
        if form.checkbox_with(value: "6")
          puts "Season checkbox found and checked"
          form.checkbox_with(value: "6").checked = true #Seasonal
          job_checkbox_found = true
        end

        if form.checkbox_with(value: "1")
          puts "Fulltime checkbox found and checked"
          form.checkbox_with(value: "1").checked = true
          job_checkbox_found = true
        end

        unless job_checkbox_found
          puts "Neither Fulltime or Season checkbox found. Checking the first job_type checkbox found"
          puts "Job Type checkbox value is: #{form.checkboxes_with(name: "JobType").first.value}"
          form.checkboxes_with(name: "JobType").first.checked = true
        end

        form.LocationWanted = job[:location_wanted]
        form.Region = job[:region]
        form.LocationZip = job[:location_zip]

        form.checkbox_with(value: "A").checked = true
        form.checkbox_with(value: "S").checked = true

        # Interests not comming through
        form.Interest1Wanted = job[:interest_1_wanted]
        form.Interest2Wanted = job[:interest_2_wanted]
        form.Interest3Wanted = job[:interest_3_wanted]
        form.SpecialSkills = job[:special_skills]

        form.ContactName = job[:contact_name]
        form.ContactEMail = job[:contact_email]
        form.ContactPhone = job[:contact_phone]
        form.CompanyAddr1 = job[:company_addr1]
        form.CompanyAddr2 = job[:company_addr2]
        form.CompanyCity = job[:company_city]
        form.CompanyState = job[:company_state]
        form.CompanyZip = job[:company_zip]
        form.ApplyOnlineURL = job[:desta_url]
        form.ExpireDate = job[:expire_date]
        form.JobDescription = job[:job_description]
        form.submit


        if agent.page.body.include?("has been posted successfully")
          puts "Successfully submitted job!"
          job_posting = college.job_postings.new(title: job[:title], company: job[:company], desta_url: job[:desta_url])
          successfully_submited += 1
          puts "Jobs successfully posted: #{successfully_submited}"

          if job_posting.save
            puts "New job posting saved to db"
            new_job_postings_in_db += 1
            puts "Total new job postings saved to db: #{new_job_postings_in_db}"
          else
            puts "Job submitted to college network successly, but not save to local db"
          end
        else
          puts "Error!!!!!! Something went wrong with submission!"
          not_successfully_submited += 1
          puts "Jobs NOT successfully posted: #{not_successfully_submited}"
        end
      else
        puts "Something went wrong. Clicked on Post a New Job, but not on correct page!"
      end
    end

    puts "\n---------------- Job Posting Results ----------------"
    puts "Jobs successfully submitted: #{successfully_submited}"
    puts "Jobs NOT successfully submitted: #{not_successfully_submited}"
    puts "College homepages missing 'new job' link: #{missing_post_new_job_link}"
    puts "Skipped because job has already been posted for this college: #{duplicate_job_posting_for_college}"
    puts "Skipped because of broken url: #{broken_urls}"
    puts "---------------- Job Posting Results ----------------"
    puts "\n"
    puts "************** Shutting Poster Bot **************"
  end

  # Should put this in a database or yaml file
  # set current job
  def self.current_job
    jobs = []

    jobs[0] = {
      title: "Summer Camp Counselor",
      company: "Indian Head Camp",
      desta_url: "desta.co\/job\/opt-specialist",
      salary: "$2,400/mo + Room & Board",
      location_wanted: ["PA"],
      region: "Equinunk",
      location_zip: "18417",
      interest_1_wanted: "88",
      interest_2_wanted: "43",
      interest_3_wanted: "117",
      special_skills: "Love having fun, kids and the outoors",
      contact_name: "Joe Ewing",
      contact_email: "joe@desta.com",
      contact_phone: "303-519-9391",
      company_addr1: "Summer Address",
      company_addr2: "PO Box 2005",
      company_city: "Honesdale",
      company_state: "PA",
      company_zip: "18431",
      expire_date: "06\/20\/2016",

      job_description: "https:\/\/desta.co/job/opt-specialist <br><br>
Counselors are the guides and facilitators at Indian Head Camp. OPT staff work with all ages at camp and with a variety of skills, including boating, zipping, climbing, mountain biking and hiking to name a few.<br><br>
The program starts with educational nature hikes around camp and builds up to a four-day trip to the Adirondacks that includes camping on an island.  The design of the program is to increase the challenges as our campers need and age increases.<br><br>
On camp, the programs offers everything from a 30 element project adventure ropes course, 1,215 feet of zipline, 7 miles of hiking and mountain biking trails, rock climbing walls, bouldering walls, nature education, daily Delaware River canoe trips, and a variety of special outdoor adventure-centric camp events. Off camp, is really where the adventure begins.<br><br>
The younger campers on Lake Camp get to camp out in a teepee, sing songs around the campfire, look at the stars, eat smore's, and feel like they're off on an adventure in the woods—when really, they're still safe and sound on the camp premises. This is to get the campers comfortable with the idea of not spending the night in their bunks.<br><br>
As they get older, they begin taking overnight trips to the beautiful Adirondacks where they will spend time hiking, rock climbing, rappelling, and camping—all while also learning about the endless varieties that nature has to offer. These trips get progressively more adventurous as the campers become more mature, but every trip is lead by outdoor adventure specialists who have been vigorously trained. All adventure staff are also certified lifeguards by The American Red Cross, trained to the ACCT Challenge Course Practioner standards, and trained in single pitch climbing & anchors building.",
    }

    jobs[1] = {
      title: "Off-Road Tour Guide",
      company: "Pink Jeep Tours",
      desta_url: "desta.co\/job\/tour-guide",
      salary: "Depends on Experience",
      location_wanted: ["AZ"],
      region: "Tusayan",
      location_zip: "86023",
      interest_1_wanted: "88",
      interest_2_wanted: "118",
      interest_3_wanted: "117",
      special_skills: "Love having fun, people and the outoors",
      contact_name: "Joe Ewing",
      contact_email: "joe@desta.com",
      contact_phone: "303-519-9391",
      company_addr1: "450 Arizona 64",
      company_addr2: "",
      company_city: "Tusayan",
      company_state: "AZ",
      company_zip: "86023",
      expire_date: "06\/20\/2016",

      job_description: "https:\/\/desta.co/job/tour-guide <br><br>
Pink Jeep Tours has been thrilling visitors as the premier off-road excursion company in the Southwest for more than 50 years. The first Jeep tour operator in the United States, the company was founded in Sedona, Arizona in 1960 and has since become known for its “must do” rugged adventure tours through Sedona’s Red Rock Country, the Grand Canyon, Scottsdale, and Las Vegas.<br><br>
Pink Jeep Tours is seeking Tour Guides. This position will work in our beautiful Grand Canyon location and provide educational and fun tours at one of the most treasured sites in the United States. Join a great team of professionals who love what they do, love the product, and love working for a company that sells FUN!<br><br>
Job Responsibilities and Requirements:<br>
We are hiring PT and FT Guides who are fun, safety minded, self-motivated, w/ excellent customer service and communication skills. You will share the area’s cultural and natural history while providing fun and adventure on a variety of paved and scenic trails. You must be able to endure weather extremes and driving up to 10 hours/day in a physically-demanding job; walking on uneven terrain and light hiking ability is required. Tour Guides must be at least 25 years of age with a good driving record. We provide extensive training and offer competitive pay and benefits.<br><br>
Compensation and Benefits:<br>
• Compensation is competitive with opportunities for advancement<br>
• Benefits available for full time employees the first of month following 60 days service and includes 2 medical and dental plans, vision plan, life insurance, 401(k) with match, paid vacation, and complimentary tours.<br>
• Employee housing is available on a part-time or full-time basis.<br><br>",
    }


    # set job
    current_job = jobs[1]
    puts "Current Job is set to: #{current_job[:title]}"

    return  current_job
  end

end
