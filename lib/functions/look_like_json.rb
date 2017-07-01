module LookLikeJSON
  def method_missing(meth, *args, &block)
  	if  has_key?(meth.to_sym)
  		self[meth.to_sym]
    elsif has_key?(meth.to_s)
      self[meth.to_s]
    else
      raise NoMethodError, "undefined method #{meth} for #{self}"
    end
  end
end