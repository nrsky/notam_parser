require 'rails_helper'

describe NotamController, :type => :controller do
  it 'index responds successfully' do
    get :index
    expect(response.status).to eq(200)
  end

  it 'load_notam expect some data to be load' do
    file_path =  File.join(Rails.root, 'spec', 'fixtures', 'notam_data.txt')
    file = mock_archive_upload(file_path, 'text')
    post :load_notam, file: file
    expect(response.status).to eq(200)
  end

  #TODO extract to FileSpecUtils
  def mock_archive_upload(archive_path, type)
    return ActionDispatch::Http::UploadedFile.new(:tempfile => File.new(Rails.root + archive_path , :type => type, :filename => File.basename(File.new(Rails.root + archive_path))))
  end
end