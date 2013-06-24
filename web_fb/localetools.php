<?php
require_once('appconf.php');

function getGameLocale($fbLocale, $fbUserId)
{
	global $mysql_host, $mysql_user, $mysql_password, $mysql_database;
	
	$gameLocale = $fbLocale;
	
	$con = mysql_connect($mysql_host, $mysql_user, $mysql_password);
	if ($con)
	{
		mysql_select_db($mysql_database, $con);
		$sqlResult = mysql_query("SELECT locale FROM fb_users WHERE fb_user_id = {$fbUserId}", $con);
		if (mysql_num_rows($sqlResult) > 0)
		{
			$row = mysql_fetch_row($sqlResult);
			if (isset($row[0]))
			{
				$gameLocale = $row[0];
			}
		}
		mysql_close($con);
	}
	
	return $gameLocale;
}

function saveGameLocale($fbUserId, $gameLocale)
{
	global $mysql_host, $mysql_user, $mysql_password, $mysql_database;

	$con = mysql_connect($mysql_host, $mysql_user, $mysql_password);
	if ($con)
	{
		mysql_select_db($mysql_database, $con);
		
		$sqlResult = mysql_query("UPDATE fb_users SET locale = '{$gameLocale}' WHERE fb_user_id = {$fbUserId}", $con);
		
		mysql_close($con);
	}
}

?>