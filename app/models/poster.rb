class Poster < ActiveRecord::Base

  # Set posting limit with number_of_postings
  def self.post_to_college_central_network(job)
    number_of_postings = 400#limits postings while testing

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

      unless form
        puts "Missing Login Form. Probably the school shut down their account"
        next
      end

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

    jobs[2] = {
      title: "River Guide",
      company: "Oregon River Experiences",
      desta_url: "desta.co\/job\/o-r-e-river-guide",
      salary: "$75 - $150 a day",
      location_wanted: ["OR"],
      region: "Beavercreek",
      location_zip: "97004",
      interest_1_wanted: "88",
      interest_2_wanted: "43",
      interest_3_wanted: "117",
      special_skills: "Love having fun, people and the outoors",
      contact_name: "Joe Ewing",
      contact_email: "joe@desta.com",
      contact_phone: "303-519-9391",
      company_addr1: "18074 S Boone Ct",
      company_addr2: "",
      company_city: "Beavercreek",
      company_state: "OR",
      company_zip: "97004",
      expire_date: "06\/20\/2016",

      job_description: "https:\/\/desta.co/job/o-r-e-river-guide <br><br>
      Founded in 1978, Oregon River Experiences conducts half day to nine day whitewater raft trips on ten rivers in Oregon and Idaho. One of the Northwest’s premier outfitters, O.R.E.’s participatory raft trips focus on experiential learning and personal involvement. We employ guides who possess the work ethic, maturity, social aptitude, integrity, leadership skills, and whitewater boating skills necessary to conduct high quality river trips.<br><br>

      General responsibilities:<br>
      Conduct high quality, safe river trips<br>
      Treat guests and fellow O.R.E. employees with courtesy and respect<br>
      Contribute to a positive, supportive team atmosphere<br>
      Arrive to work promptly as scheduled<br>
      Drive company vehicles safely<br>
      Keep vehicles clean and detect mechanical problems<br>
      Promote sales of future trips as appropriate<br>
      Comply with terms of employment contract<br>
      Conform to company policies as described in the O.R.E. Guide’s Handbook<br><br>

      Additional duties include the following:<br>
      Engage guests in friendly conversation both on and off the river<br>
      Cook all the meals on the O.R.E. menu, taking the lead in the kitchen as appropriate<br>
      Rig and de-rig an oar and paddle rafts in a safe and timely manner<br>
      Pack equipment carefully, and unpack, clean and put away all trip gear after trip<br>
      Participate in any on-river guide meetings, as well as post-trip guide de briefings<br>
      On multi-day trips, lead hikes and/or other activities to enrich our guests’ time with us<br>
      On multi-day trips, present short interpretive presentations to guests<br>
      On day trips, perform land support duties as requested (shuttles, photography, lunch prep)<br>
      ",
    }

    jobs[3] = {
      title: "Alaskan Outdoor Guide",
      company: "Kodiak Raspberry Island Remote Lodge",
      desta_url: "desta.co\/job\/guide-kodiad-raspberry-island-remote-lodge",
      salary: "$2,850.00/mo + Tips + Room & Board",
      location_wanted: ["AK"],
      region: "Kodiak",
      location_zip: "99615",
      interest_1_wanted: "88",
      interest_2_wanted: "43",
      interest_3_wanted: "117",
      special_skills: "Love having fun, people and the outoors",
      contact_name: "Joe Ewing",
      contact_email: "joe@desta.com",
      contact_phone: "303-519-9391",
      company_addr1: "PO Box 888 Kodiak",
      company_addr2: "",
      company_city: "Kodiak",
      company_state: "AK",
      company_zip: "99615",
      expire_date: "06\/20\/2016",

      job_description: "https:\/\/desta.co/job/o-r-e-river-guide <br><br>
      The Guide Position is a combination of two sub-positions, each starting at 8:00am, and concluding at 6:00pm. First, the Guide will primarily be in charge of any kayaking and or hiking expeditions, and secondly, if the lodge doesn’t have kayakers/hikers scheduled, the guide will work as a deckhand on the boat. Lastly, the Guide will be prepared and available for ‘other duties as assigned,’ as needed.<br><br>
The Kayaking and Hiking Guide’s focus will be on taking our guests interested in those activities out on such trips, and support and follow-through of those day’s programs. Guests are typically ready for their day of activities between 8:30 and 9am. This position is client-to-guide relationship intensive--you must start ‘guiding’ right away. Our guests vary in physical ability and experience level, so be prepared to mold the experience you will offer your participants to their ability and enthusiasm. Be prepared to teach the participants every aspect of the trip they are on--how to put on a kayak skirt properly, how to hold a paddle and stroke properly, how to dress properly based on the weather and the type of trip you are taking them on. Be prepared to answer questions regarding the locale; the flora, fauna, and other questions relating to the weather, tides, geography, etc. Be prepared to educate and position the group for good photographs. We do not expect you to know every answer but have the resources here so you can gather the majority of the information you’ll need to provide an educational and rewarding experience to your participants.<br><br>
The weather here is predictable to a degree. You will need to make decisions based on the safety of the group and our equipment that may conflict with your participant’s immediate goals. You will be guiding in bear country and will need to be comfortable with every stage of a bear encounter, including contact. We can teach you this, but if you’re terrified of bears or the water, this is not the job for you. If you are terrified of bears or the water and want this job to overcome your fear, this is not the job for you. Trips nearly always start and finish here at the lodge. Rare exceptions will involve a boat drop off and/or pick up. There are a variety of trails, almost always game trails, that go up the mountain behind the lodge or along the coast. There are a variety of kayak experiences that start from the lodge here, as well, and will always very as the tide comes in and goes out. Though we have a very gentle current, water height variation between high and low tides may be as much as 24 feet. It is also common to paddle a ways, get out, and enjoy some time on a local beach, or walk/hike from there. We require guides and guests return to the lodge by 5:00pm. In some cases guests will wish to either depart the lodge later in the morning or return to the lodge earlier in the evening. It is imperative that the Guide remains “guiding,” or “in charge” of his or her group of guests until 5:30pm; the remaining team at the lodge does not have room in their schedule to interact with the guests. The lodge itself is also closed from 1:00 p.m. to 4:00 p.m. Guides are expected to keep our equipment well maintained, clean, and ready for the next day’s activities.<br><br>
The Deckhand Position will assist the boat captains and fishing/boating operations. While the position will mostly be filled on the Gemini with Birch as captain, the deckhand may be a) ‘leant’ to another boat captain/boat operating out of KRIRL, or b) dropped off with a group on shore to guide shore fishermen alone (fly fishermen/spin fishermen, likely targeting Salmon). Guests typically board the Gemini and other fishing boats at 8:30am give or take 15 minutes. Birch/captain will prep engines and bring the boat into the beach, while the guide stands by on the beach to help outfit clients in boots/rain gear/etc and board the boat. Daily guiding/deck handing duties will include interacting with clients, answering questions, and working the fishing gear. This will include gear preparation and readiness, hook baiting, fish landing, boat cleaning, crab pot pulling, preparation, crab cleaning, etc. Fishing boats return to the lodge typically around 5:30pm, at which point they will pull into the beach and drop off the clients, fish, and lunch bag, etc. The captain will return the boat to the mooring and deckhand will finish any boat cleanup and next day preparation while captain fills out the logs, etc.<br><br>
On both kayaking/hiking guide days as well as deckhand days, the guide is expected to help outfit our guests in rain gear, boots, etc as needed at 8:00 a.m. and to help load the boat in the morning, as well as meet the boat on the beach at day’s end to help unload, clean, and prep the boat when the boat returns to the mooring.",
    }

    # set job
    current_job = jobs[2]
    puts "Current Job is set to: #{current_job[:title]}"

    return  current_job
  end

end
