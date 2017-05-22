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

	$.ajaxSetup({
  	dataType: 'json'
	});

	function checkVisible(elm) {
	  var rect = elm.getBoundingClientRect();
	  var viewHeight = Math.max(document.documentElement.clientHeight, window.innerHeight);
	  return (rect.bottom <= viewHeight && rect.top >= 0);
	}

	$('.select-sim').click(function(event) {
		$('.select-sim').not(this).removeClass('active');
		$(this).toggleClass('active');

		if (!checkVisible(this.nextElementSibling)) {
			$(this).toggleClass('reverse');
			while (!checkVisible(this.nextElementSibling)) {
				$(this.nextElementSibling).addClass('no-arrow');

				if ($(this).hasClass('reverse')) {
					var bottom = parseInt($(this.nextElementSibling).css('bottom'));
					$(this.nextElementSibling).css('bottom', bottom - 10);
				} else {
					var top = parseInt($(this.nextElementSibling).css('top'));
					$(this.nextElementSibling).css('top', top + 10);
				}
			}
		}

		event.stopPropagation();
	});

	$('.select-sim-dropdown-container').click(function(event) {
		event.stopPropagation();
	});

	$(window).click(function() {
		$('.select-sim').removeClass('active');
		$('.product-pannel-collection-select').hide();
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
		var minimum = 3;

		if ($(this).data('exceptions') === 'product-panel') {
			minimum = 0;
		}

		if ($(this).val().length >= minimum || $(this).val().length === 0) {
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

	$('.resource-search[data-exceptions="product-panel"]').focus(function() {
		$(this).next().show();
	});

	$('.resource-search[data-exceptions="product-panel"]').click(function(event) {
		event.stopPropagation();
	});

	$('.product-pannel-collection-select').on('click', '.variable a', function(event) {
		event.preventDefault();
		var id = $(this).data('id');
		var title = $(this).text();
		var shop_url = $('.product-pannel-collection-select').data('shop-url');
		var collection = {id: id}

		var new_html = '<div class="collection" data-collection=\''+JSON.stringify(collection)+'\'>';
    new_html += '<a target="_blank" href="https://'+shop_url+'/admin/collections/'+id+'">'+title+'</a>';
    new_html += '<span class="icon-close"></span>';
    new_html += '</div>';

		$('.resource-search[data-exceptions="product-panel"]').before('<input value="'+id+'" id="collection_'+id+'" type="hidden" name="collections[]">');
    $('.product-pannel-collection-select').after(new_html);
	});

	$('.product-collections-select').on('click', '.icon-close', function() {
		var id = $(this).parent().data('collection').id;

		$('input#collection_'+id).remove();
		$(this).parent().remove();
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

	// $('form.ajax').submit(function(e) {
	// 	e.preventDefault();
	// });

	// submit form with AJAX
	$('#save_resource').click(function() {
		$('form.ajax').submit();
		// $('.variant_input').prop('disabled', true);

  //   var valuesToSubmit = $('form.ajax').serialize();
  //   $.ajax({
  //     type: "POST",
  //     url: $('form.ajax').attr('action'), //sumbits it to the given url of the form
  //     data: valuesToSubmit,
  //     dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
  //   }).success(function(product){
  //   	var variant;
  //     console.log("success product", product);
  //     $('.variant_input').prop('disabled', false);

  //     for (var i = 0; i < product.variants.length; i++) {
  //     	variant = product.variants[i];
  //     	$('#variant_id_'+variant.id+' .edit_single_variant').data('object', variant);
  //     }
  //     // time to provide feedback 
  //   }).error(function(e) {
  //   	console.log(e);

  //   	$('.variant_input').prop('disabled', false);
  //   });
  //   return false; // prevents normal behaviour
	});

	$('form.ajax').bind("ajax:success", function(event, product){
  	var variant;
    console.log("success product", product);
    $('.variant_input').prop('disabled', false);

    for (var i = 0; i < product.variants.length; i++) {
    	variant = product.variants[i];
    	$('#variant_id_'+variant.id+' .edit_single_variant').data('object', variant);
    }
    // time to provide feedback 

	  if ( $(this).data('remotipartSubmitted') ) {

	  }
	});

	$('form.ajax').bind("ajax:error", function(event, error){
  	console.log(event, error);

  	$('.variant_input').prop('disabled', false);
	});

	// submit single variant
	$('.single_variant_submit').click(function(e) {
		var data;

		$('form.ajax [name]:not(.variant_input)').prop('disabled', true);
		data = $('form.ajax').serialize();
		$('form.ajax [name]:not(.variant_input)').prop('disabled', false);

		console.log(data);

		// submit form with AJAX
    $.ajax({
      type: "POST",
      url: '/variant-update', //sumbits it to the given url of the form
      data: data,
      dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
    }).success(function(variant) {
      console.log("success variant", variant);
      $('[data-object*="'+variant.id+'"]').data('object', variant);
      $('#variants_'+variant.id+'_option1').val();
      $('#variants_'+variant.id+'_option2').val();
      $('#variants_'+variant.id+'_option3').val();
      $('#variants_'+variant.id+'_inventory_quantity').val();
      $('#variants_'+variant.id+'_compare_at_price').val();
      $('#variants_'+variant.id+'_price').val();
      $('#variants_'+variant.id+'_sku').val();

      $('form.ajax [name]:not(.variant_input)').prop('disabled', false);

      // time to provide feedback 
    }).error(function(e) {
    	console.log(e);

    	$('form.ajax [name]:not(.variant_input)').prop('disabled', false);
    });
		return false; // prevents normal behaviour
	});

	// edit single variant
	$('.edit_single_variant').click(function(e) {
		e.preventDefault();

		var image = $(this).data('image');
		var variant = $(this).data('object');
		var metafields = $(this).data('metafields');

		$('.variant-image').remove();
		if (image) {
			$('.image_box').prepend('<img class="variant-image quark" src="'+image+'">');
			$('.image_box .variant_image').data('image-id', variant.image_id);
			$('.image_box .variant_image').data('variant-id', variant.id);
		} else {
			$('.image_box .variant_image').data('image-id', '');
			$('.image_box').prepend('<div class="column twelve type--centered no_margin variant-image"><i class="image icon-image next-icon--size-80"></i><h5>Choose image</h5></div>');
		}

		$('.new_hsc_name').remove();

		$('#section-edit-variant [name^="variants"]').each(function() {
			var variantName = $(this).attr('name'),
					variantId = $(this).attr('id'),
					nameRegexp = /variants\[([0-9]{11})\].*\[(.+)\]/g,
					match = nameRegexp.exec(variantName),
					oldId = match[1],
					oldKey = match[2],
					hsc;

			if (variant.hasOwnProperty(oldKey)) {
				$(this).attr('name', variantName.replace(oldId, variant.id));
				$(this).val(variant[oldKey]);
				if (variantId) $(this).attr('id', variantId.replace(oldId, variant.id));
			} else {
				hsc = metafields.filter(function(m) {
				  return m.key === 'harmonized_system_code';
				})[0];

				if (hsc) {
					$(this).val(hsc.value);
					$(this).attr('name', 'variants['+variant.id+']metafields['+hsc.id+'][value]');
					$(this).attr('id', 'variants_'+variant.id+'_metafields_'+hsc.id+'_value');
				} else {
					$(this).val('');
					$(this).before('<input value="harmonized_system_code" class="new_hsc_name variant_input" type="hidden" name="variants['+variant.id+']new_metafields[][name]" id="variants_'+variant.id+'_new_metafields__name">');
					$(this).attr('name', 'variants['+variant.id+']new_metafields[][value]');
					$(this).attr('id', 'variants_'+variant.id+'_new_metafields__value');
				}
			}
		});
	});

	// pannel navigation
	$('.prev-pannel').click(function() {
		var pannel = $(this).closest('.wittyEDPanel');
		var tier = parseInt(pannel.data('tier'));
		pannel.blindRightOut(400, 'swing', function() {
			$(this).css({'height': 0, 'opacity': 0});
		});
		$('.wittyEDPanel[data-tier="'+(tier - 1)+'"]').css({'height': 'auto', 'opacity': 1}).blindLeftIn(400);
	});

	$('.next-pannel').click(function() {
		var pannel = $(this).closest('.wittyEDPanel');
		var tier = parseInt(pannel.data('tier'));
		pannel.blindLeftOut(400, 'swing', function() {
			$(this).css({'height': 0, 'opacity': 0});
		});
		$('.wittyEDPanel[data-tier="'+(tier + 1)+'"]').css({'height': 'auto', 'opacity': 1}).blindRightIn(400);
	});

	// responsive iframe adjustments
	$('#responsive-dropdown').click(function() {
		$('.responsive-dropdown-items-container').toggleClass('active');
	});

	$(document).click(function() {
		$('.responsive-dropdown-items-container').removeClass('active');
	});

	$('.responsive-dropdown-items-container, #responsive-dropdown').click(function(e) {
		e.stopPropagation();
	});

	$('.responsive-dropdown-items a').click(function(e) {
		e.preventDefault();

		var width = $(this).data('width');
		var height = $(this).data('height');

		$('#dashboard-iframe').width(width).height(height);
	});

	$('.wittyEDFullscreenToggle').click(function(e) {
		e.preventDefault();
		$('.wittyEDSidebar').toggleClass('closed');
	});

	// edit variant image
	function editVariantImage($this) {
		var image_id = $this.data('image-id');
		var variant_id = $this.data('variant-id');

		if (image_id) {
			$('#variant-image-destroy').show();
		} else {
			$('#variant-image-destroy').hide();
			$('.variant-select-image').prop('checked', false);
		}

		$('#variant-select-image-'+image_id).prop('checked', true);
		$('.variant-select-image').attr('name', 'variants['+variant_id+'][image_id]');

		$('.editVariantImage').addClass('open');
	}

	function closeVariantImage() {
		$('.editVariantImage').removeClass('open');
	}

	$('#tag-field').keyup(function(e) {
    if (e.key === ',') {
    	var tag_text = $(this).val().replace(',', '');
    	var tag_list = $('#shopify_api_product_tags').val().split(',');

    	if (tag_text.trim() === '') {
    		$(this).val(tag_text.replace(',', ''));
    	} else {
	    	tag_list.push(tag_text)
				$('#shopify_api_product_tags').val(tag_list.join(','));
	    	$(this).val('');
	    	tag = '<span class="tag blue remove">'+tag_text+'<a href="#"></a></span>';
	    	$('#shopify_api_product_tags').before(tag);
	    }
    }
  });

	$('.tags-container').on('click', '.tag.remove a', function(e) {
		e.preventDefault();
		var tag = $(this).parent().remove().text().trim();
		var tag_list = $('#shopify_api_product_tags').val().split(',');
		var tag_index = tag_list.indexOf(tag);

		tag_list.splice(tag_index, 1);
		$('#shopify_api_product_tags').val(tag_list.join(','));
		console.log(tag);
		// /(\s*?[,]\s*?){2,}/
	});

	$('.variant-image-save').click(function(e) {
		e.preventDefault();

		var variant_id = $('.variant-select-image').attr('name').match(/variants\[([0-9]{11})\]\[image_id\]/)[1],
				product_id = $('[name="id"]').val(),
				image_id = $('[name="variants['+variant_id+'][image_id]"]:checked').val();

		if ($(this).attr('id') === 'variant-image-destroy') {image_id = 'destroy';}

		$.ajax({
      type: "POST",
      url: '/variant-image', //sumbits it to the given url of the form
      data: {
      	image: image_id,
      	variant: variant_id,
      	product: product_id
      },
      dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
    }).success(function(image) {
    	closeVariantImage();
    	console.log(image)

    	$('.image_box .variant_image').data('image-id', image.id);
    	$('#variant_id_'+variant_id+' .variant_image').data('image-id', image.id);
    	$('#variant_id_'+variant_id+' .edit_single_variant').data('image', image.src);
    	var variant_object = $('#variant_id_'+variant_id+' .edit_single_variant').data('object');
    	variant_object.image_id = image.id;
    	$('#variant_id_'+variant_id+' .edit_single_variant').data('object', variant_object);

    	console.log(variant_id);
    	$('.variant-image').remove();
    	$('#variant_id_'+variant_id+' .variant_image *').remove();
    	if (image.id) {
	    	$('#variant_id_'+variant_id+' .variant_image').prepend('<img src="'+image.src+'">');
	    	$('.image_box').prepend('<img class="variant-image" src="'+image.src+'">');
	    } else {
	    	$('#variant_id_'+variant_id+' .variant_image').prepend('<i class="icon-image"></i>');
	    	$('.image_box').prepend('<div class="column twelve type--centered no_margin variant-image"><i class="image icon-image next-icon--size-80"></i><h5>Choose image</h5></div>');
	    }
    }).error(function(e) {
    	console.log(e);
    });
	});

	$('#cancel').click(closeVariantImage);

	$('.variant_image').click(function(e) {
		e.preventDefault();
		$parent = $(this).parent().parent();

		if ($parent.hasClass('variant_open') || $parent.hasClass('drop_images')) {
			editVariantImage($(this));
		}
	});

	// window.onbeforeunload = function () {
	//   if (!confirm("Do you really want to close?")) {
	//   	return false;
	//   }
	// };
}

$(document).on('turbolinks:load', ready);





















