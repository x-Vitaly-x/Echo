# app/views/endpoints/index.rabl
collection :@endpoints, :root => "data"

attributes :id
node :type do
  'endpoints'
end
node :attributes do |endpoint|
  endpoint.filtered_attributes
end
