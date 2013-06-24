<?php
require_once('serverconf.php');

$type = $_GET["type"];
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">
<html>
<head>
	<title>Dungeons of Suerhop Admin</title>
</head>

<body>

<?php
$result_message = NULL;

// CONNECT

$con = mysql_connect($mysql_host, $mysql_user, $mysql_password);
if (!$con)
{
	$result_message = mysql_error();
}
else
{
	mysql_select_db($mysql_database, $con);
	
	
	// COMMANDS
	
	$sqlResult = NULL;
	if ($type == "like")
	{
		$userId = $_GET["user_id"];
		$mapId = $_GET["map_id"];
		$sqlResult = mysql_query("INSERT INTO likes (user_id, map_id, count) VALUES ({$userId}, {$mapId}, 1) ON DUPLICATE KEY UPDATE count = count + 1", $con);
		if ($sqlResult && mysql_affected_rows() == 1)
		{
			// new like
			mysql_query("UPDATE maps SET num_likes = num_likes + 1 WHERE map_id = {$mapId}", $con);
		}
	}
	elseif ($type == "refresh_total_scores")
	{
		$sqlResult = mysql_query("SELECT user_id FROM users", $con);
		$resultArray = array();
		while ($row = mysql_fetch_row($sqlResult))
		{
			$resultArray[] = $row;
		}
		
		foreach ($resultArray as $row)
		{
			$userId = $row[0];
			$sqlResult = mysql_query("UPDATE users SET total_score = (SELECT SUM(score) FROM map_status WHERE user_id = {$userId} AND map_id IN (SELECT map_id FROM top_maps)) WHERE user_id = {$userId};", $con);
		}
	}
	
	// RESULT
	if ($sqlResult == NULL)
	{
		$result_message = "Unknown send type";
	}
	else if ($sqlResult)
	{
		$result_message = "Success";
	}
	else
	{
		$result_message = "Invalid query: " . mysql_error();
	}
}

echo $result_message;

mysql_close($con);
?>

</body>
</html>