# A model for Basecamp's Card in a Card Table Board
#
# {https://github.com/basecamp/bc3-api/blob/master/sections/basecamps.md#basecamps For more information, see the official Basecamp3 API documentation for Basecamps}
class Basecamp3::Card < Basecamp3::Model
  REQUIRED_FIELDS = %w[title]
  attr_accessor :id,
                :updated_at,
                :created_at,
                :parent,
                :bucket,
                :description,
                :status,
                :completion_url,
                :card_type,
                :url,
                :app_url,
                :bookmark_url,
                :subscription_url,
                :content,
                :comments_url,
                :due_on,
                :title,
                :steps,
                :assignees,
                :completion_subs,
                :creator,
                :comments_count,
                :position,
                :comment_count,
                :completed,
                :inherits_status,
                :visible_to_clients,
                :sync,
                :assignee_names,
                :assignee_ids
end
