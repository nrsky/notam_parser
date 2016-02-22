require 'rails_helper'

describe NotamParseService do
  #TODO add missing tests
  #TODO extract mock data

  it '#find_record' do
    rec = [:MON, ['23:50']]
    expect(NotamParseService.new.send(:find_record, rec)).to eq([['23:50']])
  end

  it '#get_full_days' do
    arr = ['MON', 'FRI']
    expect(NotamParseService.new.send(:get_full_days, arr)).to eq(['MON', 'TUE', 'WED', 'THU'])
  end

  it '#parse_days' do
    e_section_data = ["MON-WED", "0500-1830", "THU", "0500-2130", "FRI", "0730-2100", "SAT", "0630-0730", "1900-2100", "SUN", "CLOSED"]
    result = NotamParseService.new.send(:parse_days, e_section_data)
    expect(result).to include(:FRI => ["0730-2100"])
    expect(result).to include(:SAT => ["0630-0730", "1900-2100"])
  end

  #TODO mock_data extract to fixtures
  it '#build_view_data' do
    mock_data  = [{:e_section=>{:MON=>["0500-1830"], :TUE=>["0500-1830"], :THU=>["0500-2130"], :FRI=>["0730-2100"], :SAT=>["0630-0730", "1900-2100"], :SUN=>["CLOSED"]}, :a_section=>" ESGJ "},
                  {:e_section=>{:MON=>["0500-2000"], :TUE=>["0500-2100"], :WED=>["0500-2100"], :THU=>["0500-2100"], :FRI=>["0545-2100"], :SUN=>["1215-2000"]}, :a_section=>" ESGJ "},
                  {:e_section=>{:MON=>["0445-2115"], :TUE=>["0500-2130"], :WED=>["0500-2300"], :THU=>["0500-2300"], :FRI=>["0500-2300", "0500-2115"], :SAT=>["0715-1300"], :SUN=>["1115-2145"]}, :a_section=>" ESNN "},
                  {:e_section=>{:MON=>["0500-2215"], :TUE=>["0500-2130"], :WED=>["0500-2300"], :THU=>["0500-2300"], :FRI=>["0500-2300", "0500-2015"], :SAT=>["1100-1300"], :SUN=>["1115-2300"]}, :a_section=>" ESNN "},
                  {:e_section=>{:MON=>["0500-2215"], :TUE=>["0500-2130"], :WED=>["0500-2300"], :THU=>["0500-2300"], :FRI=>["0500-2300", "0500-1830"], :SAT=>["1100-1300"], :SUN=>["1115-2145"]}, :a_section=>" ESNN "},
                  {:e_section=>{:MON=>["0430-2130"], :TUE=>["0430-2130"], :THU=>["0430-2215"], :FRI=>["0445-2130"], :SAT=>["CLSD"], :SUN=>["1030-1900"]}, :a_section=>" ESNO "},
                  {:e_section=>{:MON=>["0530-2030"], :TUE=>["0530-2230"], :WED=>["0530-2230"], :THU=>["0530-2315"], :FRI=>["0545-2230"], :SAT=>["CLSD"], :SUN=>["1130-2000"]}, :a_section=>" ESNO "},
                  {:e_section=>{:MON=>["0515-2145"], :WED=>["0515-2255"], :THU=>["0515-2255"], :FRI=>["0515-2255", "0515-2145"], :SAT=>["0645-1845"], :SUN=>["0645-2145"]}, :a_section=>" ESNZ "},
                  {:e_section=>{:MON=>["0530-2115"], :TUE=>["0530-2115"], :WED=>["0530-2115"], :FRI=>["0530-2000"], :SAT=>["0730-1600"], :SUN=>["1000-2115"]}, :a_section=>" ESSV "},
                  {:e_section=>{:MON=>["0530-2115"], :TUE=>["0530-2115"], :WED=>["0530-2115"], :FRI=>["0530-2000"], :SAT=>["0730-1830"], :SUN=>["0730-2115"]}, :a_section=>" ESSV "}]
    result = NotamParseService.new.send(:build_view_data, mock_data)
    expect(result.count).to eq(10)
    expect(result[0]).to eq([" ESGJ ", "0500-1830", "0500-1830", "0500-2130", "0730-2100", "0630-0730, 1900-2100", "CLOSED"])
  end
end