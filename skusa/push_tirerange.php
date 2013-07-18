<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);

// Works as of PHP 5.2.9 and 5.3.0.
if ($mysqli->connect_error) {
    die('Connect Error: ' . $mysqli->connect_error);
}

$settings_result = $mysqli->query("SELECT id FROM settings");
$settings_id = -1;
while (list($d) = $settings_result->fetch_row())
    $settings_id = $d;

if ($settings_id == -1)
    $mysqli->query("INSERT INTO settings (id) VALUES (1)");

$range = $_GET['lower'] . "-" . $_GET['higher'];

$mysqli->query("UPDATE settings SET tire_range = '{$range}'");
$mysqli->close();

?>