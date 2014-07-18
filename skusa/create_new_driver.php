<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);

$driver_event_id = $_GET['event_id'];
$query = "INSERT INTO driver (name, event_id) VALUES ('New Driver', $driver_event_id)";
$result = $mysqli->query($query);
echo json_encode(array('id' => $mysqli->insert_id));
$mysqli->close();
?>