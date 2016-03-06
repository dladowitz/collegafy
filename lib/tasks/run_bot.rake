namespace :run_bot do
  desc "logs in and posts job to collge job board"
  task post_indian_head_job: :environment do
    number_of_postings = 15
    title = "Summer Camp Counselor"
    company = "Indian Head Camp"
    desta_url = "desta.co\/job\/opt-specialist"

    puts "\n************** Starting up bot **************"

    puts "Finding colleges in database with passwords. Limiting to #{number_of_postings}"
    approved_colleges = College.where.not("password = 'nil'").limit(number_of_postings)
    puts "Found #{approved_colleges.count} colleges"

    puts "Posting jobs......."

    successfully_submited = 0
    not_successfully_submited = 0
    missing_post_new_job_link = 0
    new_job_postings_in_db = 0
    duplicate_job_posting_for_college = 0

    approved_colleges.each do |college|
      puts "\nCollge is: #{college.home_url}"

      if college.job_postings.where(title: title, company: company, desta_url: desta_url).any?
        puts "Skipping - Job has already been posted for #{title} - #{company} - #{desta_url}"
        duplicate_job_posting_for_college += 1
        next
      end

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
      new_post_link = agent.page.link_with(text: "Post a New Job")

      if new_post_link
        new_post_link.click
        puts "On 'Post a Job' page"
        form = agent.page.forms.first

        puts "Filling out out job posting form"
        form.JobTitle = title
        form.Salary = "$2,400/mo + Room & Board"


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

        form.LocationWanted = ["PA"]
        form.Region = "Equinunk"
        form.LocationZip = "18417"

        form.checkbox_with(value: "A").checked = true
        form.checkbox_with(value: "S").checked = true

        # Interests not comming through
        form.Interest1Wanted = "88"
        form.Interest2Wanted = "43"
        form.Interest3Wanted = "117"
        form.SpecialSkills = "Love having fun, kids and the outoors"

        form.ContactName = "Joe Ewing"
        form.ContactEMail = "joe@desta.com"
        form.ContactPhone = "408 666 4411"
        form.CompanyAddr1 = "Summer Address"
        form.CompanyAddr2 = "PO Box 2005"
        form.CompanyCity = "Honesdale"
        form.CompanyState = "PA"
        form.CompanyZip = "18431"
        form.ApplyOnlineURL = desta_url

        form.ExpireDate = "06\/20\/2016"

        form.JobDescription = "https:\/\/desta.co/job/opt-specialist <br><br>
