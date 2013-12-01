<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
	<head>
		<title>Dungeons of Suerhop</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<style>
		body {
			margin: 0px;
			overflow: hidden;
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
		div.banner {
			margin: 0px 0px 10px 0px;
			padding: 0px 2px 2px 2px;
			border: solid;
			border-width: thin;
			border-color: #cccccc;
			color: #777777;
			font-size: 12px;
			height: 104px;
		}
		button.closebutton {
			width: 12px;
			height: 12px;
			border: 0px;
			background-color: #eeeeee;
			padding: 0px;
			margin: 0px;
			cursor: pointer;
		}
		button.closebutton:hover {
			background-color: #cccccc;
		}
		</style>

<?php
require_once('localetools.php');
require_once('appconf.php');

$next_redirect = $canvas_page . "?" . http_build_query($_GET);
$auth_url = "//www.facebook.com/dialog/oauth?client_id=" . $app_id . "&redirect_uri=" . urlencode($next_redirect);

$signed_request = $_REQUEST["signed_request"];
list($encoded_sig, $payload) = explode('.', $signed_request, 2);
$data = json_decode(base64_decode(strtr($payload, '-_', '+/')), true);

$user = $data["user"];

$game_locale = getGameLocale($user["locale"], $data['user_id']);

if (empty($data["user_id"])) {
?>
		<script> top.location.href="<?php echo $auth_url; ?>"</script>
	</head>
	<body>
	</body>
<?php
} else {
	if (isset($_GET['game_version'])) {
		$game_version = $_GET['game_version'];
		$maintenance = FALSE;
	}
	if (!$maintenance) {
		$game_source = $_GET['source'];
		if (empty($game_source)) {
			if (!empty($_GET['fb_source'])) {
				$game_source = $_GET['fb_source'];
			}
		}
?>
		<script type="text/javascript" src="//connect.facebook.net/en_US/all.js"></script>
		<script type="text/javascript" src="swfobject.js"></script>
		<script type="text/javascript">
			
			var flashVars = {
				localeChain: "<?php echo $game_locale; ?>",
				fbUserId: "<?php echo $data['user_id']; ?>",
				configUrl: "http://apps.timokloss.com/dungeons/config.xml",
				mapId: "<?php echo $_GET['map_id']; ?>",
				requestIds: "<?php echo $_GET['request_ids']; ?>",
				source: "<?php echo $game_source; ?>"
			};

			var parObj = {
			};

			var attributes = {
				name: "myContent",
				wmode: "opaque",
				allowscriptaccess: "always"
			};		

			swfobject.embedSWF(<?php echo "\"//apps.timokloss.com/dungeons/bin/MagicStone_v{$game_version}.swf\""; ?>, "myContent", "760", "570", "10.0.0", "expressInstall.swf", flashVars, parObj, attributes);
			
		</script>
<?php
	}
?>
		<script type="text/javascript">
		
			function removeAdvert() {
				var advertBox = document.getElementById('advert');
				advertBox.parentNode.removeChild(advertBox);
			}
		
		</script>
	</head>
	<body>
		<div id="fb-root"></div>

		<div style="height: 10px;">
		</div>

		<div style="background-image:url('top_bar.png'); width: 760px; height: 80px;">
			<div style="position: relative; left: +132px; top: +51px; font-size: 14px; color: #271a0f">
				<?php echo $topbar_text; ?>
			</div>
		</div>

		<div style="height: 10px;">
		</div>
		
<?php
	if ($maintenance) {
		echo "<div class=\"infobox\">The game is currently in <b>maintenance</b>. Please try again in some minutes!</div>";
	} else {
		if (isset($infobox)) {
			echo "<div class=\"infobox\">" . $infobox . "</div>";
		}
?>
		<iframe src="//www.facebook.com/plugins/like.php?href=http%3A%2F%2Fwww.facebook.com%2Fpages%2FDungeons-of-Suerhop%2F411676995534269&amp;send=false&amp;layout=standard&amp;width=760&amp;show_faces=false&amp;action=like&amp;colorscheme=light&amp;font&amp;height=35&amp;appId=253062221374776" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:760px; height:35px;" allowTransparency="true"></iframe>

		<div id="myContent">
			<h1>You need Flash player for this game.</h1>
			<p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" /></a></p>
		</div>
		
		<div style="margin:10px 0px 0px 0px; text-align: center;">
			<a href="//www.facebook.com/pages/Dungeons-of-Suerhop/411676995534269" target="_top">Community</a> <span>|</span>
			<a href="http://www.inutilis.com" target="_blank">Inutilis Website</a> <span>|</span>
			<a href="http://apps.timokloss.com/dungeons/Privacy_Policy_DoS.pdf" target="_blank">Privacy</a>
		</div>
		
		<div style="margin:10px 0px 0px 0px; text-align: center;">
			<form method="get" action="changelocale.php" target="_top">
				<select name="locale">
					<option value="en_US" <?php if ($game_locale == "en_US") echo "selected"; ?> >English</option>
					<option value="es_ES" <?php if ($game_locale == "es_ES") echo "selected"; ?> >Español</option>
					<option value="de_DE" <?php if ($game_locale == "de_DE") echo "selected"; ?> >Deutsch</option>
					<option value="fr_FR" <?php if ($game_locale == "fr_FR") echo "selected"; ?> >Français</option>
				</select>
				<input type="hidden" name="fb_user_id" value="<?php echo $data['user_id']; ?>">
				<input class="inputbutton" type="submit" value="Go">
			</form>
		</div>
		
		<div style="height: 25px;">
		</div>
		
		<script type="text/javascript">
			FB.Canvas.setSize({height: 1000});
		</script>
		
<?php
	}
?>

	</body>
<?php
}
?>
</html>