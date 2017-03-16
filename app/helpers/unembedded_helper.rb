module UnembeddedHelper

	def svgs(svg)
		render partial: 'svgs', locals: {icon: svg}
	end

	def panel(panel)
		render partial: 'unembedded/panels/' + panel
	end

	def dropdown(resources, total, resource_name)
		render partial: 'select_dropdown', locals: {resources: resources, total: total, resource_name: resource_name}
	end

end