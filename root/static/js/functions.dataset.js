
	var findInArray = function(obj,value){
		if (value == "") return true;
		var retorno = false;
		for (a = 0; a < obj.length; a++){
			if (obj[a] == value) retorno = true;
		}
		return retorno;
	}
	
	function convertRangeValue(oldMin,oldMax,newMin,newMax,value){
		var oldRange = (oldMax - oldMin);
		var newRange = (newMax - newMin);
		var newValue = (((value - oldMin) * newRange) / oldRange) + newMin;
		
		return newValue;
	}

	var default_colors = ["#c51d18","#002974","#56a468","#98da60","#54a4a1","#cb3072","#4266ba","#3b7d03","#ed733c","#ff6281","#ffe94d"];

	var dados;

	$('.carregando').show();
		$.getJSON("/datasets", function(data) {

		$('.carregando').hide();
		dados = data;
	
		dados.data.sort(function (a, b) {
			a = a.periodo,
			b = b.periodo;
		
			return a.localeCompare(b);
		});
		
		var arr = [];
		
		var periodos = [];
	
		var tipos = [];

		var oldMin = "";
		var oldMax = "";
		var newMin = 10;

		$.each(dados.data, function(index,item){
			var valor = parseInt(item.items_real);
			
			if (oldMin == "") oldMin = valor;
			if (oldMax == "") oldMax = valor;
			
			if (valor < oldMin) oldMin = valor;
			if (valor > oldMax) oldMax = valor;
		});
		
		var newMax = 100;

		$.each(dados.data, function(index,item){
			var valor = parseInt(item.items_real);
			arr.push([item.periodo + "-01-01 8:00AM", (parseFloat(item.valor)/1000000000), convertRangeValue(oldMin,oldMax,newMin,newMax,valor), item.titulo, item.total, item.items_real]);
			if (!findInArray(periodos,item.periodo)){
				periodos.push(item.periodo);
			}
			if (!findInArray(tipos,item.type)){
				tipos.push(item.type);
			}
		});
	
		periodos.unshift(parseInt(periodos[0]) - 1);
		periodos.push(parseInt(periodos[periodos.length-1]) + 1);
		
		$.each(periodos, function(index,item){
			periodos[index] = item + "-01-01 8:00AM";
		});
	
		var tipo_cores = [];
		$.each(tipos, function(index,item){
			tipo_cores[item] = default_colors[index];
		});
		
		var seriesColors = [];
		$.each(dados.data, function(index,item){
			seriesColors.push(tipo_cores[item.type]);
		});
		
		temp = {
			grid: {
				backgroundColor: "#ffffff",
				gridLineColor: '#f0f0f0',
				gridLineWidth: 1
			},
			title: {
				fontFamily: 'tahoma, arial',
				fontSize: '12pt',
				textColor: '#005caa'
			},
			axes: {
				xaxis: {
					label: {
						fontFamily: 'arial'
					}
				},
				yaxis: {
					label: {
						fontFamily: 'arial',
						fontSize: '9pt'
					}
				}
			}
		};
	
		var plotOptions = {
				grid: {
					drawBorder: false,
					shadow: false,
					background: 'white'
				},
				seriesDefaults:{
					renderer: $.jqplot.BubbleRenderer,
					rendererOptions: {
						bubbleAlpha: 0.6,
						highlightAlpha: 0.8,
						showLabels: false
					},
					shadow: true,
					shadowAlpha: 0.05
				},
				axes:{
						xaxis:{
								renderer:$.jqplot.DateAxisRenderer,
								tickOptions:{
												formatString:'%Y'
											},
								ticks: periodos
								},
						yaxis:{
								label: "em R$ bilhões",
								labelRenderer: $.jqplot.CanvasAxisLabelRenderer
						}
				},
				seriesColors: seriesColors
		  };
	
		var plot1 = $.jqplot('chart1',[arr], plotOptions);
		pofomd_style = plot1.themeEngine.copy('Default', 'pofomd', temp);
		plot1.activateTheme('pofomd');
	
	  // Now bind function to the highlight event to show the tooltip
	  // and highlight the row in the legend.
		$('#chart1').bind('jqplotDataHighlight',
			function (ev, seriesIndex, pointIndex, data, radius) {   
				var chart_left = $('#chart1').offset().left,
				chart_top = $('#chart1').offset().top,
				x = plot1.axes.xaxis.u2p(data[0]),  // convert x axis unita to pixels
				y = plot1.axes.yaxis.u2p(data[1]);  // convert y axis units to pixels
				var color = '#710000';
				$('#tooltip1').css({left:chart_left+x+radius+5, top:chart_top+y});
				$('#tooltip1').html('<span style="font-size:14px;font-weight:bold;color:' +	color + ';">' + data[3] + '</span><br />' + 'Total: R$' + data[4] + '<br />' + 'Número de Dados: ' + $().number_format(data[5],{numberOfDecimals:0}));
				$('#tooltip1').show();
			}
		);
		
	  // Bind a function to the unhighlight event to clean up after highlighting.
		$('#chart1').bind('jqplotDataUnhighlight',
			function (ev, seriesIndex, pointIndex, data) {
				$('#tooltip1').empty();
				$('#tooltip1').hide();
			}
		);
		
		
		var items = [];
	
		items.push('<table id="datalist" class="tablesorter" width="95%" align="center"><thead><tr><th>Dataset</th><th>Período</th><th>Total de gastos</th><th>Número de Dados</th></tr></thead><tbody>');

	
		dados.data.sort(function (a, b) {
			a = a.items_real,
			b = b.items_real;
		
			return b - a;
		});

		$.each(dados.data, function(key, val) {
			 items.push('<tr class="alt"><td width="320">' + '<a href="/dataset/' + val.uri  + '">' + val.titulo + '</a></td><td align="center">' + val.periodo + '</td><td align="right">R$ ' + val.total + '</td><td align="right">' + $().number_format(val.items_real,{numberOfDecimals:0}) + '</td></tr>');
		});
		items.push('</tbody></table>');
	
		$('.my-new-list').html(items.join(''));
		
		var myTextExtraction = function(node)  
		{  
			// extract data from markup and return it  
			var conteudo = node.innerHTML;
			if (conteudo.search("href") < 0){
				conteudo = conteudo.replace(" ","");
				conteudo = conteudo.replace("R$","");
				conteudo = conteudo.replace("%","");
				conteudo = conteudo.replace(/\./gi,"");
				conteudo = conteudo.replace(/\,/gi,".");
				conteudo = parseFloat(conteudo);
			}else{
				conteudo = node.childNodes[0].innerHTML;
			}
			return conteudo;
		} 	
		//$.tablesorter.defaults.sortList = [[1,1]]; 
		//$.tablesorter.defaults.textExtraction = myTextExtraction; 
		$("#datalist").tablesorter();
		
	});