<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);

$driver_id = $_GET['id'];

$mysqli->query("DELETE FROM driver_tire WHERE driver_id=$driver_id");
$mysqli->query("DELETE FROM driver_engine WHERE driver_id=$driver_id");
$mysqli->query("DELETE FROM driver_chassis WHERE driver_id=$driver_id");

$mysqli->query("DELETE FROM driver WHERE id=$driver_id");
$mysqli->close();
?>