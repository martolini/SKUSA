<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);

// Works as of PHP 5.2.9 and 5.3.0.
if ($mysqli->connect_error) {
    die('Connect Error: ' . $mysqli->connect_error);
}

$tire_range = "";
$result = $mysqli->query("SELECT tire_range FROM settings WHERE id=1");
while (list($tire_raw) = $result->fetch_row())
	$tire_range = $tire_raw;

$mysqli->close();
print json_encode(array('tire_range' => $tire_range));

?>