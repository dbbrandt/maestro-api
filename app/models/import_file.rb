class ImportFile < ApplicationRecord
  attr_accessor :csv_file

  validates_presence_of :title
  validates_presence_of :json_data

  default_scope { order(:title)}

  belongs_to :goal, required: true
  has_many :import_rows, dependent: :destroy

  # Create all the import_rows from the json_data
  # Return true if rows were created
  def create_rows
    # Once rows are created from the json_date they cannot be recreated to avoid possible duplication.
    return false if import_rows.size > 0
    rows = JSON.parse(json_data)
    logger.info "Import File: creating #{rows.count} import rows."
    # account for title row
    row_count = 2
    import_errors = []
    added_rows = []
    rows.each do |row|
      # new_row = ImportRow.new(import_file_id: import_file_id, title: row["title"], json_data: row.to_json)
      new_row = ImportRow.new(import_file: self, title: row["title"], json_data: row.to_json)
      logger.info "Create Rows: creating row #{row_count} with title #{new_row.title}."
      if new_row.valid?
        added_rows << new_row
      else
        logger.error "Create Rows: error on row #{row_count}: #{new_row.errors.full_messages}."
        import_errors << { "Row #{row_count}": new_row.errors.full_messages.join(",") }
      end
      row_count += 1
    end
    import_errors = validate_rows(import_errors,added_rows)
    logger.error "Create Rows: row creation aborted. #{import_errors.count} validation errors."
    if import_errors.empty?
      save_rows(added_rows)
    else
      import_errors << { "Rows #{row_count-1}": "Import rows not created. #{import_errors.count} validation errors." }
    end
    #reload
    import_errors
  end

  # Perform cross row validations like custom uniqueness constraints
  def validate_rows(errors, rows)
    errors = errors
    titles = {}
    title = rows.each_with_index  do |row, index|
      titles[row.title] = titles[row.title].to_i + 1
      errors << { "Row #{index + 2}": "title must be unique. Duplicate value: #{row.title}" } if titles[row.title] > 1
    end
    # Resort the errors which got appeneded. The format of the errors requires conversion from a symbol to integer
    errors.sort_by { |hsh| hsh.keys[0].to_s.sub("Row ","").to_i }
  end

  def save_rows(rows)
    ImportFile.transaction do
      rows.each_with_index do   | row, index|
        logger.debug "Save Rows: Saving. #{index} rows: #{row.title}."
        import_rows.create!(title: row.title, json_data: row.json_data)
      end
    end
  end

  # Delete all rows not associated with an interaction
  # Return true if all rows deleted.
  def delete_rows
    return true if import_rows.size == 0
    import_rows.each do |row|
      row.destroy unless row.interaction
    end
    reload
    return import_rows.size == 0
  end

  # for each import_rows in the import_file, insert or update based on the title
  def generate_interactions
    insert_errors = []
    ImportFile.transaction do
      import_rows.each do |row|
        interaction = generate_interaction(row)

        if interaction
          prompt = generate_prompt(interaction, row)
          if prompt
            (1..4).each do |number|
              if json_criterion(row, number)
                criterion = generate_criterion(interaction, row, number)
                unless criterion
                  insert_errors << {content: "Criterion #{number} row not created for row_id: #{row.id}"}
                end
              end
            end
          else
            insert_errors << {content: "Prompt row not created for row_id: #{row.id}"}
          end
        end
      end
      raise ActiveRecord::Rollback unless insert_errors
    end
    insert_errors
  end

  def generate_interaction(row)
    interaction = Interaction.where(goal_id: goal_id, import_row_id: row.id).first
    if interaction
      interaction.update(title: row.title, answer_type: row.json["answer_type"])
      interaction.contents.delete_all
    else
      interaction = goal.interactions.create!(title: row.title, answer_type: row.json["answer_type"], import_row_id: row.id)
    end
  end

  def generate_prompt(interaction, row)
    interaction.contents.create!(title: row.json["title"], content_type: 'Prompt', copy: row.json["prompt"])
  end

  def generate_criterion(interaction, row, number)
    interaction.contents.create!(json_criterion(row, number))
  end

  def json_criterion(row, number)
    unless row.json["criterion#{number}"].blank?
      # Default copy to criterion if blank.
      copy = row.json["copy#{number}"].blank? ? row.json["criterion#{number}"] : row.json["copy#{number}"]
      {title: row.json["title"], content_type: 'Criterion', copy: copy ,
       descriptor: row.json["criterion#{number}"], score: row.json["points#{number}"]}
    end
  end
end
