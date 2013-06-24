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
	
	$sqlResult = NULL;
	if ($type == "map")
	{
		$mapId = $_POST["map_id"];
		$userId = $_POST["user_id"];
		$mapName = $_POST["map_name"];
		$unlockLevel = $_POST["unlock_level"];
		$data = $_POST["data"];
		$messages = mysql_escape_string($_POST["messages"]);
		if ($mapId == 0)
		{
			$query = "INSERT INTO maps (user_id, name, unlock_level, num_played, num_successes, time, published, data, messages, creation_date, num_likes, global) VALUES ({$userId}, '{$mapName}', {$unlockLevel}, 0, 0, 0, FALSE, '{$data}', '{$messages}', CURRENT_TIMESTAMP(), 0, FALSE)";
		}
		else
		{
			$query = "UPDATE maps SET name = '{$mapName}', unlock_level = {$unlockLevel}, data = '{$data}', messages = '{$messages}', creation_date = CURRENT_TIMESTAMP() WHERE map_id = {$mapId}";
		}
		$sqlResult = mysql_query($query, $con);
	}
	elseif ($type == "publish_map")
	{
		$mapId = $_POST["map_id"];
		$mapName = $_POST["map_name"];
		$sqlResult = mysql_query("UPDATE maps SET published = TRUE, name = '{$mapName}', creation_date = CURRENT_TIMESTAMP() WHERE map_id = {$mapId}", $con);
	}
	elseif ($type == "delete_map")
	{
		$mapId = $_POST["map_id"];
		$sqlResult = mysql_query("DELETE FROM maps WHERE map_id = {$mapId}", $con);
	}
	else if ($type == "map_started")
	{
		$userId = $_POST["user_id"];
		$mapId = $_POST["map_id"];
		$sqlResult = mysql_query("INSERT INTO map_status (user_id, map_id, status, score) VALUES ({$userId}, {$mapId}, 1, 0) ON DUPLICATE KEY UPDATE status = status", $con);
	}
	elseif ($type == "map_statistics")
	{
		$userId = $_POST["user_id"];
		$mapId = $_POST["map_id"];
		$seconds = $_POST["seconds"];
		$completed = $_POST["completed"];
		$score = $_POST["score"];
		$completedSeconds = 0;
		if (intval($completed) == 1)
		{
			$completedSeconds = $seconds;
			mysql_query("INSERT INTO map_status (user_id, map_id, status, score) VALUES ({$userId}, {$mapId}, 2, {$score}) ON DUPLICATE KEY UPDATE status = 2, score = GREATEST({$score}, score)", $con);
		}
		mysql_query("UPDATE users SET num_played = num_played + 1, time = time + {$seconds}, num_successes = num_successes + {$completed} WHERE user_id = {$userId}", $con);
		$sqlResult = mysql_query("UPDATE maps SET num_played = num_played + 1, time = time + {$completedSeconds}, num_successes = num_successes + {$completed} WHERE map_id = {$mapId}", $con);
	}
	elseif ($type == "total_score")
	{
		$userId = $_POST["user_id"];
		$totalScore = $_POST["total_score"];
		$sqlResult = mysql_query("UPDATE users SET total_score = {$totalScore} WHERE user_id = {$userId}", $con);
	}
	elseif ($type == "like")
	{
		$userId = $_POST["user_id"];
		$mapId = $_POST["map_id"];
		$sqlResult = mysql_query("INSERT INTO likes (user_id, map_id, count) VALUES ({$userId}, {$mapId}, 1) ON DUPLICATE KEY UPDATE count = count + 1", $con);
		if ($sqlResult && mysql_affected_rows() == 1)
		{
			// new like
			mysql_query("UPDATE maps SET num_likes = num_likes + 1 WHERE map_id = {$mapId}", $con);
		}
	}
	elseif ($type == "savegame")
	{
		$userId = $_POST["user_id"];
		$mapId = $_POST["map_id"];
		$mcColumn = $_POST["mc_column"];
		$mcRow = $_POST["mc_row"];
		$health = $_POST["health"];
		$numCoins = $_POST["num_coins"];
		$numKeys = $_POST["num_keys"];
		$armor = $_POST["armor"];
		$shield = $_POST["shield"];
		$weapon = $_POST["weapon"];
		$position = $_POST["position"];
		$time = $_POST["time"];
		$score = $_POST["score"];
		$dataDiff = $_POST["data_diff"];
		$query = "INSERT INTO savegames (user_id, map_id, mc_column, mc_row, health, num_coins, num_keys, armor, shield, weapon, time, score, data_diff)
			VALUES ({$userId}, {$mapId}, {$mcColumn}, {$mcRow}, {$health}, {$numCoins}, {$numKeys}, {$armor}, {$shield}, {$weapon}, {$time}, {$score}, '{$dataDiff}')
			ON DUPLICATE KEY UPDATE map_id = {$mapId}, mc_column = {$mcColumn}, mc_row = {$mcRow}, health = {$health}, num_coins = {$numCoins}, num_keys = {$numKeys}, armor = {$armor}, shield = {$shield}, weapon = {$weapon}, time = {$time}, score = {$score}, data_diff = '{$dataDiff}'";
		$sqlResult = mysql_query($query, $con);
	}
	elseif ($type == "delete_savegame")
	{
		$userId = $_POST["user_id"];
		$sqlResult = mysql_query("DELETE FROM savegames WHERE user_id = {$userId}", $con);
	}
	elseif ($type == "last_info")
	{
		$userId = $_POST["user_id"];
		$lastInfo = $_POST["last_info"];
		$sqlResult = mysql_query("UPDATE users SET last_info = {$lastInfo} WHERE user_id = {$userId}", $con);
	}
	else
	{
		$answerObject->error = "Unknown send type";
	}
	
	// RESULT
	if ($sqlResult)
	{
		$answerObject->isOk = TRUE;
		$answerObject->result = mysql_insert_id();
	}
	else
	{
		$answerObject->error = "Invalid query: " . mysql_error();
	}
}
echo json_encode($answerObject);

mysql_close($con);
?>