# A model for Basecamp's Project (Basecamp)
#
# {https://github.com/basecamp/bc3-api/blob/master/sections/basecamps.md#basecamps For more information, see the official Basecamp3 API documentation for Basecamps}
class Basecamp3::CardTable < Basecamp3::Model
  REQUIRED_FIELDS = %w[title]
  attr_accessor :id,
                :status,
                :created_at,
                :updated_at,
                :title,
                :type,
                :url,
                :visible_to_clients,
                :inherits_status,
                :app_url,
                :bookmark_url,
                :subscription_url,
                :position,
                :bucket,
                :creator,
                :subscribers,
                :lists

  # @return [Basecamp3::CardTable]
  def self.find(bucket, board)
    uri = "/buckets/#{bucket}/card_tables/#{board}"
    Basecamp3.request.get(uri, {}, Basecamp3::CardTable)
  end

  # https://3.basecamp.com/5456546/buckets/30299287/card_tables/5561609809
  def self.from_url(url)
    uri = URI.parse url
    parts = uri.path.split '/'
    res = {}
    res[:account] = parts[1]
    res[:bucket] = parts[3]
    res[:board] = parts.last
    res
  end

  # @return [string]
  def self.etag(card_table_board)
    uri = "/buckets/#{card_table_board.bucket}/card_tables/#{card_table_board.board}"
    response = Basecamp3.request.head(uri)
    response['etag']
  end

  # @return [Basecamp3::CardTable[] ]
  def self.all
    project_list = Basecamp3::Project.all
    res = []
    project_list.each do |project|
      boards = Basecamp3::CardTable.in_project(project.id)
      res.concat(boards)
    end
    res
  end

  # @return [Basecamp3::CardTable[] ]
  def self.in_project(bucket)
    uri = "/projects/#{bucket}"
    project = Basecamp3.request.get(uri, {}, Basecamp3::Project) # Might need to iterate through api pagination
    res = []
    boards = project.dock
    return res if boards.nil?

    boards.each do |board|
      next unless board['name'] == 'kanban_board'

      board['project'] = project
      res << board
    end
    res
  end

  def self.cards_in_column(column)
    uri = "buckets/#{column['bucket']['id']}/card_tables/lists/#{column['id']}/cards"
    cards = Basecamp3.request.get(uri, {}, Basecamp3::Card) # Might need to iterate through api pagination
    return cards if cards.present?

    nil
  end

  def self.columns_in_board(card_table_board)
    uri = "buckets/#{card_table_board.bucket}/card_tables/#{card_table_board.board}"
    board = Basecamp3.request.get(uri, {}, Basecamp3::CardTable) # Might need to iterate through api pagination

    return board if board.present?

    nil
  end

  # Creates a project.
  #
  # @param [Hash] data the data to create a project with
  # @option params [String] :name (required) the name of the project
  # @option params [String] :description (optional) the description of the project
  #
  # @return [Basecamp3::Project]
  def self.create(data)
    validate_required(data)
    Basecamp3.request.post('/projects', data, Basecamp3::Project)
  end

  # Updates the project.
  #
  # @param [Integer] id the id of the project
  # @param [Hash] data the data to update the project with
  # @option params [String] :name (required) the name of the project
  # @option params [String] :description (optional) the description of the project
  #
  # @return [Basecamp3::Project]
  def self.update(id, data)
    validate_required(data)
    Basecamp3.request.put("/projects/#{id}", data, Basecamp3::Project)
  end

  # Deletes the project.
  #
  # @param [Integer] id the id of the project
  #
  # @return [Boolean]
  def self.delete(id)
    Basecamp3.request.delete("/projects/#{id}")
  end
end
