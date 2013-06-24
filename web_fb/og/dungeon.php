<?php
require_once('../appconf.php');

$map_id = isset($_GET['id']) ? $_GET['id'] : '0';
$map_name = "Unknown Dungeon";

$con = mysql_connect($mysql_host, $mysql_user, $mysql_password);
if ($con)
{
	mysql_select_db($mysql_database, $con);
	$sqlResult = mysql_query("SELECT name FROM maps WHERE map_id = {$map_id}", $con);
	if ($sqlResult && mysql_num_rows($sqlResult) > 0)
	{
		$map_object = mysql_fetch_object($sqlResult);
		$map_name = $map_object->name;
	}
	mysql_close($con);
}

?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">

<head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# dungeonsofsuerhop: http://ogp.me/ns/fb/dungeonsofsuerhop#">
<title><?php echo $map_name; ?></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta property="fb:app_id" content="253062221374776" /> 
<meta property="og:type"   content="dungeonsofsuerhop:dungeon" /> 
<meta property="og:url"    content="<?php echo $canvas_page . "og/dungeon.php?id=" . $map_id ; ?>" /> 
<meta property="og:title"  content="<?php echo $map_name; ?>" /> 
<meta property="og:image"  content="http://www.inutilis.de/games/dungeons/og/dungeon.png" /> 
</head>

<body>
<script language="javascript" type="text/javascript">
window.top.location.replace("<?php echo $canvas_page . '?map_id=' . $map_id; ?>");
</script>
</body>

</html>