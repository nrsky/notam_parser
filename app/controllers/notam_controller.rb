class NotamController < ApplicationController

  skip_before_action :verify_authenticity_token

  #TODO Put proper file max size
  ADDRESS_BOOK_FILE_SIZE = 5000000

  def index
    render(:template => 'layouts/notam')
  end

  def load_notam
    if (params[:file]) && (params[:file].size < ADDRESS_BOOK_FILE_SIZE)
      file  = params[:file]
      @parsed_data = NotamParseService.new.process_notam file
      respond_to do |format|
        format.html { render :partial => "notam/show_table.html" }
      end
    else
      raise "#{params} Params are empty or size is too big"
    end
  end
end