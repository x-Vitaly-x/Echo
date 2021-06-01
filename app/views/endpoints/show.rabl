# app/views/endpoints/show.rabl
object :@endpoint, :root => "data"

attributes :id
node :type do
  'endpoints'
end
node :attributes do |endpoint|
  endpoint.filtered_attributes
end
