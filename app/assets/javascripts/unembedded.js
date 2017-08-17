function ready() {

	/*******************************************
	Variable Declarations
	*******************************************/

	var variant_image_page = 0;
	// JS for the resourse selection
	var resource_infomation = {
		blogs: [],
		collections: [],
		smart_collections: [],
		custom_collections: [],
		pages: [],
		products: [],
		blog_page: 1,
		collection_page: 1,
		custom_collection_page: 1,
		page_page: 1,
		product_page: 1,
		blog_chunks_loaded: 1,
		collection_chunks_loaded: 1,
		custom_collection_chunks_loaded: 1,
		page_chunks_loaded: 1,
		product_chunks_loaded: 1,
		target: $('#target_attr').data('target'),
		query: ''
	}

	// console.log(resource_infomation);

	try {
		resource_infomation.blog_total = resource_infomation.blogs.length;
		resource_infomation.collection_total = resource_infomation.collections.length;
		resource_infomation.page_total = resource_infomation.pages.length;
		resource_infomation.product_total = resource_infomation.products.length;
	} catch (e) {
		console.log(e);
	}

	/*******************************************
	Javascript Object Extentions
	*******************************************/

	if (!Array.prototype.filter) {
	  Array.prototype.filter = function(fun /*, thisp*/) {
	    var len = this.length >>> 0;
	    if (typeof fun != "function")
	    throw new TypeError();

	    var res = [];
	    var thisp = arguments[1];
	    for (var i = 0; i < len; i++) {
	      if (i in this) {
	        var val = this[i]; // in case fun mutates this
	        if (fun.call(thisp, val, i, this))
	        res.push(val);
	      }
	    }
	    return res;
	  };
	}

	/*******************************************
	jQuery Extentions
	*******************************************/

	$.ajaxSetup({
  	dataType: 'json'
	});

	$.fn.isAfter = function(sel){
		return this.index() > sel.index();
	  // return this.prevAll(sel).length !== 0;
	}
	$.fn.isBefore= function(sel){
		return this.index() < sel.index();
	  // return this.nextAll(sel).length !== 0;
	}

	/*******************************************
	General Functions
	*******************************************/

	function resetResources() {
		variant_image_page = 0;
		// JS for the resourse selection
		resource_infomation = {
			blogs: [],
			collections: [],
			smart_collections: [],
			custom_collections: [],
			pages: [],
			products: [],
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

		// console.log(resource_infomation);

		try {
			resource_infomation.blog_total = resource_infomation.blogs.length;
			resource_infomation.collection_total = resource_infomation.collections.length;
			resource_infomation.page_total = resource_infomation.pages.length;
			resource_infomation.product_total = resource_infomation.products.length;
		} catch (e) {
			console.log(e);
		}
	}

	function basicError(error) {
		console.log(error);
  }

	function getCookie(cname) {
    var name = cname + "=";
    var decodedCookie = decodeURIComponent(document.cookie);
    var ca = decodedCookie.split(';');
    for(var i = 0; i <ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
	}

	function onlyUnique(value, index, self) { // for use in ARRAY.filter()
	  return self.indexOf(value) === index;
	}

	function flashMessage(message, type) {
		type = type || 'success';

		if ($('.flash-message').length === 0) {
			$('body').append('<div class="flash-message '+type+'">'+message+'</div>');
		} else {
			$('.flash-message').removeClass('success error');
			$('.flash-message').text(message);
			$('.flash-message').addClass(type);
		}

		$('.flash-message').addClass('active');

		setTimeout(function() {
			$('.flash-message').removeClass('active');
		}, 4000);
	}

	function checkVisible(elm) {
	  var rect = elm.getBoundingClientRect();
	  var viewHeight = Math.max(document.documentElement.clientHeight, window.innerHeight);
	  return (rect.bottom <= viewHeight && rect.top >= 0);
	}

	function isUnsaved() {
		$('.variant_input').prop('disabled', true);
		var currentFormState = $('form.ajax').serialize();
		$('.variant_input').prop('disabled', false);

		return currentFormState !== previousFormState;
	}

	function isVariantUnsaved() {
		$('form.ajax [name]:not(.variant_input)').prop('disabled', true);
		var currentVariantState = $('form.ajax').serialize();
		$('form.ajax [name]:not(.variant_input)').prop('disabled', false);
		return currentVariantState !== previousVariantState;
	}

	function refreshIframe() {
		setTimeout(function() {
			$('#dashboard-iframe').attr('src', currentIframeUrl);
		}, 500);
	}

	function confirmBox(confirmHeader, confirmText, confirmAction, callbackFunctions, callbackParams, extra_button) {
		var confirm_function,
				deny_function;
		if (typeof callbackFunctions.yes === 'function') {
			confirm_function = function(e) {
				e.stopPropagation();
				e.preventDefault();
				callbackFunctions.yes(callbackParams);
				$('#confirmBoxOverlay').remove();
			}
		} else {
			confirm_function = function(e) {
				e.stopPropagation();
				e.preventDefault();
				$('#confirmBoxOverlay').remove();
			}
		}

		if (typeof callbackFunctions.no === 'function') {
			deny_function = function(e) {
				e.stopPropagation();
				e.preventDefault();
				callbackFunctions.no(callbackParams);
				$('#confirmBoxOverlay').remove();
			}
		} else {
			deny_function = function(e) {
				e.stopPropagation();
				e.preventDefault();
				$('#confirmBoxOverlay').remove();
			}
		}

		var $confirmBox = $('<div>', {id: 'confirmBoxOverlay', class: 'editModalOverlay'})
				.append(
					$('<section>', {id: 'confirmBox', "class": 'editModal '+confirmAction.toLowerCase()})
					.append($('<div>', {"class": "card has-sections"})
						.append(
							$('<div>', {"class": 'card-section'}).append('<h3>'+confirmHeader+'</h3>')
							.append($('<button class="btn btn--link close-modal" type="button" name="button">Close modal</button>').click(deny_function))
						).append('<hr>').append(
							$('<div>', {"class": 'card-section'}).append('<p>'+confirmText+'</p>')
						).append('<hr>').append(
							$('<div>', {"class": 'card-section'}).append(
								$('<button>', {id: 'cancel', "class": 'secondary', type: "button"}).text('Cancel').click(deny_function)
							).append(
								$('<button>', {id: 'confirm', type: "button"}).text(confirmAction).click(confirm_function)
							)
						)
					)
				).click(function(e) {
					e.stopPropagation();
				});

		if (extra_button) {
			$confirmBox.find('#confirm').before($('<button id="extra" type="button">'+extra_button.text+'</button>').click(extra_button.function));
		}

		$('body').append($confirmBox);
	}

	function closeModal($overlay) {
		$overlay.removeClass('open');
	}

	function shiftPannelsRight($this) {
		$('#save_resource').show();
		$('.single_variant_submit').hide();
		var pannel = $this.closest('.wittyEDPanel');
		var tier = parseInt(pannel.data('tier'));
		pannel.blindRightOut(400, 'swing', function() {
			$(this).css({'height': 0, 'opacity': 0});
		});
		$('.wittyEDPanel[data-tier="'+(tier - 1)+'"]').css({'height': 'auto', 'opacity': 1}).blindLeftIn(400);
	}

	function shiftPannelsLeft($this) {
		var pannel = $this.closest('.wittyEDPanel');
		var tier = parseInt(pannel.data('tier'));
		pannel.blindLeftOut(400, 'swing', function() {
			$(this).css({'height': 0, 'opacity': 0});
		});
		$('.wittyEDPanel[data-tier="'+(tier + 1)+'"]').css({'height': 'auto', 'opacity': 1}).blindRightIn(400);
	}

	function refreshFormCallback(new_html) {
		$('#resource-section').html(new_html.form_html).find('.wittyEDPanelBody').hide().fadeIn(200);
		$('#modals-container').html(new_html.modals);

		initializeFroalaEditor();
		$('.variant_input').prop('disabled', true);
		previousFormState = $('form.ajax').serialize();
		$('.variant_input').prop('disabled', false);
		setTimeout(function() {
			$('.wittyEDPanel').removeClass('is-loading');
		}, 200);
	}

	function refreshForm(messageEvent) {
		currentIframeUrl = messageEvent.data;
		var url = messageEvent.data.replace(messageEvent.origin, '').split('?')[0];
		var resource_handle = url.match(/^\/([a-z]+)\/?[a-z-0-9]*\/([a-z-0-9]+)$/);

		$('.wittyEDPanelBody').fadeOut(200, 'swing', function() {
			$('.wittyEDPanel.active').addClass('is-loading');
		});
		// $('#resource-section').append('<div id="refreshing-resource" class="is-loading">');

		if (resource_handle) {
			$.ajax({
				type: 'GET',
				url: '/refresh-form',
				data: {
					resource: resource_handle[1].replace(/s$/, ''),
					handle: resource_handle[2]
				},
				dataType: 'json'
			}).success(refreshFormCallback).error(basicError);
		} else {
			$.ajax({
				type: 'GET',
				url: '/refresh-form',
				dataType: 'json'
			}).success(refreshFormCallback).error(basicError);
		}
	}

	function refreshVariantPanel() {
		$('#allVariantsPanel').fadeOut(200, 'swing', function() {
			$('#allVariantsPanel').parent().addClass('is-loading');
		});

		$.ajax({
			type: 'GET',
			url: '/refresh-form',
			data: {
				resource: 'product',
				handle: $('[name="handle"]').val()
			},
			dataType: 'json'
		}).success(function(new_html) {
			$('#modals-container').html(new_html.modals);
		}).error(basicError);

  	$.ajax({
  		type: 'GET',
  		url: '/refresh-variant-panel',
  		data: {id: $('[name="id"]').val()},
  		dataType: 'html'
  	}).success(function(variants_html) {
  		$('#allVariantsPanel').fadeIn().html(variants_html).parent().removeClass('is-loading');
  	}).error(basicError);
  }

	function hideRTEButtons() {
		$('.fr-toolbar .fr-command').addClass('fr-hidden');
		$('.fr-command[id^="fullscreen"]').removeClass('fr-hidden');
		$('.fr-command[id^="bold"]').removeClass('fr-hidden');
		$('.fr-command[id^="italic"]').removeClass('fr-hidden');
		$('.fr-command[id^="underline"]').removeClass('fr-hidden');
		$('.fr-command[id^="insertLink"]').removeClass('fr-hidden');
	}

	function showRTEButtons() {
		$('.fr-toolbar .fr-command').removeClass('fr-hidden');
		$('.fr-command[id^="undo"]').addClass('fr-hidden');
		$('.fr-command[id^="redo"]').addClass('fr-hidden');
		$('.fr-command[id^="fullscreen"]').addClass('fr-hidden');
	}

	function initializeFroalaEditor() {
		$('#shopify_api_product_body_html').froalaEditor({
			toolbarButtons: [
				'paragraphFormat', 
				'bold', 
				'italic', 
				'underline',
				'formatUL',
				'formatOL',
				'outdent', 
				'indent',
				'align',
				'color',
				'insertLink',
				'insertTable',
				'insertImage',
				'insertVideo',
				'clearFormatting',
				'html',
				'fullscreen'
			],
			toolbarSticky: false,
			tooltips: true,
			placeholderText: '',
			useClasses: false,
			htmlIgnoreCSSProperties: [],
			codeMirror: true,
		  codeMirrorOptions: {
		    tabSize: 2,
		    lineNumbers: true,
		    lineWrapping: true
		  },
		  imageUploadURL: '/add-image-to-theme',
		  videoInsertButtons: [
		  	'videoBack', 
		  	'|',
		  	'videoEmbed'
		  ],
		  paragraphFormat: {
			  N: 'Paragraph',
			  H1: 'Heading 1',
			  H2: 'Heading 2',
			  H3: 'Heading 3',
			  H4: 'Heading 4',
			  H5: 'Heading 5',
			  H6: 'Heading 6',
			  BLOCKQUOTE: 'Blockquote'
			}
		});
		hideRTEButtons();
		$(window).resize(function() {
			if ($('.fr-box').hasClass('fr-fullscreen')) {
				showRTEButtons();			
			} else {
				hideRTEButtons();
			}
		});
		$('#shopify_api_product_body_html').on('froalaEditor.commands.after', function (e, editor, cmd, param1, param2) {

  		function exitFullscreen() {
				if ($('#shopify_api_product_body_html').froalaEditor('fullscreen.isActive')) {
		  		$('#description-label').after($('.fr-box'));
					$('#shopify_api_product_body_html').froalaEditor('fullscreen.toggle');
		  		hideRTEButtons();
		  		$('.fr-top.fr-toolbar').css('z-index', 4);
		  		$('#frWysiwygFullscreenOverlay').remove();
				}
			}

		  if (cmd === "fullscreen") {
		  	if ($('.fr-box').hasClass('fr-fullscreen')) {
		  		showRTEButtons();

					var $overlay = $('<div id="frWysiwygFullscreenOverlay" class="editModalOverlay">');
					$overlay.click(exitFullscreen);

					var $overlay_inner = $('<section id="frWysiwygFullscreen" class="editModal">').click(function(e) {
						e.stopPropagation();
					});

			    var overlay_inner_html = '<div class="card has-sections">';
		      overlay_inner_html += '<div class="card-section">';
	        overlay_inner_html += '<h3 style="margin-bottom: 0;">Description</h3>';
	        overlay_inner_html += '</div>';
		      overlay_inner_html += '<div id="fullscreen-wysiwyg-container" class="card-section"></div>';
		      overlay_inner_html += '<div class="card-section">';
		      overlay_inner_html += '<p class="info-text">Changes will not be lost when exiting fullscreen.</p>';
	        overlay_inner_html += '<button type="button" class="secondary cancel" href="#">Exit Fullscreen</button>';
	        overlay_inner_html += '</div>';
	        overlay_inner_html += '</div>';

	        $overlay_inner.append(overlay_inner_html);
	        $overlay.append($overlay_inner);

	        $overlay.find('button.cancel').click(exitFullscreen);

					$('body').append($overlay);
	        $('#fullscreen-wysiwyg-container').append($('.fr-box'));

		  	} else {
		  		exitFullscreen();
		  	}
		  }
		});
	}

	initializeFroalaEditor();

	var currentIframeUrl = $('#dashboard-iframe').attr('src');
	$('#section-edit-variant [name^="variants"]').addClass('variant_input');
	$('.variant_input').prop('disabled', true);
	var previousFormState = $('form.ajax').serialize();
	var previousVariantState;
	$('.variant_input').prop('disabled', false);

	/*******************************************
	Common Events
	*******************************************/

	$('#modals-container').on('click', '.editModalOverlay', function() {
		closeModal($(this));
	});

	$('#modals-container').on('click', '.editModal .cancel', function() {
		closeModal($(this).closest('.editModalOverlay'));
	});

	$('#modals-container').on('click', '.editModal', function(e) {
		e.stopPropagation();
	});

	// pannel navigation
	$('body').on('click', '.prev-pannel', function(e) {
		e.preventDefault();
		shiftPannelsRight($(this));
	});

	$('body').on('click', '.next-pannel', function(e) {
		e.preventDefault();
		shiftPannelsLeft($(this));
	});

	$('#resource-section').on('change', '.hidden_checkbox', function() {
		if ($(this).is(':checked')) {
			$(this).next('[type="hidden"]').val(true);
		} else {
			$(this).next('[type="hidden"]').val(false);
		}
	});

	window.addEventListener("message", function(messageEvent) {
		console.log(currentIframeUrl, messageEvent.data);

		if (currentIframeUrl !== messageEvent.data && currentIframeUrl) {

			if (isUnsaved()) {
			  confirmBox(
			  	'You have unsaved changes on this page', // Title of confirm Box
			  	'If you leave this page, all unsaved changes will be lost. Are you sure you want to leave this page?', // Text of confirm Box
			  	'Leave Page', // Confirm Button Text
			  	{
			  	yes: function() { // function for confirm button
			  		refreshForm(messageEvent);
			  	},
			  	no: function() {
			  		refreshIframe();
			  	}
			  },
			  {}, // function parameters; unneeded here
			  {
			  	text: "Save & Leave", // extra button text
			  	function: function() {
			  		$(this).addClass('is-loading');
			  		$('.variant_input').prop('disabled', true);
			  		var data = $('form.ajax').serialize();
			  		$.ajax({
				      type: "POST",
				      url: '/dashboard-update', //sumbits it to the given url of the form
				      data: data,
				      dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
				    }).success(function(event, product) {
				    	$('#confirmBoxOverlay').remove();

				    	flashMessage('Product was successfully saved');
				    	refreshForm(messageEvent);
				    }).error(function(event, error) {
		    	  	console.log(event, error);

					  	$('.variant_input').prop('disabled', false);
					  	flashMessage('Product was not saved', 'error');
				    });
			  	}
			  });
			} else {
				refreshForm(messageEvent);
			}
		}

	}, false);

	// permenatly shows target upon clicking the trigger
  $('#resource-section').on('click', '.reveal-trigger', function(e) {
  	e.preventDefault();
  	var reveal = $(this).data('reveal');
  	var $this = $(this);
  	if (reveal === 'seo') {
  		$this.addClass('is-loading');
  		$this.off('click');
  		if ($('[name="id"]').val() === 'new') {
  			var new_html = '';
	      new_html += '<input value="title_tag" class="new_field" type="hidden" name="new_metafields[][name]" id="new_metafields__name">';
	      new_html += '<label for="new_field_title">Page title</label>';
	      new_html += '<input class="new_field" id="new_field_title" type="text" name="new_metafields[][value]">';
				$('.title_tag_container').append(new_html);
				new_html = '';
        new_html += '<input value="description_tag" class="new_field" type="hidden" name="new_metafields[][name]" id="new_metafields__name">';
        new_html += '<label for="new_field_description">Meta description</label>';
        new_html += '<textarea class="new_field" id="new_field_description" name="new_metafields[][value]"></textarea>';
        $('.description_tag_container').append(new_html);
		  	$this.hide();
		  	$('.reveal-target[data-reveal="'+reveal+'"]').show(); 
			} else {
				$.ajax({
		      type: "GET",
		      url: '/product-seo', //sumbits it to the given url of the form
		      data: {
		      	product_id: $('[name="id"]').val()
		      },
		      dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
		    }).success(function(product_metafields) {
		    	var new_html = '';
		    	var description_tag = product_metafields.filter(function(metafield) {
					  return metafield.key === 'description_tag'
					})[0];
					var title_tag = product_metafields.filter(function(metafield) {
					  return metafield.key === 'title_tag'
					})[0];

					if (title_tag) {
	          new_html += '<label for="metafields_'+title_tag.id+'_value">Page title</label>';
	          new_html += '<input type="text" value="'+title_tag.value+'" name="metafields['+title_tag.id+'][value]" id="metafields_'+title_tag.id+'_value">';
						$('.title_tag_container').append(new_html);
					}	else {
	          new_html += '<input value="title_tag" class="new_field" type="hidden" name="new_metafields[][name]" id="new_metafields__name">';
	          new_html += '<label for="new_field_title">Page title</label>';
	          new_html += '<input class="new_field" id="new_field_title" type="text" name="new_metafields[][value]">';
						$('.title_tag_container').append(new_html);
	        }

	        new_html = '';

					if (description_tag) {
	          new_html += '<label for="metafields_'+description_tag.id+'_value">Page title</label>';
	          new_html += '<textarea type="text" name="metafields['+description_tag.id+'][value]" id="metafields_'+description_tag.id+'_value">'+description_tag.value+'</textarea>';
						$('.description_tag_container').append(new_html);
					}	else {
	          new_html += '<input value="description_tag" class="new_field" type="hidden" name="new_metafields[][name]" id="new_metafields__name">';
	          new_html += '<label for="new_field_description">Meta description</label>';
	          new_html += '<textarea class="new_field" id="new_field_description" name="new_metafields[][value]"></textarea>';
	          $('.description_tag_container').append(new_html);
	        }

			  	$this.hide();
			  	$('.reveal-target[data-reveal="'+reveal+'"]').show(); 
		    }).error(function() {
		    	basicError();
		    	$this.removeClass('is-loading');
		    });

		  }
  	} else {
	  	$(this).hide();
	  	$('.reveal-target[data-reveal="'+reveal+'"]').show();  		
  	}
  });

	// responsive iframe adjustments
	$('#responsive-dropdown').click(function() {
		$('.responsive-dropdown-items-container').toggleClass('active');
	});

	$(document).click(function() {
		$('.responsive-dropdown-items-container').removeClass('active');
		$('.more-menu').removeClass('open');
	});

	$('.responsive-dropdown-items-container, #responsive-dropdown').click(function(e) {
		e.stopPropagation();
	});

	$('.responsive-dropdown-items a').click(function(e) {
		e.preventDefault();
		$('.responsive-dropdown-items a').removeClass('active rotated');
		$(this).addClass('active');
		var width = $(this).data('width');
		var height = $(this).data('height');
		var icon = $(this).data('icon');
		$('.views_button span').removeClass('active rotated');
		$('.views_button span.'+icon).addClass('active');

		$('#dashboard-iframe').width(width).height(height);
	});

	$('.responsive-dropdown-items .rotate').click(function(e) {
		e.preventDefault();
		e.stopPropagation();
		if (!$('.responsive-dropdown-items a.active').hasClass('desktop')) {
			$('.responsive-dropdown-items a.active').toggleClass('rotated');
			var width = $('#dashboard-iframe').attr('style').match(/height: ([0-9]{0,4}).{1,}/)[1];
			var height = $('#dashboard-iframe').attr('style').match(/width: ([0-9]{0,4}).{1,}/)[1];
			$('.views_button .active').toggleClass('rotated');

			$('#dashboard-iframe').width(width).height(height);
		}
	});

	$('.wittyEDFullscreenToggle').click(function(e) {
		e.preventDefault();
		$('.wittyEDSidebar').toggleClass('closed');
	});

	$('body').on('click', '.select-sim', function(event) {
		var resource = $(this).next().find('.select-sim-dropdown').data('resource');;

		$('.select-sim').not(this).removeClass('active');
		$(this).toggleClass('active');

		if (resource_infomation[resource+'s'].length === 0) {
			$(this).next().find('.select-sim-dropdown').addClass('is-loading');
			$(this).next().find('.resource-search').keyup();
		}

		// if (!checkVisible(this.nextElementSibling)) {
		// 	$(this).toggleClass('reverse');
		// 	while (!checkVisible(this.nextElementSibling)) {
		// 		$(this.nextElementSibling).addClass('no-arrow');

		// 		if ($(this).hasClass('reverse')) {
		// 			console.log(bottom);
		// 			var bottom = parseInt($(this.nextElementSibling).css('bottom'));
		// 			$(this.nextElementSibling).css({'bottom': bottom - 10, 'top': 'auto'});
		// 		} else {
		// 			console.log(top);
		// 			var top = parseInt($(this.nextElementSibling).css('top'));
		// 			$(this.nextElementSibling).css({'top': top + 10, 'bottom': 'auto'});
		// 		}
		// 	}
		// }

		event.stopPropagation();
	});

	$('body').on('click', '.select-sim-dropdown-container', function(event) {
		event.stopPropagation();
	});

	$(window).click(function() {
		$('.select-sim').removeClass('active');
		$('.product-pannel-collection-select').hide();
	});

	/*******************************************
	Resource Select functions and events
	*******************************************/

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
			error: basicError
		});
	}
      
	function deleteResource(params) {
		params.$this.addClass('is-loading');

		$.ajax({
			type: "POST",
			url: '/dashboard-delete',
      data: {
      	id: params.id,
      	resource: params.resource
      },
			dataType: "JSON",
			success: params.callback,
			error: basicError
		});
	}

	$('body').on('click', '.select-sim-dropdown .icon-trash', function() {
		var resource = $(this).data('resource');
		var id = $(this).data('id');
		var $this = $(this);
		var index_of_id;
		var resource_title = $(this).next().text();

		confirmBox(
			'Delete '+resource_title+'?', // confirm box title
			'Are you sure you want to delete '+resource_title+'? This action cannot be reversed.', // confirm box text
			'Delete', // confirm button text
			{
			yes: deleteResource // confirm function
			}, 
			{ // confirm function parameters 
				id: id,
				resource: resource,
				$this: $this,
				callback: function(deleted_resource) {
					console.log(deleted_resource);
					if (deleted_resource) {
						index_of_id = resource_infomation[resource+'s'].map(function(a) {return a.id}).indexOf(deleted_resource.id);
						resource_infomation[resource+'s'].splice(index_of_id, 1);

						if (resource.indexOf('collection') > -1) {
							index_of_id = resource_infomation['collections'].map(function(a) {return a.id}).indexOf(deleted_resource.id);
							resource_infomation['collections'].splice(index_of_id, 1);
							resource = 'collection';
						}
						resource_infomation[resource+'_total'] = resource_infomation[resource+'_total'] - 1;

						changePage(resource, resource_infomation[resource+'s'], resource_infomation[resource+'_page'], resource_infomation[resource+'_total']);
					}
				}
			}
		);
	});

	$('body').on('click', '.wittyEDTopButtons .delete-viewed-resource', function() {
		var resource = $(this).data('resource');
		var id = $(this).data('id');
		var $this = $(this);
		var index_of_id;
		var resource_title = $(this).data('title');
		var url = new URL(window.location.href);

		confirmBox(
			'Delete '+resource_title+'?', 
			'Are you sure you want to delete '+resource_title+'? This action cannot be reversed.', 
			'Delete', 
			{
			yes: deleteResource
			}, 
			{
				id: id,
				resource: resource,
				$this: $this,
				callback: function(deleted_resource) {
					console.log(deleted_resource);
					$this.removeClass('is-loading');
					flashMessage(resource_title + ' deleted.');
					if (url.searchParams.get("referrer")) {
						window.top.location.href = url.searchParams.get("referrer");
					} else {
						window.top.location.href = 'http://' + $('body').data('shopify-url');
					}
				}
			}
		);
	});

	function changePage(resource, resource_object, page, total) {
		var total_pages = Math.ceil(total/8);
		var new_html = '';
		page = Math.min(page, total_pages);
		page = Math.max(1, page);
		var max_bound = page*8 - 1;
		var min_bound = page*8 - 8;
		var data_resource = resource;
		resource_infomation[resource+'_page'] = page;

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
		if (page >= total_pages) {
			$('.select-sim-dropdown.'+resource+' + .arrow-navigation .icon-next').addClass('disabled');
		}

		$('.select-sim-dropdown.'+resource).find('.variable').remove();

		if (resource_object.length > 0) {
			for (var i = min_bound; i <= max_bound; i++) {
				if (resource == 'collection') {
					data_resource = resource;
					smart_ids = resource_infomation.smart_collections.map(function(sc) {
						return sc.id
					});
					custom_ids = resource_infomation.custom_collections.map(function(cc) {
						return cc.id
					});
					if (smart_ids.indexOf(resource_object[i].id) > -1) {
						data_resource = 'smart_collection';
					}

					if (custom_ids.indexOf(resource_object[i].id) > -1) {
						data_resource = 'custom_collection';
					}
				}

			  new_html += '<li class="variable">';
			  new_html += '<button type="button" class="sidebyside_small warning icon-trash" data-id="'+resource_object[i].id+'" data-resource="'+data_resource+'"></button>'
			  if (data_resource === 'product') {
					new_html += '<a href="/dashboard?resource='+data_resource+'&id='+resource_object[i].id+'" target="'+resource_infomation.target+'" data-handle="' + resource_object[i].handle + '" data-id="'+resource_object[i].id+'">';
				} else {
					new_html += '<a href="https://'+$('body').data('shopify-url')+'/admin/'+data_resource.replace('blog', 'article').replace(/smart_|custom_/, '')+'s/'+resource_object[i].id+'" target="_blank" data-handle="' + resource_object[i].handle + '" data-id="'+resource_object[i].id+'">';
				}
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

	// pull login from cookie if it exists and autofill form
	var permanent_domain = getCookie('permanent_domain');
	if (permanent_domain) {
		$('#myshopify_login').val(permanent_domain).closest('#myshopify_login_section').addClass('filled_login');
	}

	$('body').on('click', '.search .icon-next', function() {
		if (!$(this).hasClass('disabled')) {
			pageChangeSetResource($(this), 'next');
		}
	});

	$('body').on('click', '.search .icon-prev', function() {
		if (!$(this).hasClass('disabled')) {
			pageChangeSetResource($(this), 'prev');
		}
	});

	$('body').on('keyup', '.resource-search', function() {
		var minimum = 3;
		var exceptions = $(this).data('exceptions');

		if (exceptions === 'product-panel') {
			minimum = 0;
		}

		if ($(this).val().length >= minimum || $(this).val().length === 0) {
			var resource = $(this).data('resource');
			resource_infomation.query = $(this).val();
			$.ajax({
				url: '/search/'+resource+'?q='+resource_infomation.query+'&page=1',
				success: function(filtered_resource) {
					console.log(filtered_resource);
					$('.select-sim-dropdown').removeClass('is-loading');

					if (resource === 'collection') {
						resource_infomation[resource+'s'] = filtered_resource.collections;
						resource_infomation['smart_collections'] = filtered_resource.smart_collections;
						resource_infomation['custom_collections'] = filtered_resource.custom_collections;
						resource_infomation[resource+'_page'] = 1;
						resource_infomation[resource+'_total'] = filtered_resource.collections.length;
						resource_infomation[resource+'_chunks_loaded'] = 1;
						changePage(resource, filtered_resource.collections, 1, filtered_resource.collections.length);
					} else {
						resource_infomation[resource+'s'] = filtered_resource;
						resource_infomation[resource+'_page'] = 1;
						resource_infomation[resource+'_total'] = filtered_resource.length;
						resource_infomation[resource+'_chunks_loaded'] = 1;
						changePage(resource, filtered_resource, 1, filtered_resource.length);
					}
				},
				error: basicError
			});
		}
	});

	$('#resource-section').on('focus', '.resource-search[data-exceptions="product-panel"]', function() {
		$(this).next().show();
		$(this).next().find('.select-sim-dropdown').addClass('is-loading');
		$(this).keyup();
	});

	$('#resource-section').on('click', '.resource-search[data-exceptions="product-panel"]', function(event) {
		event.stopPropagation();
	});

	$('#resource-section').on('click', '.product-pannel-collection-select .variable a', function(event) {
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

	$('#resource-section').on('click', '.product-collections-select .icon-close', function() {
		var id = $(this).parent().data('collection').id;

		$('input#collection_'+id).remove();
		$(this).parent().remove();
	});

  // checkes variant checkboxes based on option value clicked
  $('#resource-section').on('click', '.variant-selector-link', function() {
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
	$('#resource-section').on('click', '.variant', function() {
		if (!$(this).hasClass('variant_open')) {
			$('.variant').removeClass('variant_open before_variant_open');
			$(this).addClass('variant_open');
			$(this).prev().addClass('before_variant_open');
		}
	});

	$('#resource-section').on('click', '.variant input[type="checkbox"]', function(e) {
		e.stopPropagation();
	});

	// submit form with AJAX
	$('#save_resource').click(function() {
		$(this).addClass('is-loading');
		$('.variant_input').prop('disabled', true);
		$('form.ajax').submit();
	});

	$('#resource-section').on("ajax:success", 'form.ajax', function(event, product) {
		$('#save_resource').removeClass('is-loading');
		$('#shopify_api_product_handle').val(product.handle);

		if (product.id) {
		  if (product.created_new_product) {
			  window.location.href = '/dashboard?id='+product.id+'&resource=product'
			} else {
				if (product.created_new_variants) {
					location.reload();
				}
			}
	  	var variant;
	    console.log("success product", product);

	    if (product.variants) {
		    for (var i = 0; i < product.variants.length; i++) {
		    	variant = product.variants[i];
		    	$('#variant_id_'+variant.id+' .edit_single_variant').data('object', variant);
		    }
		  }
	    // time to provide feedback 
		  flashMessage('Product was successfully saved');
		  refreshIframe();
			previousFormState = $('form.ajax').serialize();

		  if ($('#confirmBoxOverlay #extra').length > 0) {
		  	$('#confirmBoxOverlay').remove();
		  	shiftPannelsRight($('.check-for-unsaved'));
		  }
		} else {
			console.log(product);
		  if ($('#confirmBoxOverlay #extra').length > 0) {
		  	$('#confirmBoxOverlay').remove();
		  }

			if (product.error_message) {
				flashMessage(product.error_message, 'error');
			} else {
				flashMessage('Product was not saved', 'error');
			}
		}
    $('.variant_input').prop('disabled', false);
	});

	$('#resource-section').on("ajax:error", 'form.ajax', function(event, error){
  	console.log(event, error);

  	$('.variant_input').prop('disabled', false);
  	flashMessage('Product was not saved', 'error');
	});

	$('#resource-section').on('click', '.theme-editor__heading .more', function(e) {
		e.stopPropagation();
		$('.more-menu').toggleClass('open');
	});

	$('#resource-section').on('click', '.more-menu', function(e) {
		e.stopPropagation();
	});

	$('#give-feedback').click(function() {
		$('.trackduck-anonymous').click();
	});

	$('#send-message').click(function() {
		zE.activate();
	});

	// submit single variant
	$('.single_variant_submit').click(function(e) {
		if ($(this).hasClass('is-loading')) {
			return false;
		}

		$(this).addClass('is-loading');

		$('form.ajax [name]:not(.variant_input)').prop('disabled', true);
		var data = $('form.ajax').serialize();
		$('form.ajax [name]:not(.variant_input)').prop('disabled', false);

		var data_with_id = "product_id=" + $('[name="id"]').val() + '&' + data;

		// submit form with AJAX
    $.ajax({
      type: "POST",
      url: '/variant-update', //sumbits it to the given url of the form
      data: data_with_id,
      dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
    }).success(function(variant) {
      console.log(variant);
      $('.single_variant_submit').removeClass('is-loading');
      $('form.ajax [name]:not(.variant_input)').prop('disabled', false);

      if ($('.variant_input[name^="variants[new]"]').length > 0) {

				$('#section-edit-variant [name^="variants"]').each(function() {
					var variantName = $(this).attr('name'),
							variantId = $(this).attr('id'),
							nameRegexp = /variants\[([0-9]{11}|[a-z]{3})\].*\[(.+)\]/g,
							match = nameRegexp.exec(variantName),
							oldId = match[1],
							oldKey = match[2],
							hsc,
							$this = $(this);

					$(this).attr('name', variantName.replace(oldId, variant.id));
				});
				refreshVariantPanel();
      }
      previousVariantState = data;

    	if (variant.error_message) {
    		flashMessage(variant.error_message, 'error');
    	}	else {
	      refreshIframe();
	      flashMessage('Variant has been updated successfully.');
	      $('[data-object*="'+variant.id+'"]').data('object', variant);
	      $('#variants_'+variant.id+'_option1').val(variant.option1);
	      $('#variants_'+variant.id+'_option2').val(variant.option2);
	      $('#variants_'+variant.id+'_option3').val(variant.option3);
	      $('#variants_'+variant.id+'_inventory_quantity').val(variant.inventory_quantity);
	      $('#variants_'+variant.id+'_compare_at_price').val(variant.compare_at_price);
	      $('#variants_'+variant.id+'_price').val(variant.price);
	      $('#variants_'+variant.id+'_sku').val(variant.sku);

	      $('.new_hsc_name').remove();

				$.ajax({
		      type: "GET",
		      url: '/variant-hsc', //sumbits it to the given url of the form
		      data: {
		      	variant_id: variant.id
		      },
		      dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
		    }).success(function(hsc) {
		    	var $this = $('.harmonized_system_code');
		    	console.log(hsc);

					if (hsc) {
						$this.val(hsc.value);
						$this.before('<input value="harmonized_system_code" class="new_hsc_name variant_input" type="hidden" name="variants['+variant.id+']metafields['+hsc.id+'][name]" id="variants_'+variant.id+'_new_metafields__name">');
						$this.attr('name', 'variants['+variant.id+']metafields['+hsc.id+'][value]');
						$this.attr('id', 'variants_'+variant.id+'_metafields_'+hsc.id+'_value');
					} else {
						$this.val('');
						$this.before('<input value="harmonized_system_code" class="new_hsc_name variant_input" type="hidden" name="variants['+variant.id+']new_metafields[][name]" id="variants_'+variant.id+'_new_metafields__name">');
						$this.attr('name', 'variants['+variant.id+']new_metafields[][value]');
						$this.attr('id', 'variants_'+variant.id+'_new_metafields__value');
					}

					$('form.ajax [name]:not(.variant_input)').prop('disabled', true);
					previousVariantState = $('form.ajax').serialize();
					$('form.ajax [name]:not(.variant_input)').prop('disabled', false);
		    }).error(basicError);
	    }
      // time to provide feedback 
    }).error(function(e) {
    	console.log(e);
    	flashMessage('Variant failed to update successfully.', 'error');
    	$('form.ajax [name]:not(.variant_input)').prop('disabled', false);
    });
		return false; // prevents normal behaviour
	});

	// $('#resource-section').on('click', '.warning.btn_bottom.variant', function(e) {
	// 	e.preventDefault();
	// 	var id = $(this).data('id');
	// 	var resource_title = $(this).data('title');

	// 	confirmBox('Delete '+resource_title+'?', 'Are you sure you want to delete the variant '+resource_title+'? This action cannot be reversed.', 'Delete', {
	// 		yes: function() {
	// 			window.location.href = url;
	// 		}
	// 	});
	// });

	// edit single variant
	$('#resource-section').on('click', '.edit_single_variant', function(e) {
		e.preventDefault();
		e.stopImmediatePropagation();

		var $panelThis = $(this);
		var image = $(this).data('image');
		var variant = $(this).data('object');

		$panelThis.addClass('is-loading');

		$('.variant-image').remove();
		if (image) {
			$('.image_box').prepend('<img class="variant-image quark" src="'+image+'">');
			$('.image_box .variant_image').data('image-id', variant.image_id);
			$('.image_box .variant_image').data('variant-id', variant.id);
		} else {
			$('.image_box .variant_image').data('image-id', '');
			$('.image_box').prepend('<div class="column twelve type--centered no_margin variant-image"><i class="image icon-image next-icon--size-80"></i><h5>Choose image</h5></div>');
		}

		$('.warning.btn_bottom.variant-delete').data('id', variant.id).data('title', variant.title);

		$('.new_hsc_name').remove();

		$('#section-edit-variant [name^="variants"]').each(function() {
			var variantName = $(this).attr('name'),
					variantId = $(this).attr('id'),
					nameRegexp = /variants\[([0-9]{11}|[a-z]{3})\].*\[(.+)\]/g,
					match = nameRegexp.exec(variantName),
					oldId = match[1],
					oldKey = match[2],
					hsc,
					$this = $(this);


			if (variant.id === 'new') {

				if ($this.hasClass('harmonized_system_code')) {
					$this.val('');
					$this.before('<input value="harmonized_system_code" class="new_hsc_name variant_input" type="hidden" name="variants['+variant.id+']new_metafields[][name]" id="variants_'+variant.id+'_new_metafields__name">');
					$this.attr('name', 'variants['+variant.id+']new_metafields[][value]');
					$this.attr('id', 'variants_'+variant.id+'_new_metafields__value');
				} else {
					$(this).attr('name', variantName.replace(oldId, variant.id));
					$(this).val('');
					if (variantId) $(this).attr('id', variantId.replace(oldId, variant.id));
				}

			} else {
				if (variant.hasOwnProperty(oldKey)) {
					$(this).attr('name', variantName.replace(oldId, variant.id));
					$(this).val(variant[oldKey]);
					if (variantId) $(this).attr('id', variantId.replace(oldId, variant.id));
				} else {

					$.ajax({
			      type: "GET",
			      url: '/variant-hsc', //sumbits it to the given url of the form
			      data: {
			      	variant_id: variant.id
			      },
			      dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
			    }).success(function(hsc) {
			    	console.log('hsc:', hsc);
						if (hsc) {
							$this.val(hsc.value);
							$this.before('<input value="harmonized_system_code" class="new_hsc_name variant_input" type="hidden" name="variants['+variant.id+']metafields['+hsc.id+'][name]" id="variants_'+variant.id+'_new_metafields__name">');
							$this.attr('name', 'variants['+variant.id+']metafields['+hsc.id+'][value]');
							$this.attr('id', 'variants_'+variant.id+'_metafields_'+hsc.id+'_value');
						} else {
							$this.val('');
							$this.before('<input value="harmonized_system_code" class="new_hsc_name variant_input" type="hidden" name="variants['+variant.id+']new_metafields[][name]" id="variants_'+variant.id+'_new_metafields__name">');
							$this.attr('name', 'variants['+variant.id+']new_metafields[][value]');
							$this.attr('id', 'variants_'+variant.id+'_new_metafields__value');
						}

						$('form.ajax [name]:not(.variant_input)').prop('disabled', true);
						previousVariantState = $('form.ajax').serialize();
						$('form.ajax [name]:not(.variant_input)').prop('disabled', false);

						$('#save_resource').hide();
						$('.single_variant_submit').show();
						$panelThis.removeClass('is-loading');
						shiftPannelsLeft($panelThis);
			    }).error(basicError);
				}

			}
		});

		if (variant.id === 'new') {
			$('form.ajax [name]:not(.variant_input)').prop('disabled', true);
			previousVariantState = $('form.ajax').serialize();
			$('form.ajax [name]:not(.variant_input)').prop('disabled', false);

			$('#save_resource').hide();
			$('.single_variant_submit').show();
			$panelThis.removeClass('is-loading');
			shiftPannelsLeft($panelThis);
		}

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
	
		variant_image_page = 0;
		changeVariantImagePage(variant_image_page);

		$('#editVariantImageOverlay').addClass('open');
	}

	function changeVariantImagePage(page) {
		if (page <= 0) {
			$('#editVariantImage .icon-prev').addClass('disabled');
		} else {
			$('#editVariantImage .icon-prev').removeClass('disabled');
		}

		if (page >= Math.floor(($('.variant-select-image-label').length-1)/10)) {
			$('#editVariantImage .icon-next').addClass('disabled');
		} else {
			$('#editVariantImage .icon-next').removeClass('disabled');
		}

		$('.variant-select-image-label').hide();
		$('.variant-select-image-label[data-page="'+page+'"]').show();
	}

	$('#modals-container').on('click', '#editVariantImage .icon-prev', function() {
		if (!$(this).hasClass('disabled')) {
			variant_image_page--;
			changeVariantImagePage(variant_image_page);
		}
	});

	$('#modals-container').on('click', '#editVariantImage .icon-next', function() {
		if (!$(this).hasClass('disabled')) {
			variant_image_page++;
			changeVariantImagePage(variant_image_page);
		}
	});

	$('#resource-section').on('blur', '#tag-field', function() {
		$(this).val('');
		$('.tag-error').hide();
	});

	$('#resource-section').on('keyup', '#tag-field', function(e) {
		$('.tag-error').hide();
    if (e.key === ',') {
    	var tag_text = $(this).val().replace(',', '');
    	var tag_list = $('#shopify_api_product_tags').val().split(',').filter(function(value) {
    		return value !== '';
    	}).map(function(value, index) {
	  		return value.trim();
    	});

    	if (tag_text.trim() === '') {
    		$(this).val(tag_text.replace(',', ''));
    	} else if (tag_list.indexOf(tag_text.trim()) > -1) {
    		$('.tag-error span').text(tag_text);
    		$('.tag-error').show();
    	} else {
	    	tag_list.push(tag_text.trim())
				$('#shopify_api_product_tags').val(tag_list.join(','));
	    	$(this).val('');
	    	tag = '<span class="tag teal remove">'+tag_text+'<a href="#"></a></span>';
	    	$('.tags-container').append(tag);
	    }
    }
  });

	$('#resource-section').on('click', '.tags-container .tag.remove a', function(e) {
		e.preventDefault();
		var tag = $(this).parent().remove().text().trim();
		var tag_list = $('#shopify_api_product_tags').val().split(',').map(function(a) {return a.trim()});
		var tag_index = tag_list.indexOf(tag);

		tag_list.splice(tag_index, 1);
		$('#shopify_api_product_tags').val(tag_list.join(','));
	});

	$('#modals-container').on('click', '.variant-image-save', function(e) {
		$(this).addClass('is-loading');
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
    	closeModal($('#editVariantImageOverlay'));
    	console.log(image);

    	$('.image_box .variant_image').data('image-id', image.id);
    	$('#variant_id_'+variant_id+' .variant_image').data('image-id', image.id).attr('data-image-id', image.id);
    	$('#variant_id_'+variant_id+' .edit_single_variant').data('image', image.src);
    	var variant_object = $('#variant_id_'+variant_id+' .edit_single_variant').data('object');
    	variant_object.image_id = image.id;
    	$('#variant_id_'+variant_id+' .edit_single_variant').data('object', variant_object);

    	$('.variant-image').remove();
    	$('#variant_id_'+variant_id+' .variant_image *').remove();
    	if (image.id) {
	    	$('#variant_id_'+variant_id+' .variant_image').prepend('<img src="'+image.src+'">');
	    	$('.image_box').prepend('<img class="variant-image" src="'+image.src+'">');
	    	flashMessage('Variant has been updated successfully.');
	    } else {
	    	$('#variant_id_'+variant_id+' .variant_image').prepend('<i class="icon-image"></i>');
	    	$('.image_box').prepend('<div class="column twelve type--centered no_margin variant-image"><i class="image icon-image next-icon--size-80"></i><h5>Choose image</h5></div>');
	    	flashMessage('Variant image has been removed successfully.');
	    }

	    refreshIframe();
    	$('.variant-image-save').removeClass('is-loading');
    }).error(function(e) {
    	console.log(e);
    });
	});

	$('#resource-section').on('click', '#view-all-tags', function(e) {
		e.preventDefault();
		$(this).addClass('is-loading');

		$.ajax({
      type: "GET",
      url: '/product-tags'
    }).success(function(tags) {
    	tags = tags.filter(onlyUnique);

    	$('#view-all-tags').removeClass('is-loading');
  		$('#viewAllTagsOverlay .all-tags').empty();
  		$('#viewAllTagsOverlay .applied-tags').empty();
  		$('#viewAllTagsOverlay .applied-tags').next().show();

    	for (var i = 0; i < tags.length; i++) {
    		if (tags[i].trim() !== "") {
		    	$('#viewAllTagsOverlay .all-tags').append('<span class="tag teal" data-tag="'+tags[i]+'">'+tags[i]+'</span>');
		    }
	    }

    	$('#viewAllTagsOverlay').addClass('open');
    }).error(basicError);
	});

	$('#modals-container').on('click', '.all-tags .tag', function() {
		var tag = $(this).data('tag');
		if ($('.applied-tags .tag[data-tag="'+tag+'"]').length > 0) {
			$('.applied-tags .tag[data-tag="'+tag+'"]').remove();
			$(this).removeClass('greyed-out');
		} else {
			$('.applied-tags').append('<span class="tag teal remove" data-tag="'+tag+'">'+tag+'<a href="#"></a></span>');
			$(this).addClass('greyed-out');
		}

		if ($('.applied-tags .tag').length > 0) {
			$('.applied-tags').next().hide();
		} else {
			$('.applied-tags').next().show();
		}
	});

	$('#modals-container').on('click', '.applied-tags .tag.remove a', function() {
		var tag = $(this).parent().data('tag');

		$('.all-tags .tag[data-tag="'+tag+'"]').removeClass('greyed-out');
		$(this).parent().remove();

		if ($('.applied-tags .tag').length > 0) {
			$('.applied-tags').next().hide();
		} else {
			$('.applied-tags').next().show();
		}
	});

	$('#modals-container').on('click', '#apply-tag-changes', function() {
		$('.applied-tags .tag').each(function() {
			var tag_text = $(this).data('tag');
    	var tag_list = $('#shopify_api_product_tags').val().split(',').filter(function(value) {
    		return value !== '';
    	}).map(function(value, index) {
	  		return value.trim();
    	});

      if (tag_list.indexOf(tag_text.trim()) === -1) {
	    	tag_list.push(tag_text.trim())
				$('#shopify_api_product_tags').val(tag_list.join(','));
	    	$(this).val('');
	    	tag = '<span class="tag teal remove">'+tag_text+'<a href="#"></a></span>';
	    	$('.tags-container').append(tag);
	    }
		});

		$('#viewAllTagsOverlay').removeClass('open');
	});

	$('#resource-section').on('click', '#view-all-types', function(e) {
		e.stopPropagation();

		$('.input-group.select-sim.no-style').removeClass('active');
  	$('.product-types .select-sim-dropdown').addClass('is-loading');
  	$(this).parent().addClass('active');
		$.ajax({
      type: "GET",
      url: '/product-types'
    }).success(function(types) {
    	console.log(types);
    	var new_html = '';

    	for (var i = 0; i < types.length; i++) {
    		if (types[i] !== '') {
		    	new_html += '<li class="variable">';
			    	new_html += '<a class="product-type-selector" href="#">';
				    	new_html += types[i];
			    	new_html += '</a>';
		    	new_html += '</li>';
		    }
	    }
	    
	    $('.product-types .select-sim-dropdown .variable').remove();
	    $('.product-types .select-sim-dropdown').removeClass('is-loading').append(new_html);

    }).error(basicError);
	});

	$('#resource-section').on('click', '.product-type-selector', function(e) {
		e.preventDefault();

		$('#shopify_api_product_product_type').val($(this).text());
		$(this).closest('.select-sim-dropdown-container').prev().removeClass('active');
	});

	$('#resource-section').on('click', '#view-all-vendors', function(e) {
		e.stopPropagation();

		$('.input-group.select-sim.no-style').removeClass('active');
  	$('.product-vendors .select-sim-dropdown').addClass('is-loading');
		$(this).parent().addClass('active');
		$.ajax({
      type: "GET",
      url: '/product-vendors'
    }).success(function(vendors) {
    	console.log(vendors);
    	var new_html = '';

    	for (var i = 0; i < vendors.length; i++) {
    		if (vendors[i] !== '') {
		    	new_html += '<li class="variable">';
			    	new_html += '<a class="product-vendor-selector" href="#">';
				    	new_html += vendors[i];
			    	new_html += '</a>';
		    	new_html += '</li>';
		    }
	    }

	    $('.product-vendors .select-sim-dropdown .variable').remove();
	    $('.product-vendors .select-sim-dropdown').removeClass('is-loading').append(new_html);
    }).error(basicError);
	});

	$('#resource-section').on('click', '.product-vendor-selector', function(e) {
		e.preventDefault();

		$('#shopify_api_product_vendor').val($(this).text());
		$(this).closest('.select-sim-dropdown-container').prev().removeClass('active');
	});

	$('#modals-container').on('click', '#editVariantImage #variant-add-image', function() {
		$('.link_label[for="shopify_api_product_file"]').click();
	});

	$('#resource-section').on('click', '.variant_image', function(e) {
		e.preventDefault();
		$parent = $(this).parent().parent();

		if ($parent.hasClass('variant_open') || $parent.hasClass('drop_images')) {
			editVariantImage($(this));
		}
	});

	$('#resource-section').on('click', '#addImageUrlLink', function(e) {
		e.preventDefault();

		$('#addImageUrlOverlay').addClass('open');
	});

	/*******************************************
	Links at the top of the Variant Panel
	*******************************************/

	$('#resource-section').on('click', '#reorderVariantsLink', function(e) {
		e.preventDefault();

		$('#reorderVariantsOverlay').addClass('open');
	});

	$('#modals-container').on('mousedown', '#reorderVariants .option-item', function(e) {
		this_elem = this;
    e = e || window.event;
    var start = 0, diff = 0;
    if( e.pageY) start = e.pageY;
    else if( e.clientY) start = e.clientY;

    this_elem.style.position = 'relative';
    document.body.onmousemove = function(e) {
      e = e || window.event;
      var end = 0;
      if( e.pageY) end = e.pageY;
      else if( e.clientY) end = e.clientY;

      diff = end-start;

			if (diff >= 54 && $(this_elem).next().length > 0) {
				$(this_elem).next().after($(this_elem));
				start = start + 54;
				diff = 0;
			} else if (diff <= -54 && $(this_elem).prev().length > 0) {
				$(this_elem).prev().before($(this_elem));
				start = start - 54;
				diff = 0; 
			}

      this_elem.style.top = diff+"px";

    };
    document.body.onmouseup = function() {
        // do something with the action here
        // elem has been moved by diff pixels in the X axis
        this_elem.style.position = 'static';
        this_elem.style.top = 0;
        document.body.onmousemove = document.body.onmouseup = null;
    };
	});

	$('#modals-container').on('mousedown', '#reorderVariants .value-item', function(e) {
		e.stopPropagation();
		this_elem = this;
    e = e || window.event;
    var start = 0, diff = 0;
    if( e.pageX) start = e.pageX;
    else if( e.clientX) start = e.clientX;

    this_elem.style.position = 'relative';
    document.body.onmousemove = function(e) {
      e = e || window.event;
      var end = 0;
      if( e.pageX) end = e.pageX;
      else if( e.clientX) end = e.clientX;

      diff = end-start;

			if ($(this_elem).next().length > 0 && diff >= $(this_elem).next().outerWidth()) {
				start = start + $(this_elem).next().outerWidth();
				$(this_elem).next().after($(this_elem));
				diff = 0;
			} else if ($(this_elem).prev().length > 0 && diff <= -1*$(this_elem).prev().outerWidth()) {
				start = start - $(this_elem).prev().outerWidth();
				$(this_elem).prev().before($(this_elem));
				diff = 0; 
			}

      this_elem.style.left = diff+"px";

    };
    document.body.onmouseup = function() {
        // do something with the action here
        // elem has been moved by diff pixels in the X axis
        this_elem.style.position = 'static';
        this_elem.style.left = 0;
        document.body.onmousemove = document.body.onmouseup = null;
    };
	});

	$('#modals-container').on('click', '#save-reorder-variants', function() {
		$(this).addClass('is-loading');
		var optionsOrder = {}

		$('#reorderVariants .option-item').each(function(option_index, element) {
			var values = [];

			$(this).find('.value-item').each(function(value_index, element) {
				console.log(element);

				values.push($(element).data('value'));
			});

			optionsOrder[$(element).data('id')] = {
				index: option_index,
				values: values
			};
		});

		console.log(optionsOrder);
		$.ajax({
      type: "POST",
      url: '/reorder-variants',
      data: {
      	id: $('[name="id"]').val(),
      	options: optionsOrder
      },
      dataType: "JSON"
    }).success(function(new_options) {
    	console.log(new_options);

    	refreshVariantPanel();

    	$('#save-reorder-variants').removeClass('is-loading');
    	closeModal($('#reorderVariantsOverlay'));
    	flashMessage('The order of your product variants was successfully saved.');
    	refreshIframe();

    }).error(function(error) {
    	console.log(error);
    	flashMessage('The order of your product variants failed to save.', 'error');
    });
	});

	$('#resource-section').on('click', '#editOptionsLink', function(e) {
		e.preventDefault();

		$('#editOptionsOverlay').addClass('open');
	});

	$('#modals-container').on('click', '#save-edit-options', function(e) {
		var new_option_names = {}
		var $this = $(this);

		$this.addClass('is-loading');
		$('#editOptions .option-item').each(function() {
			new_option_names[$(this).data('id')] = $(this).find('.option-input').val();
		});

		$.ajax({
      type: "POST",
      url: '/edit-options',
      data: {
      	id: $('[name="id"]').val(),
      	option_names: new_option_names
      },
      dataType: "JSON"
    }).success(function(new_options) {
			console.log(new_options);

			refreshVariantPanel();
			refreshIframe();

 			$this.removeClass('is-loading');
			flashMessage('Your options have been updated.');
			closeModal($('#editOptionsOverlay'));

    }).error(function(erro) {
    	console.log(error);
    	flashMessage('There was a problem updating your product options', 'error');
    });

	});

	$('#modals-container').on('click', '#editOptions .value-item a', function(e) {
		e.preventDefault();
		var $this = $(this);
		var value = $(this).parent().data('value'),
				option = $(this).parent().data('option'),
				optionIndex = $(this).parent().data('option-index'),
				variantAmount = $('.variant[data-option'+optionIndex+'="'+value+'"]').length,
				variant_ids = [];

		$('.variant[data-option'+optionIndex+'="'+value+'"]').each(function() {
			variant_ids.push($(this).data('id'));
		});

		closeModal($('#editOptionsOverlay'));
	  confirmBox(
	  	'Are you sure you want to delete this option value?', // Title of confirm Box
	  	'You are about to delete <strong>all '+variantAmount+' variants</strong> with a <strong>'+option+'</strong> of <strong>'+value+'</strong>. Deleted variants cannot be recovered.', // Text of confirm Box
	  	'Delete',
	  	{ // Confirm Button Text
		  	yes: function() { // function for confirm button
		  		$('#editOptionsLink').addClass('is-loading');

		  		$.ajax({
			      type: "POST",
			      url: '/dashboard-bulk-delete',
			      data: {
			      	resource_ids: variant_ids,
			      	resource: 'variant'
			      },
			      dataType: "JSON"
		  		}).success(function(deleted_resource) {
		  			console.log(deleted_resource);
		  			$('#editOptionsLink').removeClass('is-loading');

		  			refreshVariantPanel();

		  		}).error(basicError);
		  	}
		  }
  	);
	});

	function addImagesCallback(images) {
		$('.images-container .column.twelve').remove();
  	$('#shopify_api_product_file').val('');
  	console.log(images);
  	var dataPageTotal = Math.floor(($('.variant-select-image-label').length-1)/10);
  	if ($('.variant-select-image').attr('name')) {
	  	var variantIdRegex = $('.variant-select-image').attr('name').match(/[0-9]{11}/);
	  }
  	var variantId = '';
  	if (variantIdRegex) {variantId = variantIdRegex[0]}

  	images.forEach(function(image, index) {

    	var image_html = '';
    	var variant_image_html = '';
  		image_html += '<div class="product-image" data-id="'+image.id+'" draggable="true">';
      	image_html += '<img src="'+image.src+'">';
        image_html += '<div class="overlay">';
          image_html += '<div class="icons-container">';
            image_html += '<i class="image icon-preview next-icon--size-16"></i>';
            image_html += '<i class="next-icon--size-16 alt-tag">ALT</i>';
            image_html += '<i class="image icon-trash next-icon--size-16"></i>';
          image_html += '</div>';
        image_html += '</div>';
      image_html += '</div>';

      variant_image_html += '<input type="radio" id="variant-select-image-'+image.id+'" class="variant-select-image" name="variants['+variantId+'][image_id]" value="'+image.id+'">';
      variant_image_html += '<label for="variant-select-image-'+image.id+'" class="variant-select-image-label" data-page="'+Math.floor(index/10)+'" style="display: flex;">';
        variant_image_html += '<img src="'+image.src+'">';
      variant_image_html += '</label>';

      if ($('.product-image[data-id="'+image.id+'"]').length === 0) {
        $('.images-container').append(image_html);
      }

      if ($('#variant-select-image-'+image.id+'').length === 0) {
      	$('#editVariantImage .card-section:eq(1)').append(variant_image_html);
      }
  	});
		
		$('#variant-add-image').removeClass('is-loading');
		$('body').removeClass('is-loading-body');
		flashMessage('Image(s) Added');
		refreshIframe();

		variant_image_page = dataPageTotal;
		changeVariantImagePage(variant_image_page);
		closeModal($('#addImageUrlOverlay'));
  }

	$('#resource-section').on('change', '#shopify_api_product_file', function() {
		var data = [];
		var files = Array.from(this.files);
		console.log(files);
		$('#variant-add-image').addClass('is-loading');
		$('body').addClass('is-loading-body');

		function getBase64(file, total_files, callback) {
	  	var reader = new FileReader();
	  	reader.readAsDataURL(file);
	  	reader.onload = function () {
	    	data.push(reader.result.replace(/data:image\/[a-z]{3,4};base64,/, ''));
	    	if (data.length === total_files) {
	    		callback(data);
	    	}
	  	};
	  	reader.onerror = function (error) {
	  		console.log('Error: ', error);
	  	};
		}

		files.forEach(function(file) {
			getBase64(file, files.length, function(data) {
				if ($('[name="id"]').val() === 'new') {
					$('.images-container .column.twelve').remove();
			  	$('#shopify_api_product_file').val('');
			  	console.log(data);
			  	var dataPageTotal = Math.floor(($('.variant-select-image-label').length-1)/10);

			  	data.forEach(function(imageBase64, index) {

			    	var image_html = '';
			  		image_html += '<div class="product-image" draggable="true">';
				    	image_html += '<input type="hidden" name="shopify_api_product[files][]" value="'+imageBase64+'">';
			      	image_html += '<img src="data:image/png;base64,'+imageBase64+'">';
			        image_html += '<div class="overlay">';
			          image_html += '<div class="icons-container">';
			            image_html += '<i class="image icon-preview next-icon--size-16"></i>';
			            image_html += '<i class="next-icon--size-16 alt-tag">ALT</i>';
			            image_html += '<i class="image icon-trash next-icon--size-16"></i>';
			          image_html += '</div>';
			        image_html += '</div>';
			      image_html += '</div>';

			      $('.images-container').append(image_html);
			  	});

					$('#variant-add-image').removeClass('is-loading');
					$('body').removeClass('is-loading-body');

					closeModal($('#addImageUrlOverlay'));
				} else {
					$.ajax({
			      type: "POST",
			      url: '/add-images', // sumbits it to the given url of the form
			      data: {
			      	id: $('[name="id"]').val(),
			      	images: data
			      },
			      dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
					}).success(addImagesCallback).error(function(e) {
			    	console.log(e);
			    });
			  }
			});
		});
	});

	$('#modals-container').on('click', '#add-image-from-url', function() {
		$('#variant-add-image').addClass('is-loading');
		$('body').addClass('is-loading-body');

		$.ajax({
      type: "POST",
      url: '/add-image-from-url',
      data: {
      	id: $('[name="id"]').val(),
      	src: $('#addImageUrlInput').val()
      },
      dataType: "JSON"
    }).success(addImagesCallback).error(basicError);
	});

	var dragCounter = 0;
	var $dragSrcEl = null;
	var $dragIcon;

	$('#resource-section').on({
		dragstart: function(e) {
			$dragSrcEl = $(this); // set original element
			e.originalEvent.dataTransfer.effectAllowed = 'move';
			e.originalEvent.dataTransfer.setData('text/html', $dragSrcEl);

			$dragIcon = $dragSrcEl.clone(); // copy original element for ghost image
			$dragIcon.addClass('ghostImage').find('.overlay').remove();
			if ($dragSrcEl.index() === 0) {$dragIcon.addClass('first')} // for proper width; the first image is wider
			$('.images-container').append($dragIcon);
			e.originalEvent.dataTransfer.setDragImage($dragIcon[0], e.offsetX, e.offsetY);

			$dragSrcEl.addClass('dragging'); // this class makes it look like a blank square; only editing the original after it's already been cloned 
		},
		dragenter: function(e) {
			e.preventDefault();
			dragCounter++; // needed to account for child elements
			$('.product-image').removeClass('over');
			$(this).addClass('over');
		},
		dragover: function(e) {
			e.preventDefault();
			e.stopPropagation();

			if (!$(this).hasClass('dragging')) {
				if ($(this).isAfter($dragSrcEl)) {
					$(this).after($dragSrcEl);
					return;
				}
				if ($(this).isBefore($dragSrcEl)) {
					$(this).before($dragSrcEl);
				}
			}
		},
		dragleave: function(e) {
			dragCounter--; // needed to account for child elements
			if (dragCounter === 0) {
				$(this).removeClass('over');
			}
		},
		dragend: function() {
			$(this).removeClass('dragging');
			$dragSrcEl.show();
			$dragIcon.remove();
		},
		drop: function(e) {
			e.preventDefault();
			e.stopPropagation();

			$('.images-container .product-image').removeClass('over');
			dragCounter = 0;

		  // Don't do anything if dropping the same item we're dragging.
		  if ($dragSrcEl != $(this)) {
		  	var imageOrders = {};

		  	$('.images-container .product-image:not(.ghostImage)').each(function(index, element) {
		  		imageOrders[$(element).data('id')] = index;
		  	});

		  	if ($('[name="id"]').val() !== 'new') {
					$.ajax({
			      type: "POST",
			      url: '/change-image-order',
			      data: {
			      	id: $('[name="id"]').val(),
			      	image_orders: imageOrders
			      },
			      dataType: "JSON"
			    }).success(function(images) {
			    	console.log(images);
			    	flashMessage('Image order has been saved.');
			    	refreshIframe();
			    }).error(function(error) {
			    	console.log(error);
			    	flashMessage('Image order failed to save.', 'error');
			    });
			  }
		  }
		}
	}, '.images-container .product-image');

	$('#resource-section').on('keyup', '#shopify_api_product_handle', function() {
		var tooltiptext = $('#SEOURL #SEOURL-url').text().split('/');
		tooltiptext[tooltiptext.length - 1] = $(this).val();
		$('#SEOURL #SEOURL-url').text(tooltiptext.join('/'))
	});

	$('#resource-section').on('click', '#duplicateProductLink', function(e) {
		e.preventDefault();
		$('#duplicateProductOverlay').addClass('open');
	});

	// $('#modals-container').on('click', '#duplicate-product', function(e) {
	// 	$.ajax({
 //      type: "POST",
 //      url: '/duplicate-product',
 //      data: {
 //      	id: $('[name="id"]').val(),
 //      	new_title: $('#duplicateProductInput').val()
 //      },
 //      dataType: "JSON"
 //    })
	// });

	$('#resource-section').on('click', '.images-container .icon-preview', function() {
		var image = $(this).parent().parent().prev().attr('src');

		$('#image-preview').attr('src', image);
		$('#previewOverlay').addClass('open');
	});

	$('#modals-container').on('click', '#preview', function(e) {
		e.stopPropagation();
	});

	$('#resource-section').on('click', '.alt-tag', function() {
		var image = $(this).parent().parent().prev().attr('src');
		var image_id = $(this).parent().parent().parent().data('id');
		var $productImage = $(this).closest('.product-image');

		$productImage.addClass('is-loading');

		$('#image-for-alt-tag').attr('src', image);
		$('#image-for-alt-tag').data('image-id', image_id);

		$.ajax({
      type: "GET",
      url: '/alt-tag',
      data: {
      	image_id: image_id
      },
      dataType: "JSON"
    }).success(function(alt_tag_metafield) {
    	console.log(alt_tag_metafield);
    	$productImage.removeClass('is-loading');

    	if (alt_tag_metafield) {
	    	$('#image-alt-tag').data('metafield-id', alt_tag_metafield.id).val(alt_tag_metafield.value);
			} else {
				$('#image-alt-tag').data('metafield-id', 'new').val('');
			}

			$('#editAltTagOverlay').addClass('open');
    }).error(basicError);
	});

	$('#modals-container').on('click', '#editAltTag #image-alt-tag-save', function() {
		var metafield_id = $('#image-alt-tag').data('metafield-id');
		var image_id = $('#image-for-alt-tag').data('image-id');
		var alt_tag = $('#image-alt-tag').val();

		$('#image-alt-tag-save').addClass('is-loading');

		$.ajax({
      type: "POST",
      url: '/alt-tag',
      data: {
      	metafield_id: metafield_id,
      	image_id: image_id,
      	alt_tag: alt_tag
      },
      dataType: "JSON"
    }).success(function(alt_tag_metafield) {
    	console.log(alt_tag_metafield);
    	$('#image-alt-tag-save').removeClass('is-loading');
    	flashMessage('The image has been updated.');
    	refreshIframe();
    	closeModal($('#editAltTagOverlay'));
    }).error(function(error) {
    	console.log(error);
    	$('#image-alt-tag-save').removeClass('is-loading');
    	flashMessage('The image failed to update.');
    });
	});

	$('#modals-container').on('click', '#editAltTag', function(e) {
		e.stopPropagation();
	});

	$('#resource-section').on('click', '.images-container .image.icon-trash', function() {
		var product_id = $('[name="id"]').val();
		var image_id = $(this).closest('.product-image').data('id');
		var $overlay = $(this).closest('.product-image');

		confirmBox('Delete this image?', 'Are you sure you want to delete this image and remove it from all variants? This action cannot be reversed.', 'Delete', {
			yes: function(params) {
				var no_image_html = '';
				$overlay.addClass('is-loading');
				if ($('[name="id"]').val() === 'new') {
					$overlay.remove();
		    	if ($('.images-container .product-image').length === 0) {
						no_image_html += '<div class="column twelve type--centered no_margin">';
	            no_image_html += '<i class="image icon-photos next-icon--size-80"></i>';
	            no_image_html += '<h5>Drop images to upload</h5>';
	          no_image_html += '</div>';
	          $('.images-container').append(no_image_html);
	        }
    		} else {
					$.ajax({
			      type: "POST",
			      url: '/delete-image', // sumbits it to the given url of the form
			      data: {
			      	product_id: params.product_id,
			      	image_id: params.image_id
			      },
			      dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
			    }).success(function(image) {
			    	var no_image_html = '';
			    	console.log(image);
			    	flashMessage('The image has been deleted.');
			    	refreshIframe();
			    	$('.variant .variant_image[data-image-id="'+image.id+'"]').prepend('<i class="icon-image"></i>').find('img').remove();
			    	$('.variant .variant_image[data-image-id="'+image.id+'"]').each(function() {
			    		$(this).closest('.variant').find('.edit_single_variant').data('image', null);
			    	});

			    	$('.product-image[data-id="'+image.id+'"]').remove();

			    	if ($('.images-container .product-image').length === 0) {
							no_image_html += '<div class="column twelve type--centered no_margin">';
		            no_image_html += '<i class="image icon-photos next-icon--size-80"></i>';
		            no_image_html += '<h5>Drop images to upload</h5>';
		          no_image_html += '</div>';
		          $('.images-container').append(no_image_html);
		        }

			    	$('#variant-select-image-'+image.id).remove();
			    	$('.variant-select-image-label[for="variant-select-image-'+image.id+'"]').remove();

			    	$('.variant-select-image-label').each(function(index) {
			    		$(this).attr('data-page', Math.floor(index/10));
			    	});
			    }).error(function(e) {
			    	console.log(e);
			    	flashMessage('The image failed to be deleted.', 'error');
			    });
			  }
			}
		},
		{
			product_id: product_id,
			image_id: image_id
		});
	});

	$('#resource-section').on('click', '.info-icon', function() {
		$('#SEOURLOverlay').addClass('open');
	});

	$('#resource-section').on('click', '.warning.btn_bottom.product', function(e) {
		e.preventDefault();
		var resource_title = $(this).data('resource');
		var url = $(this).find('a').attr('href');

		confirmBox(
			'Delete '+resource_title+'?', // title for confirm box
			'Are you sure you want to delete the '+resource_title+'? This action cannot be reversed.', // text for confirm box
			'Delete', // confirm button text
			{
			yes: function() { // confirm function
				window.location.href = url;
			}
		});
	});

	$('#resource-section').on('click', '.warning.variant-delete', function(e) {
		e.preventDefault();
		var resource = $(this).data('resource');
		var resource_title = $(this).data('title');
		var resource_id = $(this).data('id');
		var $this = $(this);

		confirmBox(
			'Delete '+resource_title+'?', // title for confirm box
			'Are you sure you want to delete the variant '+resource_title+'? This action cannot be reversed.', // text for confirm box
			'Delete', // confirm button text
			{
			yes: deleteResource // confirm function
		},
		{
			id: resource_id,
			resource: resource,
			$this: $this,
			callback: function(deleted_variant) {
				console.log(deleted_variant);
				$('.wittyEDPanel[data-tier="4"]').blindRightOut(400, 'swing', function() {
					$(this).css({'height': 0, 'opacity': 0});
				});
				$('.wittyEDPanel[data-tier="3"]').css({'height': 'auto', 'opacity': 1}).blindLeftIn(400);
				$('#save_resource').show();
				$('.single_variant_submit').hide();

				$('#variant_id_'+deleted_variant.id).remove();
				$('.variant').removeClass('before_variant_open');

				flashMessage('Your variant has been deleted.');
				refreshIframe();
			}
		});
	});

	$('#resource-section').on('click', '.check-for-unsaved', function(e) {
		e.stopImmediatePropagation();
		var $this = $(this);
		if (isUnsaved()) {
		  confirmBox(
		  	'You have unsaved changes on this page', // Title of confirm Box
		  	'If you leave this page, all unsaved changes will be lost. Are you sure you want to leave this page?', // Text of confirm Box
		  	'Leave Page', // Confirm Button Text
		  	{
		  	yes: function() { // function for confirm button
		  		shiftPannelsRight($this);
		  	}
		  },
		  {}, // function parameters; unneeded here
		  {
		  	text: "Save & Leave", // extra button text
		  	function: function() {
		  		$(this).addClass('is-loading');
		  		$('#save_resource').click();
		  	}
		  });
		} else {
			shiftPannelsRight($this);
		}
	});

	$('#resource-section').on('click', '.check-for-variant-unsaved', function(e) {
		e.stopImmediatePropagation();
		var $this = $(this);
		if (isVariantUnsaved()) {
		  confirmBox(
		  	'You have unsaved changes on this page', // Title of confirm Box
		  	'If you leave this page, all unsaved changes will be lost. Are you sure you want to leave this page?', // Text of confirm Box
		  	'Leave Page', 
		  	{ // Confirm Button Text
			  	yes: function() { // function for confirm button
			  		shiftPannelsRight($this);
			  	}
			  },
			  {}, // function parameters; unneeded here
		  	{
		  		text: "Save & Leave", // extra button text
		  		function: function() { // extra button function
		  			$(this).addClass('is-loading');

						$('form.ajax [name]:not(.variant_input)').prop('disabled', true);
						var data = $('form.ajax').serialize();
						$('form.ajax [name]:not(.variant_input)').prop('disabled', false);

						var data_with_id = "product_id=" + $('[name="id"]').val() + '&' + data;

						// submit form with AJAX
				    $.ajax({
				      type: "POST",
				      url: '/variant-update', //sumbits it to the given url of the form
				      data: data_with_id,
				      dataType: "JSON" // you want a difference between normal and ajax-calls, and json is standard
				    }).success(function(variant) {
				      console.log(variant);
				      $('.single_variant_submit').removeClass('is-loading');
				      $('form.ajax [name]:not(.variant_input)').prop('disabled', false);
				      previousVariantState = data;

				    	if (variant.error_message) {
						    $('#confirmBoxOverlay').remove();
				    		flashMessage(variant.error_message, 'error');
				    	}	else {
					      flashMessage('Variant has been updated successfully.');
					      refreshIframe();
					      $('[data-object*="'+variant.id+'"]').data('object', variant);
					      $('#variants_'+variant.id+'_option1').val(variant.option1);
					      $('#variants_'+variant.id+'_option2').val(variant.option2);
					      $('#variants_'+variant.id+'_option3').val(variant.option3);
					      $('#variants_'+variant.id+'_inventory_quantity').val(variant.inventory_quantity);
					      $('#variants_'+variant.id+'_compare_at_price').val(variant.compare_at_price);
					      $('#variants_'+variant.id+'_price').val(variant.price);
					      $('#variants_'+variant.id+'_sku').val(variant.sku);

					      if ($('.variant_input[name^="variants[new]"]').length > 0) {
									refreshVariantPanel();
					      }
					    }

					    $('#confirmBoxOverlay').remove();
					    shiftPannelsRight($this);
				      // time to provide feedback 
				    }).error(function(e) {
				    	console.log(e);
					    $('#confirmBoxOverlay').remove();
				    	flashMessage('Variant failed to update successfully.', 'error');
				    	$('form.ajax [name]:not(.variant_input)').prop('disabled', false);
				    });
		  		}
		  	}
	  	);
		} else {
			shiftPannelsRight($this);
		}
	});

	window.onbeforeunload = function () {
		if (isUnsaved()) {
		  if (!confirm("Changes you made may not be saved.")) {
		  	return false;
		  }
		}
	};

	$('#syncStore').click(function() {
		$(this).addClass('is-loading');

		$.ajax({
			type: 'GET',
			url: '/sync-store',
			dataType: 'json'
		}).success(function(return_message) {
			$('#syncStore').removeClass('is-loading');

			flashMessage('Store had been synced.')
		}).error(basicError);
	});

	$('.accordion-trigger').click(function() {
		var group = $(this).data('group');
		var accordion = $(this).data('accordion');
		console.log(group, accordion);

		$('.accordion-target[data-group="' + group + '"]').slideUp();

		if (!$(this).hasClass('active')) {
			$('.accordion-target[data-group="' + group + '"][data-accordion="' + accordion + '"]').slideDown();
			$('.accordion-trigger[data-group="' + group + '"]').removeClass('active');
			$(this).addClass('active');
		} else {
			$('.accordion-trigger[data-group="' + group + '"]').removeClass('active');
		}
	});
}

$(document).on('turbolinks:load', ready);





















