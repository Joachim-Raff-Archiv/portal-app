var vrvToolkit = new verovio.toolkit();
<!-- Load the file using HTTP GET -->
$.get( ".", function( data ) {
var svg = vrvToolkit.renderData(data, {});
$("#output").html(svg);
}, 'text');