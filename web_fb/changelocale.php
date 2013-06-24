<?php
require_once('localetools.php');

$canvas_page = "http://apps.facebook.com/dungeonsofsuerhop/";

$locale = $_GET["locale"];
$fbUserId = $_GET["fb_user_id"];

saveGameLocale($fbUserId, $locale);

header("Location: " . $canvas_page);
?>