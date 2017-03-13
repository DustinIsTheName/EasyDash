function ready() {

	var resource_infomation = {
		blogs: $('.select-sim-dropdown.blog').data('object'),
		collections: $('.select-sim-dropdown.collection').data('object'),
		pages: $('.select-sim-dropdown.page').data('object'),
		products: $('.select-sim-dropdown.product').data('object'),
		blog_page: 1,
		collection_page: 1,
		page_page: 1,
		product_page: 1,
		blog_chunks_loaded: 1,
		collection_chunks_loaded: 1,
		page_chunks_loaded: 1,
		product_chunks_loaded: 1,
		query: ''
	}

	resource_infomation.blog_total = resource_infomation.blogs.length;
	resource_infomation.collection_total = resource_infomation.collections.length;
	resource_infomation.page_total = resource_infomation.pages.length;
	resource_infomation.product_total = resource_infomation.products.length;

	$('.select-sim').click(function(event) {
		$('.select-sim').not(this).removeClass('active');
		$(this).toggleClass('active');
		event.stopPropagation();
	});

	$(window).click(function() {
		$('.select-sim').removeClass('active');
	});

	function extendResource(resource, page, total) {
		resource_infomation[resource+'_chunks_loaded']++;
		$.ajax({
			url: '/search/'+resource+'?q='+resource_infomation.query+'&page='+resource_infomation[resource+'_chunks_loaded'],
			success: function(extension) {
				resource_infomation[resource+'s'] = resource_infomation[resource+'s'].concat(extension);
				resource_infomation[resource+'_total'] = resource_infomation[resource+'s'].length;

				if (extension.length < 250) {
					resource_infomation[resource+'_chunks_loaded'] = 'all';
				}
				console.log(extension);
			},
			error: function(error) {
				console.log(error);
			}
		});
	}

	function changePage(resource, resource_object, page, total) {
		var total_pages = Math.ceil(total/8);
		var new_html = '';
		var max_bound = page*8 - 1;
		var min_bound = page*8 - 8;

		if (page >= total_pages - 3 && total_pages > 31 && resource_infomation[resource+'_chunks_loaded'] !== 'all') {
			extendResource(resource, page, total);
		}

		if (max_bound >= total) {
			max_bound = total - 1;
		}

		$('.select-sim-dropdown.'+resource+' + .arrow-navigation button').removeClass('disabled');
		if (page === 1) {
			$('.select-sim-dropdown.'+resource+' + .arrow-navigation .icon-prev').addClass('disabled');
		}
		if (page === total_pages) {
			$('.select-sim-dropdown.'+resource+' + .arrow-navigation .icon-next').addClass('disabled');
		}

		$('.select-sim-dropdown.'+resource).find('.variable').remove();

		if (resource_object.length > 0) {
			for (var i = min_bound; i <= max_bound; i++) {
			  new_html += '<li class="variable">';
				new_html += '<a href="#" data-handle="' + resource_object[i].handle + '" data-id="'+resource_object[i].id+'">';
			  new_html += resource_object[i].title;
			  new_html += '</a>'
			  new_html += '</li>'
			}
		} else {
		  new_html += '<li class="variable"><span>No results found.</span></li>';
		}

		$('.select-sim-dropdown.'+resource).append(new_html);

	}

	function pageChangeSetResource($this, direction) {
		var resource = $this.parent().prev().data('resource'),
				resource_object,
				total,
				page;

		if (direction === 'next') {
			resource_infomation[resource+'_page']++;
		} else {
			resource_infomation[resource+'_page']--;
		}

		changePage(resource, resource_infomation[resource+'s'], resource_infomation[resource+'_page'], resource_infomation[resource+'_total']);
	}

	$('.search .icon-next').click(function() {
		if (!$(this).hasClass('disabled')) {
			pageChangeSetResource($(this), 'next');
		}
	});

	$('.search .icon-prev').click(function() {
		if (!$(this).hasClass('disabled')) {
			pageChangeSetResource($(this), 'prev');
		}
	});

	$('.resource-search').keyup(function() {
		console.log('wat?');
		if ($(this).val().length > 2 || $(this).val().length === 0) {
			var resource = $(this).data('resource');
			resource_infomation.query = $(this).val();
			$.ajax({
				url: '/search/'+resource+'?q='+resource_infomation.query+'&page=1',
				success: function(filtered_resource) {
					resource_infomation[resource+'s'] = filtered_resource;
					resource_infomation[resource+'_page'] = 1;
					resource_infomation[resource+'_total'] = filtered_resource.length;
					resource_infomation[resource+'_chunks_loaded'] = 1;

					console.log(filtered_resource);
					changePage(resource, filtered_resource, 1, filtered_resource.length);
				},
				error: function(error) {
					console.log(error);
				}
			});
		}
	});
}

$(document).on('turbolinks:load', ready);





















