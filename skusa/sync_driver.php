<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);

$driver_id = $_GET['id'];
$driver_name = $_GET['name'];
$driver_kart = $_GET['kart'];
$driver_note = $_GET['note'];
$driver_class = $_GET['class'];
$driver_tires = $_GET['tire'];
$driver_engines = $_GET['engine'];
$driver_chassis = $_GET['chassis'];

$event_result = $mysqli->query("SELECT event_id FROM driver WHERE id={$driver_id}");
$event_id = -1;
while (list($evid) = $event_result->fetch_row())
	$event_id = $evid;

// handle class
$class_result = $mysqli->query("SELECT id FROM event_class WHERE class_name like '$driver_class' AND event_id={$event_id}");
$class_id = 0;
while (list($cid) = $class_result->fetch_row()) {
    $class_id = $cid;
}

// handle name, kart
$mysqli->query("UPDATE driver SET name='$driver_name', kart='$driver_kart', note='$driver_note', class_id=$class_id WHERE id = $driver_id");

// handle tires.

if ($driver_tires != -1) {
	$mysqli->query("DELETE FROM driver_tire WHERE driver_id=$driver_id");
	$tire_array = explode(",", $driver_tires);
	foreach ($tire_array as $tire_id) {
		if ($tire_id != '')
	    	$mysqli->query("INSERT INTO driver_tire (driver_id, tire_id) VALUES ($driver_id, '$tire_id')");
	}
}

// handle engine
if ($driver_engines != -1) {
$mysqli->query("DELETE FROM driver_engine WHERE driver_id=$driver_id");
	$engine_array = explode(",", $driver_engines);
	foreach ($engine_array as $engine_id) {
		if ($engine_id != '')
	    	$mysqli->query("INSERT INTO driver_engine (driver_id, engine_id) VALUES ($driver_id, '$engine_id')");
	}
}

// handle chassis
if ($driver_chassis != -1) {
	$mysqli->query("DELETE FROM driver_chassis WHERE driver_id=$driver_id");
	$chassis_array = explode(",", $driver_chassis);
	foreach ($chassis_array as $chassis_id) {
		if ($chassis_id != '')
	    	$mysqli->query("INSERT INTO driver_chassis (driver_id, chassis_id) VALUES ($driver_id, '$chassis_id')");
	}
}
// 
$mysqli->close();
?>