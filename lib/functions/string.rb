class String
  def is_i?
 		/\A[-+]?\d+\z/ === self
  end

  def handle
		self.downcase.gsub(/[^\w\u00C0-\u024f]+/, "-").gsub(/^-+|-+$/, "");
  end
end