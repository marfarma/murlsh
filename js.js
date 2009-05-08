function format_li(d, prev) {
  var li = $('<li />').append($('<a />').attr('href', d['url']).append(
    d['title']));

  var same_as_last = prev &&
    prev['email'] && prev['name'] && d['email'] && d['name'] &&
    d['email'] == prev['email'] && d['name'] == prev['name'];

  if (!same_as_last) {
    if (d['name']) {
      li.prepend($('<div />').addClass('name').append(d['name']));
    }

    if (d['email']) {
      li.prepend($('<div />').addClass('icon').append(
        $('<img />').attr({
          src :  'http://www.gravatar.com/avatar/' + d['email'] + '?s=32',
          title : d['name'],
          alt : d['name'],
          width : 32,
          height : 32
	  })));
    }
  }

  return li;
}

function add_extra() {
  var flickr_match;
  var mp3_match;
  var vimeo_match;
  var youtube_match;
  $('a').map(function() {
    var this_a = $(this);
    if (youtube_match = /http:\/\/(?:(?:www|uk)\.)?youtube\.com\/watch\?v=(.+?)(?:&|$)/.exec(
      $(this).attr('href'))) {
	$(this).prepend($('<img />').addClass('thumb').attr('src',
        'http://img.youtube.com/vi/' + youtube_match[1] + '/1.jpg'));
    } else if (flickr_match = /http:\/\/(?:www\.)?flickr\.com\/photos\/[^\/]+?\/([0-9]+)/.exec(
      $(this).attr('href'))) {
        function flickr_thumb_insert(d) {
          this_a.prepend($('<img />').addClass('thumb').attr({
            alt : d.photo.title._content,
            src : 'http://farm' + d.photo.farm + '.static.flickr.com/' +
              d.photo.server + '/' + d.photo.id + '_' + d.photo.secret +
              '_t.jpg',
            title : d.photo.title._content
          }));
        }
	$.getJSON('http://api.flickr.com/services/rest/?api_key=d04e574aaf11bf2e1c03cba4ee7e5725&method=flickr.photos.getinfo&format=json&photo_id=' +
          flickr_match[1] + '&jsoncallback=?', flickr_thumb_insert);
    } else if (vimeo_match = /^http:\/\/(?:www\.)?vimeo\.com\/([0-9]+)$/.exec(
      $(this).attr('href'))) {
      function vimeo_thumb_insert(d) {
	this_a.prepend($('<img />').addClass('thumb').attr({
          alt : d[0].title,
          src : d[0].thumbnail_medium,
          title : d[0].title
        }));
      }
      $.getJSON('http://vimeo.com/api/clip/' + vimeo_match[1] +
        '.json?callback=?', vimeo_thumb_insert);
    } else if (mp3_match = /.*\.mp3$/.exec($(this).attr('href'))) {
      $(this).before($(
        '<object data="player_mp3_mini.swf" height="20" type="application/x-shockwave-flash" width="200">' +
        '<param name="bgcolor" value="#000000" />' +
        '<param name="FlashVars" value="mp3=' + mp3_match[0] + '" />' +
        '<param name="movie" value="player_mp3_mini.swf" />' +
        '</object>'));
    }
  });
}

$(document).ready(function() {
  $('#urls li:first').html('loading');
  $.get('ajax.cgi', {}, function(d) {
    $('#urls').empty();
    $.each(d, function(i, v) {
      var prev = i > 0 ? d[i - 1] : null;
      $('#urls').append(format_li(v, prev));
    });
    $('#urls li:even').addClass('even');
    add_extra();
  }, 'json');

  $('#submit').click(function() {
    $.post('ajax.cgi', {
      url : $('#url').val(),
      name : $('#name').val(),
      email : $('#email').val()
      }, function(d) {
        $.each(d, function(i, v) {
          $('#urls').prepend(format_li(v, null));
        });
	$('#url').val('');
      }, 'json');
  });

  if ($.cookie('name')) {
    $('#name').val($.cookie('name'));
  }
  if ($.cookie('email')) {
    $('#email').val($.cookie('email'));
  }
});
