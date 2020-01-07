class ImportRowValidator < ActiveModel::Validator
  def validate(record)

    #TODO insure title is unique for the import file

    record.errors.add(:title, "can't be blank") if record.title.blank?

    json = record.json_data

    if json.blank?
      record.errors.add(:json_data, "can't be blank")
      return
    end

    duplicate = ImportRow.where(import_file_id: record.import_file_id, title: record.title).first
    # if update, ignore the record getting updated
    if duplicate and duplicate.id != record.id
      record.errors.add(:title, "must be unique. Duplicate value: #{record.title}")
      return
    end

    begin
      row = JSON.parse(json)
    rescue JSON::ParserError
      record.errors.add(:json_data, 'invalid json - parse error')
      return
    end

    record.errors.add(:prompt, "can't be blank: #{record.title}.") if row["prompt"].blank?

    if row["answer_type"].blank? or !(Interaction::TYPES.include?(row["answer_type"]))
      record.errors.add(:answer_type, "must be a valid type (#{Interaction::TYPES.to_s}): #{record.title}")
    end

    if row["criterion1"].blank? or row["points1"].nil?
      record.errors.add(:criterion, ": At least one complete criterion (criterion1 and points1) is required: #{record.title}")
    end

    total_points = row["points1"].to_i + row["points2"].to_i + row["points3"].to_i + row["points4"].to_i

    record.errors.add(:points, ": At least one criterion is required to have points: #{record.title}") if total_points == 0
    end
end
