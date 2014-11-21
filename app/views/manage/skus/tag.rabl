object false
collection @tags, :object_root => false, :root => false

node(:id){|tag| tag.name}
node(:label){|tag| tag.name}
node(:value){|tag| tag.name}