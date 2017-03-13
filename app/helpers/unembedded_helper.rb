module UnembeddedHelper

	def svgs(svg)
		render partial: 'svgs', locals: {icon: svg}
	end

end