$(function() {

	$( "li.busca a" ).click(function(e){
		e.preventDefault();
		$(this).parent().submit();
	});
	var cache = {};
	$( "#busca" ).autocomplete({
		minLength: 2,
		source: function( request, response ) {
			var term = request.term;
			if ( term in cache ) {
				response( cache[ term ] );
				return;
			}
	
			$.getJSON( "/credores/sugestao?q="+request.term, function( data, status, xhr ) {
				cache[ term ] = data.nomes;
				response( data.nomes );
			});
		}
	});
});