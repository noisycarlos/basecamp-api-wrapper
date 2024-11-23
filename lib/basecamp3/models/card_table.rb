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

  # @return [string]
  def self.etag(bucket, board)
    uri = "/buckets/#{bucket}/card_tables/#{board}"
    response = Basecamp3.request.head(uri)
    response['etag']
  end

  # @return [Basecamp3::CardTable[] ]
  def self.all
    project_list = []
    1000.times do |page|
      projects = Basecamp3::Project.all(page: page)
      projects.each do |proj|
        project_list << proj
      end
      break if projects.count < 15
    end

    res = []
    project_list.each do |project|
      boards = Basecamp3::CardTable.in_project(project.id)
      boards.each do |board|
        next unless board['name'] == 'kanban_board'

        board['project'] = project
        res << board
      end
    end
    res
  end

  # @return [Basecamp3::CardTable[] ]
  def self.in_project(project)
    uri = "/projects/#{project}"
    response = Basecamp3.request.get(uri, {}, Basecamp3::Project)
    response.dock
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
