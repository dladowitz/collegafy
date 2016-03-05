# == Schema Information
#
# Table name: colleges
#
#  id         :integer          not null, primary key
#  code       :string
#  access_id  :string
#  password   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  home_url   :string
#
class College < ActiveRecord::Base
  validates :code, :access_id, :home_url, presence: true
  has_many :job_postings

  def self.mass_registration(school_codes, start_index)
    code_count = 0
    @registered_schools = 0

    puts "School code range: #{school_codes}."

    school_codes.each do |school_code|
      puts "----------------------------------------------------"
      registration_options = College.register_for_school(school_code)
      code_count += 1

      if registration_options
        College.confirm_registration(registration_options)
      end

      puts "Registration try finished."
      puts "Current run results:"
      puts "On school number #{start_index} of 17576"
      puts "Schools checked: #{code_count}"
      puts "New registrations: #{@registered_schools}"
      puts "----------------------------------------------------\n\n"
      start_index += 1
    end
  end

  def self.register_for_school(univ_code)
    agent = Mechanize.new

    puts "Getting URL for school: #{univ_code}."
    agent.get "https://www.collegecentral.com/CCNEngine/EmployersJobs/EmpRegForm.CFM?UnivCode=#{univ_code}"

    puts "Checking for valid url."


    if College.valid_url?(agent, univ_code)
      puts "Filling out form.."

      form = agent.page.forms.first
      form.ContactName = "David Ladowitz"
      form.CompanyName = "Desta"
      form.CompanyAddr1 = "777 ash street #309"
      form.CompanyCity = "Denver"
      form.CompanyState = "CO"
      form.CompanyZip = "08220"
      form.CompanyPhone = "408 666 4411"
      form.CompanyEMail = "david@desta.co"
      form.CompanyURL = "desta.co"
      form.CompanyDesc = "Dests helps people who love the outdoors find summer & winter jobs. We specialize in rafting, climbing, skiing, summer camps, hiking, guiding and national parks."
      form.EEOC = "dl"
      form.checkboxes.first.checked = true
      form.Industry = ["11", "47", "59"]
      form.AccessID = "dladowitz"

      # Saving as these variables disappear after submitting
      registration_options = {agent: agent, code: form['UnivCode'], access_id: form.AccessID, home_url: agent.page.links.last.href}

      puts "Submitting form"
      form.submit

      puts "Form submitted"
      puts "Univ Codes Checked: #{CodeCheck.count }"

      return registration_options
    else
      return nil
    end
  end

  def self.confirm_registration(registration_options)
    if registration_options[:agent].page.body.include? "Thank you for registering"
      College.create(code: registration_options[:code], access_id: registration_options[:access_id], home_url: registration_options[:home_url])
      puts "!!!!!!!! Registration confirmed for #{registration_options[:code]} !!!!!!!!!!!"
      puts "!!!!!!!! School Resistered is: #{registration_options[:home_url]} !!!!!!!!!!!!"
      @registered_schools += 1

    else
      puts "Does not compute. Registration failure."
    end
  end

  def self.valid_url?(agent, univ_code)
    code_check = CodeCheck.new(code: univ_code)

      if agent.page.body.include? "ContactName"
      code_check.valid_univ_code = true
      puts "URL is valid, found 'ContactName' field."
      puts "School home URL is: #{agent.page.links.last.href}"
      if code_check.save
        return true
      else
        puts "Error: #{code_check.errors.full_messages}"
        return true
      end
    else
      code_check.valid_univ_code = false
      puts "URL is no good, :("
      if code_check.save
        return false
      else
        puts "Error: #{code_check.errors.full_messages}"
        return false
      end
    end
  end
end
