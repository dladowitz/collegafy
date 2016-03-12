class SavePasswordsController < ApplicationController
# This was turned into a rake task


  # gmail gem: https://github.com/gmailgem/gmail
  # Need to enable lower security for gmail: https://www.google.com/settings/u/2/security/lesssecureapps

#   def index
#     puts "Connecting to Gmail............."
#     gmail = Gmail.connect!(ENV["GMAIL_EMAIL_ADDRESS"], ENV["GMAIL_PASSWORD"])
#     p "Results: "
#     p gmail.inspect
#     puts "\n"
#
#     start_date = "2016-02-29"
#     end_date = "2016-03-04"
#
#     puts "Getting messages from #{start_date} to #{end_date}"
#     messages = gmail.inbox.find(after: Date.parse(start_date), before: Date.parse(end_date))
#
#     puts "Found #{messages.count} messages\n"
#
#     puts "Iterating over all messages for password and url......."
#     messages.each do |message|
#       puts "--------------------------------------"
#       puts "Looking for a College URL in message body......."
#       search_result = /<p><a href=\"(.*)\">https/.match(message.body.raw_source)
#
#       if search_result
#         college_url = search_result[1]
#
#         puts "College URL found: #{college_url}"
#
#         puts "Looking up College in databse......"
#         college = College.find_by_home_url(college_url)
#
#         if college
#           puts "Found matching College with code: #{college.code}"
#           if college.password
#             puts "College already has a password set with '#{college.password}'"
#           else
#             puts "Looking for password in message body......."
#             password = /Your Password is: <b>(.*)<\/b>/.match(message.body.raw_source)[1]
#
#             if password
#               puts "Found password in message body: #{password}"
#               puts "Saving password to College in database"
#               college.password = password
#               if college.save
#                 puts "College saved with new password"
#               else
#                 puts "College NOT saved with new password. Not sure why"
#               end
#             else
#               puts "Didn't find password in message body"
#               puts "Partial message is: \n\n#{message.body.raw_source.slice(0..100)}\n\n"
#             end
#           end
#
#         else
#           puts "Didn't find college in databse that matched #{college_url}"
#         end
#       else
#         puts "Didn't find a College URL in message body"
#         puts "Partial message is: \n\n#{message.body.raw_source.slice(0..100)}\n\n"
#       end
#         puts "--------------------------------------"
#     end
#   end
end
