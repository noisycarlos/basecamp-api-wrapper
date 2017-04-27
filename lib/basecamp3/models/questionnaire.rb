class Basecamp3::Questionnaire < Basecamp3::Model
  include Basecamp3::Concerns::Creatorable
  include Basecamp3::Concerns::Bucketable

  attr_accessor :id,
                :status,
                :created_at,
                :updated_at,
                :name,
                :questions_count

  def self.find(bucket_id, id)
    Basecamp3.request.get("/buckets/#{bucket_id}/questionnaires/#{id}", {}, Basecamp3::Questionnaire)
  end
end