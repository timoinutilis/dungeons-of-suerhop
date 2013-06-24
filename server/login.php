<?php
require_once('Answer.php');
require_once('serverconf.php');

$fbUserId = $_POST["fb_user_id"];
$source = $_POST["source"];

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
	
	$sqlResult = mysql_query("SELECT user_id FROM fb_users WHERE fb_user_id = {$fbUserId}", $con);
	
	if (mysql_num_rows($sqlResult) > 0)
	{
		// existing user
		$row = mysql_fetch_row($sqlResult);
		$answerObject->isOk = TRUE;
		$userId = (int)$row[0];
		$answerObject->result = $userId;
		
		// update login date
		$sqlResult = mysql_query("UPDATE users SET login_date = CURRENT_TIMESTAMP() WHERE user_id = {$userId}", $con);
	}
	else
	{
		// create new user
		$sqlResult = mysql_query("INSERT INTO users (num_played, num_successes, time, total_score, last_info, login_date, register_date, source) VALUES (0, 0, 0, 0, 0, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), '{$source}')", $con);
		if ($sqlResult)
		{
			$userId = mysql_insert_id();
			$sqlResult = mysql_query("INSERT INTO fb_users (fb_user_id, user_id) VALUES ({$fbUserId}, {$userId})", $con);
			if ($sqlResult)
			{
				$answerObject->isOk = TRUE;
				$answerObject->result = $userId;
			}
			else
			{
				$answerObject->error = "Invalid query: " . mysql_error();
			}
		}
		else
		{
			$answerObject->error = "Invalid query: " . mysql_error();
		}
	}
}
echo json_encode($answerObject);

mysql_close($con);
?>