Counselors are the guides and facilitators at Indian Head Camp. OPT staff work with all ages at camp and with a variety of skills, including boating, zipping, climbing, mountain biking and hiking to name a few.<br><br>
The program starts with educational nature hikes around camp and builds up to a four-day trip to the Adirondacks that includes camping on an island.  The design of the program is to increase the challenges as our campers need and age increases.<br><br>
On camp, the programs offers everything from a 30 element project adventure ropes course, 1,215 feet of zipline, 7 miles of hiking and mountain biking trails, rock climbing walls, bouldering walls, nature education, daily Delaware River canoe trips, and a variety of special outdoor adventure-centric camp events. Off camp, is really where the adventure begins.<br><br>
The younger campers on Lake Camp get to camp out in a teepee, sing songs around the campfire, look at the stars, eat smore's, and feel like they're off on an adventure in the woods—when really, they're still safe and sound on the camp premises. This is to get the campers comfortable with the idea of not spending the night in their bunks.<br><br>
As they get older, they begin taking overnight trips to the beautiful Adirondacks where they will spend time hiking, rock climbing, rappelling, and camping—all while also learning about the endless varieties that nature has to offer. These trips get progressively more adventurous as the campers become more mature, but every trip is lead by outdoor adventure specialists who have been vigorously trained. All adventure staff are also certified lifeguards by The American Red Cross, trained to the ACCT Challenge Course Practioner standards, and trained in single pitch climbing & anchors building."

        form.submit

        if agent.page.body.include?("has been posted successfully")
          puts "Successfully submitted job!"
          job_posting = college.job_postings.new(title: title, company: company, desta_url: desta_url)
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
        puts "Error: No 'New Job' link found"
        missing_post_new_job_link += 1
        puts "Jobs NOT successfully posted: #{not_successfully_submited}"
      end
    end

    puts "\n---------------- Job Posting Results ----------------"
    puts "Jobs successfully submitted: #{successfully_submited}"
    puts "Jobs NOT successfully submitted: #{not_successfully_submited}"
    puts "College homepages missing 'new job' link: #{missing_post_new_job_link}"
    puts "Skipped because job has already been posted for this college: #{duplicate_job_posting_for_college}"
    puts "---------------- Job Posting Results ----------------"
    puts "\n"
    puts "************** Shutting down bot **************"
  end





  desc "Pull passwords from email and save them to matching college"
  task pull_passwords_from_email: :environment do
    start_date = "2016-03-03"
    end_date = "2016-03-06"


    puts "Connecting to Gmail............."
    gmail = Gmail.connect!(ENV["GMAIL_EMAIL_ADDRESS"], ENV["GMAIL_PASSWORD"])
    p "Results: "
    p gmail.inspect
    puts "\n"

    updated_colleges = 0
    skipped_colleges = 0
    colleges_without_password_in_db_but_not_saved = 0
    emails_with_collge_url_but_without_found_password = 0
    emails_without_college_url = 0

    puts "Getting messages from #{start_date} to #{end_date}"
    messages = gmail.inbox.find(after: Date.parse(start_date), before: Date.parse(end_date))

    puts "Found #{messages.count} messages\n"

    puts "Iterating over all messages for password and url......."
    messages.each_with_index do |message, index|
      puts "--------- message #{index + 1} / #{messages.count} ---------"
      puts "Looking for a College URL in message body......."
      search_result = /<p><a href=\"(.*)\">https/.match(message.body.raw_source)

      if search_result
        college_url = search_result[1]

        puts "College URL found: #{college_url}"

        puts "Looking up College in databse......"
        college = College.find_by_home_url(college_url)

        if college
          puts "Found matching College with code: #{college.code}"
          if college.password
            skipped_colleges += 1
            puts "College already has a password set with '#{college.password}'"
            puts "Skipped colleges: #{skipped_colleges}"
          else
            puts "Looking for password in message body......."
            password = /Your Password is: <b>(.*)<\/b>/.match(message.body.raw_source)[1]

            if password
              puts "Found password in message body: #{password}"
              puts "Saving password to College in database"
              college.password = password
              if college.save
                updated_college =+ 1
                puts "College saved with new password"
                puts "Updated colleges: #{updated_colleges}"
              else
                colleges_without_password_in_db_but_not_saved += 1
                puts "!!!!!!!!!! College NOT saved with new password. Not sure why !!!!!!!!!!!!!!!"
                puts "Colleges with not saved: #{colleges_without_password_in_db_but_not_saved}"
              end
            else
              emails_with_collge_url_but_without_found_password += 0
              puts "College found, but didn't find password in message body"
              puts "Partial message is: \n\n#{message.body.raw_source.slice(0..100)}\n\n"
              puts "Emails with college url found but no password in body: #{emails_with_collge_url_but_without_found_password}"
            end
          end

        else
          puts "Didn't find college in databse that matched #{college_url}"
        end
      else
        emails_without_college_url += 1
        puts "Didn't find a College URL in message body"
        puts "Partial message is: \n\n#{message.body.raw_source.slice(0..100)}\n\n"
        puts "Emails without college URL: #{emails_without_college_url}"
      end
        puts "--------------------------------------"
    end

    puts "\n\n************* Task Results *************"
      puts "Registered colleges: #{College.all.count}"
      puts "Approved colleges w/passwords: #{College.where.not(password: nil).count}"
      puts "Colleges without passwords: #{College.where(password: nil).count}"
      puts "Emails searched: #{messages.count}"
      puts ""
      puts "Colleges with updated passwords: #{updated_colleges}"
      puts "Colleges skipped because password already present: #{skipped_colleges}"
      puts "College URL & password found in email, password NOT in db, but password not saved: #{colleges_without_password_in_db_but_not_saved}"
      puts ""
      puts "Emails with college URL, but no password found: #{emails_with_collge_url_but_without_found_password}"
      puts "Emails without a college URL: #{emails_without_college_url}"
    puts "************* Task Results *************\n\n"
  end
end
