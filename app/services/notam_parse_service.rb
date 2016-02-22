class String
  def string_between_markers marker1, marker2
    self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
  end

  def string_with_optional_marker marker1
    self[/#{Regexp.escape(marker1)}(-?)/m, 1]
  end
end

class NotamParseService

  DAYS = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']

  #TODO assumption: we don't need to process with the highest speed and won't use benchmarks.
  # I've decided to write the code by 'easier to read' ctiteria
  def process_notam(file)
    notam_records = split_file_to_notam_blocks(file)
    result_records = []
    notam_records.each do |notam_record|
      result_record = {}
      e_section_str = notam_record.string_between_markers('AERODROME HOURS OF OPS/SERVICE', 'CREATED')
      #TODO What about a_section mandatory?
      if e_section_str.present?
        #TODO assumption that all elements separated with ' '
        e_section_arr = clean_string(e_section_str).split(' ')
        result_record[:e_section] = parse_days(e_section_arr)
        result_record[:a_section] = notam_record.string_between_markers('A)', 'B)')
        if result_record[:e_section].present?
          result_records << result_record
        end
      end
    end
    build_view_data(result_records)
  end

  private()

  def split_file_to_notam_blocks(file)
    notam_records = []
    notam_record = ""

    file.read.each_line do |line|
      notam_record = notam_record + line
      if line.blank?
        notam_records << notam_record
        notam_record = ""
      end
    end
    notam_records
  end

  def clean_string(str)
    str.tr("\n", ' ').tr('.', ' ').tr(',',' ')
  end

  #TODO extract method
  def parse_days(e_section_data)
    current_tag = ''
    result_array = {}
    e_section_data.each do |item|
     #TODO check where change symbols to str or vs
     item = item.tr(':','')
     day_tag = DAYS.any? { |day| item.string_with_optional_marker day }
     if day_tag.present?
      current_tag = item
     else
      if current_tag.include?('-')
        process_range_tag(current_tag, result_array, item)
      else
        result_array[current_tag.to_sym] ||= []
        result_array[current_tag.to_sym] << item
      end
     end
    end
    result_array
  end

  def process_range_tag(current_tag, result_array, item)
    days = get_full_days(current_tag.split('-'))
    if days.present?
      days.each do |day|
        result_array[day.to_sym] ||= []
        result_array[day.to_sym] << item
      end
    end
  end

  def get_full_days(arr)
    index_from = DAYS.index(arr[0])
    index_to = DAYS.index(arr[1])
    DAYS[index_from, index_to] if index_from.present? && index_to.present?
  end

  def build_view_data(result_records)
    view_data = []
    result_records.each do |record|
      view_record = []
      view_record << record[:a_section]
      record[:e_section].each do |rec|
        day_record = find_record(rec)
        if day_record
          view_record << day_record.join(", ")
        else
          view_record << ""
        end
      end
      view_data << view_record
    end
    view_data
  end

  def find_record(rec)
    if DAYS.include?(rec[0].to_s)
      return rec[1,rec.size-1]
    end
    false
  end
end