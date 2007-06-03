<?
/* $Id$ */
// +--------------------------------------------------------------------------+
// | i18n_form.php                                                            |
// +--------------------------------------------------------------------------+
// | Copyright (c)                                                            |
// +--------------------------------------------------------------------------+
// | License:  GNU/GPL - http://www.gnu.org/copyleft/gpl.html                 |
// +--------------------------------------------------------------------------+
// | Used by all the PHP files at http://www.finkproject.org                  |
// |    to produce the headers (incl HTML headers and top parts)              |
// |                                                                          |
// | usage:    1. read the comments                                           |
// |           2. include this file before outputting anything                |
// +--------------------------------------------------------------------------+
// | issues:                                                                  |
// |                                                                          |
// |                                                                          |
// +--------------------------------------------------------------------------+

function WriteLog($translated){
	// Save log in the server
	$File = "/private/var/tmp/translation_$document_$chapter_$section.$lang.$id.txt"; 
	$Handle = fopen($File, 'w');
	
	fwrite($Handle, "$translated\n");
	fclose($Handle);
}

function SendEmail($translated){
// Email to fink-i18n
// Your email address
$toemail = "babayoshihiko@mac.com";
$subject = "[Translated] ($tr_lang)";
$message = $translated;

mail($toemail, $subject, $message, "From: fink-i18n@lists.sourceforge.net");
}


$document = $_POST["document"];
$chapter = $_POST["chapter"];
$section = $_POST["section"];
$tr_lang = $_POST["lang"];
$id = $_POST["id"];
$original = $_POST["original"];
$translated = $_POST["translated"];

?>

<html>
<head>
<meta http-equiv="refresh" content="5;url=<? echo $_SERVER["HTTP_REFERER"];?>">
</head><body>

<p>
Thank you for your effort! We will check and update as soon as possible. (Fink Translation Team)
</p>

</body></html>
