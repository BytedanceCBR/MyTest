<?php
$filename = $argv[1];
if(is_null($filename))
{
	echo "format.php [filename]";
	exit;
}

$content = file_get_contents($filename);
$content = str_replace("\\n", "\n", $content);
$new_filename = "f_".$filename;
file_put_contents($new_filename, $content);

?>