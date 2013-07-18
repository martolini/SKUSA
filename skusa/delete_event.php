<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);

$event_id = $_GET['id'];


$query = "SELECT id FROM driver WHERE event_id=$event_id";
$result = $mysqli->query($query);
while (list($id) = $result->fetch_row()) {
    $mysqli->query("DELETE FROM driver_tire WHERE driver_id=$id");
    $mysqli->query("DELETE FROM driver_engine WHERE driver_id=$id");
    $mysqli->query("DELETE FROM driver_chassis WHERE driver_id=$id");
}
$mysqli->query("DELETE FROM driver WHERE event_id=$event_id");
$mysqli->query("DELETE FROM event_class WHERE event_id=$event_id");
$mysqli->query("DELETE FROM event WHERE id=$event_id");
$mysqli->close();
?>