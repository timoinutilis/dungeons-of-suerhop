<?php
require_once('../dungeons/appconf.php');

$game_locale = "en_US";
if (isset($_GET["locale"])) {
	$game_locale = $_GET["locale"];
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
	<head>
		<title>Dungeons of Suerhop</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<style>
		body {
			margin:0px;
			padding:0px;
			background-color: #ffffff;
			font-family: "Helvetica Neue", Arial, Helvetica, "Nimbus Sans L", sans-serif;
		}
		object {
			outline: none;
			overflow: hidden;
		}
		a:link, a:visited {
			color: #3b5998;
			text-decoration: none;
		}
		a:active, a:hover {
			color: #3b5998;
			text-decoration: underline;
		}
		div.infobox {
			margin: 0px 0px 10px 0px;
			padding: 0.5em;
			border: solid;
			border-width: thin;
			background: #fff9d7;
			border-color: #e2c822;
			color: #333333;
			font-size: 80%;
		}
		</style>

<?php
	if (!$maintenance) {
		if (isset($_GET['game_version'])) {
			$game_version = $_GET['game_version'];
		}
?>
		<script type="text/javascript" src="swfobject.js"></script>
		<script type="text/javascript">
					
			var flashVars = {
				localeChain: "<?php echo $game_locale; ?>",
				configUrl: "http://inutilis.de/games/dungeonsweb/config.xml",
				mapId: "<?php echo $_GET['map_id']; ?>",
			};

			var parObj = {
			};

			var attributes = {
				name: "myContent",
				wmode: "opaque",
				allowscriptaccess: "always"
			};		

			swfobject.embedSWF(<?php echo "\"http://inutilis.de/games/dungeons/bin/MagicStone_v{$game_version}.swf\""; ?>, "myContent", "760", "570", "10.0.0", "expressInstall.swf", flashVars, parObj, attributes);
		
		</script>
<?php
	}
?>
	</head>
	<body>
		<div style="width: 760px; margin:0px auto;">

		<div style="height: 10px;"></div>
		
		<!-- maudau code begin -->
		<iframe id="maudauIframe" scrolling="no" height="72" frameborder="0" width="758" marginheight="0" marginwidth="0" src="http://www.maudau.com/AdsBar/?appid=1154"></iframe>
		<!-- maudau code end -->

		<div style="height: 10px;"></div>
		
		<div style="background-image:url('top_bar.png'); width: 760px; height: 80px;">
			<div style="position: relative; left: +132px; top: +51px; font-size: 14px; color: #271a0f">
				<?php echo $topbar_text; ?>
			</div>
		</div>

		<div style="height: 10px;"></div>
		
<?php
	if ($maintenance) {
		echo "<div class=\"infobox\">The game is currently in <b>maintenance</b>. Please try again in some minutes!</div>";
	} else {
		if (isset($infobox)) {
			echo "<div class=\"infobox\">" . $infobox . "</div>";
		}
?>
		<div id="myContent">
			<h1>You need Flash player for this game.</h1>
			<p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" /></a></p>
		</div>
		
		<div style="margin:10px 0px 0px 0px; text-align: center;">
			<a href="<?php echo $canvas_page . "?source=web"; ?>">Play on Facebook</a> <span>|</span>
			<a href="http://www.inutilis.de" target="_blank">Inutilis Website</a> <span>|</span>
			<a href="http://www.inutilis.de/games/dungeons/Privacy_Policy_DoS.pdf" target="_blank">Privacy</a>
		</div>
		
		<div style="margin:10px 0px 0px 0px; text-align: center;">
			<form method="get" action="index.php" target="_top">
				<select name="locale">
					<option value="en_US" <?php if ($game_locale == "en_US") echo "selected"; ?> >English</option>
					<option value="es_ES" <?php if ($game_locale == "es_ES") echo "selected"; ?> >Español</option>
					<option value="de_DE" <?php if ($game_locale == "de_DE") echo "selected"; ?> >Deutsch</option>
					<option value="fr_FR" <?php if ($game_locale == "fr_FR") echo "selected"; ?> >Français</option>
				</select>
				<input class="inputbutton" type="submit" value="Go">
			</form>
		</div>
<?php
	}
?>
		
		<div style="height: 25px;"></div>
		
		</div>
		
	</body>
</html>