<?php
require_once('appconf.php');

$days = $_GET["days"];

$con = mysql_connect($mysql_host, $mysql_user, $mysql_password);
if ($con)
{
	mysql_select_db($mysql_database, $con);
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
	<head>
		<title>Dungeons of Suerhop Statistics</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	</head>

	<body>
	<h1>Statistics for the last <?php echo $days; ?> days</h1>
	<h2>Overview</h2>
	Active users: <?php echo getActiveUsers($con, $days); ?> (<?php echo getNewUsers($con, $days); ?> new)<br/>
	Updated dungeons: <?php echo getUpdatedMaps($con, $days); ?> (<?php echo getPublishedMaps($con, $days); ?> published)<br/>
	<h2>Users</h2>
	<?php showUsers($con, $days); ?>
	<h2>Dungeons</h2>
	<?php showMaps($con, $days); ?>
	</body>
</html>
<?php
	mysql_close($con);
}
else
{
	echo "Error connecting to server";
}

function getActiveUsers($connection, $numDays)
{
	$sqlResult = mysql_query("SELECT COUNT(*) FROM users WHERE login_date >= DATE_SUB(CURDATE(),INTERVAL {$numDays} DAY)", $connection);
	$row = mysql_fetch_array($sqlResult);
	return $row[0];
}

function getNewUsers($connection, $numDays)
{
	$sqlResult = mysql_query("SELECT COUNT(*) FROM users WHERE register_date >= DATE_SUB(CURDATE(),INTERVAL {$numDays} DAY)", $connection);
	$row = mysql_fetch_array($sqlResult);
	return $row[0];
}

function getUpdatedMaps($connection, $numDays)
{
	$sqlResult = mysql_query("SELECT COUNT(*) FROM maps WHERE creation_date >= DATE_SUB(CURDATE(),INTERVAL {$numDays} DAY)", $connection);
	$row = mysql_fetch_array($sqlResult);
	return $row[0];
}

function getPublishedMaps($connection, $numDays)
{
	$sqlResult = mysql_query("SELECT COUNT(*) FROM maps WHERE creation_date >= DATE_SUB(CURDATE(),INTERVAL {$numDays} DAY) AND published = TRUE", $connection);
	$row = mysql_fetch_array($sqlResult);
	return $row[0];
}

function showUsers($connection, $numDays)
{
	$sqlResult = mysql_query("SELECT user_id, num_played, num_successes, time, total_score, last_info, register_date, login_date, source FROM users WHERE login_date >= DATE_SUB(CURDATE(),INTERVAL {$numDays} DAY) ORDER BY register_date", $connection);
	showTable($sqlResult, array("user_id", "num_played", "num_successes", "time", "total_score", "last_info", "register_date", "login_date", "source"));
}

function showMaps($connection, $numDays)
{
	$sqlResult = mysql_query("SELECT map_id, user_id, name, unlock_level, num_played, num_successes, time, published, creation_date, num_likes, global FROM maps WHERE creation_date >= DATE_SUB(CURDATE(),INTERVAL {$numDays} DAY) ORDER BY published, creation_date", $connection);
	showTable($sqlResult, array("map_id", "user_id", "name", "unlock_level", "num_played", "num_successes", "time", "published", "creation_date", "num_likes", "global"));
}

function showTable($sqlResult, $titles)
{
	echo '<table border="1" width="100%"><tr>';
	foreach ($titles as $title)
	{
		echo "<th>{$title}</th>";
	}
	echo "</tr>";
	
	while ($row = mysql_fetch_array($sqlResult))
	{
		echo "<tr>";
		foreach ($titles as $title)
		{
			echo "<td>";
			echo $row[$title];
			echo "</td>";
		}
		echo "</tr>";
	}
	echo "</table>";
} 

?>