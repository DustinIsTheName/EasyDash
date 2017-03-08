$(document).ready(function() {

	var blogs = $('.select-sim-dropdown.blog').data('object'),
			collections = $('.select-sim-dropdown.collection').data('object'),
			pages = $('.select-sim-dropdown.page').data('object'),
			products = $('.select-sim-dropdown.product').data('object'),
			blog_total = $('.select-sim-dropdown.blog').data('total'),
			collection_total = $('.select-sim-dropdown.collection').data('total'),
			page_total = $('.select-sim-dropdown.page').data('total'),
			product_total = $('.select-sim-dropdown.product').data('total'),
			blog_page = 1,
			collection_page = 1,
			page_page = 1,
			product_page = 1;

	// console.log(blogs);
	// console.log(collections);
	// console.log(pages);
	// console.log(products);


	function changePage(resource, resource_object, page, total) {
		var total_pages = Math.ceil(total/8);
		var new_html = '';
		var max_bound = page*8;
		var min_bound = page*8 - 7;

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

		for (var i = min_bound; i <= max_bound; i++) {
		  new_html += '<li class="variable">';
			new_html += '<a href="#" data-handle="' + resource_object[i].handle + '" data-id="'+resource_object[i].id+'">';
		  new_html += resource_object[i].title;
		  new_html += '</a>'
		  new_html += '</li>'
		}

		$('.select-sim-dropdown.'+resource).append(new_html);

	}

	function pageChangeSetResource($this, direction) {
		var resource = $this.parent().prev().data('resource'),
				resource_object,
				total,
				page;

		switch(resource) {
			case 'product':
				resource_object = products;
				if (direction === 'next') {
					product_page++;
				} else {
					product_page--;
				}
				page = product_page;
				total = product_total;
				break;
			case 'blog':
				resource_object = blogs;
				if (direction === 'next') {
					blog_page++;
				} else {
					blog_page--;
				}
				page = blog_page;
				total = blog_page;
				break;
			case 'collection':
				resource_object = collections;
				if (direction === 'next') {
					collection_page++;
				} else {
					collection_page--;
				}
				page = collection_page;
				total = collection_total;
				break;
			case 'page':
				resource_object = pages;
				if (direction === 'next') {
					page_page++;
				} else {
					page_page--;
				}
				page = page_page;
				total = page_total;
				break;
		}

		changePage(resource, resource_object, page, total);
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
		if ($(this).val().length > 3) {
			var resource = $(this).data('resource');
			$.ajax({
				url: '/search/'+resource+'?q='+$(this).val(),
				success: function(filtered_resource) {
					switch(resource) {
						case 'product':
							products = filtered_resource;
							product_page = 1;
							break;
						case 'blog':
							blogs = filtered_resource;
							blog_page = 1;
							break;
						case 'collection':
							collections = filtered_resource;
							collection_page = 1;
							break;
						case 'page':
							pages = filtered_resource;
							page_page = 1;
							break;
					}
				},
				error: function(error) {
					console.log(error);
				}
			})
		}
	});

});
