/* $Id$ */


/*
 *
 *
 *
 *
 *
 *
 *
 */


function i18n_Init(){
	var e = document.getElementsByTagName('translate');
	for( var i = 0 ; i < e.length ; i++ ){
		str = e[i].innerHTML;
		e[i].innerHTML = "<a href=\"javascript:i18n_Translate_Init('','','','de'," + i + ")\" >Translate</a>";
	}
}

function i18n_Translate_Init(doc, chapter, section, lang, id){
	var e = document.getElementsByTagName('translate');
	e[id].parentNode.style.backgroundColor = "#eeffff";
	
	// guesses the window size for column width
	var colwidth = (document.width - 80) / 10;
	colwidth = (colwidth > 10 ? colwidth : 10);
	
	var str = '<form action="http://localhost/fink/i18n_form.php" method="post" name="form' + id + '">';
	str += '<textarea cols="' + colwidth + '" rows="10" accept-charset="UTF-8" name="translated"></textarea>';
	str += '<input type="hidden" name="doc" value="' + doc + '">';
	str += '<input type="hidden" name="chapter" value="' + chapter + '">';
	str += '<input type="hidden" name="section" value="' + section + '">';
	str += '<input type="hidden" name="lang" value="' + lang + '">';
	str += '<input type="hidden" name="id" value="' + id + '">';
	str += '<input type="hidden" name="original" value="' + e[id].parentNode.innerText + '">';
	str += '<br><a href="javascript:i18n_Previw(' + id + ')">Preview</a>';
	str += ' |  <a href="javascript:document.form' + id + '.submit();">Commit</a>';
	str += '</form>';
	
	e[id].innerHTML = str;
	
	// this.form.translated.focus();
}

function i18n_Previw(id){
	var e = document.getElementsByTagName('translate');
	e[id].parentNode.style.backgroundColor = "#ffffff";
	
	var str = e[id].getElementsByTagName('textarea')[0].value;
	
	e[id].parentNode.innerText = str;
}
