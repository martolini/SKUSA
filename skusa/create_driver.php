<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);

$driver_name = $_GET['name'];
$driver_kart = $_GET['kart'];
$driver_event_id = $_GET['event_id'];
$driver_class = $_GET['class'];

if (!$driver_name)
    $driver_name = "temp";
if (!$driver_kart)
    $driver_kart = "temp";

$class_result = $mysqli->query("SELECT id FROM event_class WHERE class_name like '$driver_class'");
$driver_class_id = 0;
while (list($cid) = $class_result->fetch_row()) {
    $driver_class_id = $cid;
}
$query = "INSERT INTO driver (name, kart, event_id, class_id) VALUES ('$driver_name', '$driver_kart', $driver_event_id, $driver_class_id)";
$result = $mysqli->query($query);
$mysqli->close();
?>