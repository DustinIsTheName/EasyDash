module UnembeddedHelper

	def svgs(svg)
		render partial: 'svgs', locals: {icon: svg}
	end

	def panel(panel)
		render partial: 'unembedded/panels/' + panel
	end

	def dropdown(resource_name, target)
		render partial: 'select_dropdown', locals: {resource_name: resource_name, target: target}
	end

end