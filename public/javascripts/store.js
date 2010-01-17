function correctPNG() // correctly handle PNG transparency in Win IE 5.5 & 6.
{
   var arVersion = navigator.appVersion.split("MSIE")
   var version = parseFloat(arVersion[1])
   if ((version >= 5.5) && (document.body.filters)) 
   {
      for(var i=0; i<document.images.length; i++)
      {
         var img = document.images[i]
         var imgName = img.src.toUpperCase()
         if (imgName.substring(imgName.length-3, imgName.length) == "PNG")
         {
            var imgID = (img.id) ? "id='" + img.id + "' " : ""
            var imgClass = (img.className) ? "class='" + img.className + "' " : ""
            var imgTitle = (img.title) ? "title='" + img.title + "' " : "title='" + img.alt + "' "
            var imgStyle = "display:inline-block;" + img.style.cssText 
            if (img.align == "left") imgStyle = "float:left;" + imgStyle
            if (img.align == "right") imgStyle = "float:right;" + imgStyle
            if (img.parentElement.href) imgStyle = "cursor:hand;" + imgStyle
            var strNewHTML = "<span " + imgID + imgClass + imgTitle
            + " style=\"" + "width:" + img.width + "px; height:" + img.height + "px;" + imgStyle + ";"
            + "filter:progid:DXImageTransform.Microsoft.AlphaImageLoader"
            + "(src=\'" + img.src + "\', sizingMethod='scale');\"></span>" 
            img.outerHTML = strNewHTML
            i = i-1
         }
      }
   }    
}


var STATE_UNFOCUSED = 0;
var STATE_FOCUSED = 1;

function setup_help_value(element_id, state) {
	var element = $(element_id).get(0);
	var help_text = HELP_VALUES[element_id];
	element.style.color = (state == STATE_FOCUSED ? '#000' : '#aaa');

	if ( state == STATE_FOCUSED && element.value == help_text) {
		element.value = '';
	} else if ( state == STATE_UNFOCUSED && element.value == '') {
		element.value = help_text;
	}
}

function setup_help_values() {
	for (element_id in HELP_VALUES) {
		setup_help_value(element_id, STATE_UNFOCUSED);
	}
}

function clear_help_values() {
	for (element_id in HELP_VALUES) {
	   var element = $(element_id).get(0);
		if ( element.value == HELP_VALUES[element_id] ) {
		   element.value = '';
		}
	}
}



$(document).ready(function(){
   if ( typeof(window['HELP_VALUES']) != 'undefined' ) {
      $(document).unload = clear_help_values;
      setup_help_values();
      for (element_id in HELP_VALUES) {
         var element = $(element_id);
         element.focus(function() { setup_help_value(element_id, STATE_FOCUSED); });
         element.blur(function() { setup_help_value(element_id, STATE_UNFOCUSED); });
      }
   }
});