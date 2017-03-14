module UnembeddedHelper

	def svgs(svg)
		render partial: 'svgs', locals: {icon: svg}
	end

	def panel(panel)
		render partial: 'unembedded/panels/' + panel
	end

end