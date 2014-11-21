# -*- encoding : utf-8 -*-
class Hash
#  alias :__fetch :[]

#  def traverse(*path)
#    path.inject(self) { |obj, item| obj.__fetch(item) || break }
#  end

#  def [](*args)
#    (args.length > 1) ? traverse(*args) : __fetch(*args)
#  end

  def to_downcase
    self.inject({}){|h, v| h[v[0]]=v[1].is_a?(String) ? v[1].downcase : v[1] ; h}
  end
end
