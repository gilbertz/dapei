json.id @selfie.id
json.photo @selfie.photos do |photo|
  json.id photo.id
  json.path photo.processed_image
end
