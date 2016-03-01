class CodeChecksController < ApplicationController
  def index

    start = 1600  
    stop = 10000
    school_codes = code_range(start, stop)

    if params[:run_checks] == "on"
      College.mass_registration(school_codes, start)
    end

    @code_checks = CodeCheck.all
    @colleges = College.all
  end


  private

  def code_range(start, stop)
    # count = 17576
    all_codes = ('aaa'..'zzz').to_a.uniq
    return all_codes[start..stop]

  end
end
