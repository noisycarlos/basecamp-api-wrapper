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

  def self.get_next_page_uri(response)
    puts " ---- Getting next page"
    link = response[:headers]["link"]&.first
    if link.present?
      url = link.split('<')[1].split('>')[0] 
      # puts "Url: #{url}"
      return url
    end
    nil
  rescue => e
    puts "Error getting next page: #{e}"
    return nil
  end

  def self.cards_in_column(column)
    uri = "buckets/#{column['bucket']['id']}/card_tables/lists/#{column['id']}/cards"
    cards = []
    response = Basecamp3.request.get_all(uri, {}, Basecamp3::Card)
    cards += response
    return cards if cards.present?
    nil
  end

  def self.columns_in_board(card_table_board)
    uri = "buckets/#{card_table_board.bucket}/card_tables/#{card_table_board.board}"
    response = Basecamp3.request.get_all(uri, {}, Basecamp3::CardTable) 
    board = response[:body] if response[:body].present?
    return board if board.present?
    nil
  end

  # @return [Basecamp3::CardTableColumn]
  def self.create_column(bucket, board, title)
    data = { "title": title }
    url = "buckets/#{bucket}/card_tables/#{board}/columns"
    Basecamp3.request.post(url, data, Basecamp3::CardTableColumn)
  end

  # @return [Basecamp3::CardTable]
  def self.update_card(bucket, _board, card, data)
    url = "/buckets/#{bucket}/card_tables/cards/#{card}"
    Basecamp3.request.put(url, data, Basecamp3::Card)
  end

  # @return [Basecamp3::CardTable]
  def self.move_card(bucket, card, destination_column)
    data = { "column_id": destination_column }
    url = "buckets/#{bucket}/card_tables/cards/#{card}/moves"
    Basecamp3.request.post(url, data, Basecamp3::Card)
  end

  # Creates a project.
  #
  # @param [Hash] data the data to create a project with
  # @option params [String] :name (required) the name of the project
  # @option params [String] :description (optional) the description of the project
  #
  # @return [Basecamp3::CardTable]
  def self.create(bucket, column, data)
    # data = { "title": title, "content": content, "due_on": due_on }
    Basecamp3.request.post("buckets/#{bucket}/card_tables/lists/#{column}/cards",
                           data,
                           Basecamp3::CardTable)
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
