<?php
require_once('Answer.php');
require_once('serverconf.php');

$type = $_POST["type"];

$answerObject = new Answer;

// CONNECT

$con = mysql_connect($mysql_host, $mysql_user, $mysql_password);
if (!$con)
{
	$answerObject->error = mysql_error();
}
else
{
	mysql_select_db($mysql_database, $con);
	
	
	// COMMANDS
	
	$query = NULL;
	if ($type == "map")
	{
		$mapId = $_POST["map_id"];
		$query = "SELECT map_id, user_id, name, published, data, messages FROM maps WHERE map_id = {$mapId}";
	}
	elseif ($type == "user_map_infos")
	{
		$userIds = $_POST["user_ids"];
		$onlyPublished = $_POST["only_published"];
		$query = "SELECT map_id, user_id, name, unlock_level, num_played, num_successes, time, published, creation_date, num_likes, global FROM maps WHERE user_id IN ({$userIds})";
		if ($onlyPublished == "true")
		{
			$query = $query . " AND published = TRUE";
		}
	}
	elseif ($type == "fb_users")
	{
		$fbUserIds = $_POST["fb_user_ids"];
		$query = "SELECT fb_user_id, user_id FROM fb_users WHERE fb_user_id IN ({$fbUserIds})";
	}
	elseif ($type == "map_info")
	{
		$mapId = $_POST["map_id"];
		$query = "SELECT map_id, user_id, name, unlock_level, num_played, num_successes, time, published, creation_date, num_likes, global FROM maps WHERE map_id = {$mapId}";
	}
	elseif ($type == "top_map_infos")
	{
		$query = "SELECT t.map_id, m.user_id, m.name, m.unlock_level, m.num_played, m.num_successes, m.time, m.published, m.creation_date, m.num_likes, m.global FROM top_maps t INNER JOIN maps m USING (map_id)";
	}
	elseif ($type == "savegame")
	{
		$userId = $_POST["user_id"];
		$query = "SELECT map_id, mc_column, mc_row, health, num_coins, num_keys, armor, shield, weapon, time, score, data_diff FROM savegames WHERE user_id = {$userId}";
	}
	elseif ($type == "user_info")
	{
		$userId = $_POST["user_id"];
		$query = "SELECT num_played, num_successes, time, total_score, last_info FROM users WHERE user_id = {$userId}";
	}
	elseif ($type == "map_status")
	{
		$userId = $_POST["user_id"];
		$query = "SELECT map_id, status, score FROM map_status WHERE user_id = {$userId}";
	}
	
	// QUERY AND RESULT
	if ($query != NULL)
	{
		$sqlResult = mysql_query($query, $con);
		$resultArray = array();
		
		while ($row = mysql_fetch_row($sqlResult))
		{
			$resultArray[] = $row;
		}
		
		$answerObject->isOk = TRUE;
		$answerObject->result = $resultArray;
	}
	else
	{
		$answerObject->error = "Unknown request type";
	}
}
echo json_encode($answerObject);

mysql_close($con);
?>