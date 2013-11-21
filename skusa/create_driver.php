<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);

$driver_name = $_GET['name'];
$driver_kart = $_GET['kart'];
$driver_note = $_GET['note'];
$driver_event_id = $_GET['event_id'];
$driver_class = $_GET['class'];
$ipod = $_GET['ipod'];


$found = false;
$ipod_result = $mysqli->query("SELECT id FROM scanners WHERE uuid like '$ipod'");
while (list($ipodid) = $ipod_result->fetch_row()) {
	$ipod = $ipodid;
	$found = true;
}
if (!$found) {
	$res = $mysqli->query("INSERT INTO scanners (uuid) VALUES ('$ipod')");
	$ipod = $mysqli->insert_id;
}

if (!$driver_name)
    $driver_name = "temp";
if (!$driver_kart)
    $driver_kart = "temp";
if (!$driver_note)
	$driver_note = "";

$class_result = $mysqli->query("SELECT id FROM event_class WHERE class_name like '$driver_class'");
$driver_class_id = 0;
while (list($cid) = $class_result->fetch_row()) {
    $driver_class_id = $cid;
}
$query = "INSERT INTO driver (name, kart, note, event_id, class_id, synced_with) VALUES ('$driver_name', '$driver_kart', '$driver_note', $driver_event_id, $driver_class_id, '$ipod')";
$result = $mysqli->query($query);
$mysqli->close();
?>