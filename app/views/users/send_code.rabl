object false
  if @state == 'success'
    node(:result) {0}
    node(:message) {'Success'}
    node(:is_new){ @is_new }
    node(:time) {Time.now}
  else
    node(:result) {1}
    node(:message) {'Error'}
    node(:errors) {@errors}
  end
