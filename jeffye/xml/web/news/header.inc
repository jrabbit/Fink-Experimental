<? include_once "../phpLang.inc.php";
    $lang_code = 'en'; 
    if ((phpLang_current)) $lang_code=phpLang_current; 
    if (is_readable ("header." . $lang_code . ".inc")) 
        include_once "header." . $lang_code . ".inc"; 
    else 
        include_once "header.en.inc"; 
?>
