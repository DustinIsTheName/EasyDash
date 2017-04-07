function ready() {

	// JS for the resourse selection
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
		target: $('#target_attr').data('target'),
		query: ''
	}

	try {
		resource_infomation.blog_total = resource_infomation.blogs.length;
		resource_infomation.collection_total = resource_infomation.collections.length;
		resource_infomation.page_total = resource_infomation.pages.length;
		resource_infomation.product_total = resource_infomation.products.length;
	} catch (e) {
		console.log(e);
	}

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
				new_html += '<a href="/dashboard?resource='+resource+'&id='+resource_object[i].id+'" target="'+resource_infomation.target+'" data-handle="' + resource_object[i].handle + '" data-id="'+resource_object[i].id+'">';
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

	// permenatly shows target upon clicking the trigger
  $('.reveal-trigger').click(function(e) {
  	e.preventDefault();
  	var reveal = $(this).data('reveal');
  	$(this).hide();

  	$('.reveal-target[data-reveal="'+reveal+'"]').show();
  });

  // checkes variant checkboxes based on option value clicked
  $('.variant-selector-link').click(function() {
  	var option = $(this).data('option');
  	var value = $(this).data('value');

  	$('.variant .col_left > input[type="checkbox"]').prop('checked', false);

  	if (option === 'all') {
  		$('.variant .col_left > input[type="checkbox"]').prop('checked', true);
  	} else if (option !== 'none') {
	  	$('.variant[data-option'+option+'="'+value+'"] .col_left > input[type="checkbox"]').prop('checked', true);
	  }
  });

	// Opens bulk variant editing 
	$('.variant').click(function() {
		if (!$(this).hasClass('variant_open')) {
			$('.variant').removeClass('variant_open');
			$(this).addClass('variant_open');
		}
	});

	$('.variant input[type="checkbox"]').click(function(e) {
		e.stopPropagation();
	});

	// submit form with AJAX
	$('form.ajax').submit(function() {  
	    var valuesToSubmit = $(this).serialize();
	    $.ajax({
	        type: "POST",
	        url: $(this).attr('action'), //sumbits it to the given url of the form
	        data: valuesToSubmit,
	        dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
	    }).success(function(json){
	        console.log("success", json);
	    });
	    return false; // prevents normal behaviour
	});
}

$(document).on('turbolinks:load', ready);





















