namespace :run_bot do

  # Make sure you set the correct job and posting limit
  desc "posts a specifc job to college central job network"
  task post_to_college_central: :environment do
    puts "!!!!!!!!!!!!!!!!!! Make sure you set the correct job and posting limit !!!!!!!!!!!!!!!!!\n"
    job = Poster.current_job

    Poster.post_to_college_central_network(job)
  end





 # Use this instead of old SavePasswordsController
 # gmail gem: https://github.com/gmailgem/gmail
 # Need to enable lower security for gmail: https://www.google.com/settings/u/2/security/lesssecureapps
  desc "Pull passwords from email and save them to matching college"
  task pull_passwords_from_email: :environment do
    start_date = "2016-03-19"
    end_date = "2016-04-02"


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
                updated_colleges += 1
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












  desc "logs in to job boards and gets view count"
  task get_job_stats: :environment do
    job_postings = JobPosting.all

    job_postings.each_with_index do |job_posting, index|
      puts "--------- job postings #{index + 1} / #{job_postings.count} ---------"


    end



    puts "\n---------------- Job Posting Results ----------------"
    puts "Total Job Postings: #{job_postings.count}"

    puts "\n"
    puts "************** Shutting down bot **************"
  end





end
