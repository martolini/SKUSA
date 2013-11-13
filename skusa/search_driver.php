<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);

$unknown_id = $_GET['id'];

$result = $mysqli->query("SELECT driver_id FROM driver_tire WHERE tire_id={$unknown_id}");
if ($result->num_rows == 0) {
	$result = $mysqli->query("SELECT driver_id FROM driver_engine WHERE engine_id={$unknown_id}");
	if ($result->num_rows == 0) {
		$result = $mysqli->query("SELECT driver_id FROM driver_chassis WHERE chassis_id={$unknown_id}");
	}
}
$driver = array();
while (list($cid) = $result->fetch_row()) {
	$driver['id'] = $cid;
}
$result = $mysqli->query("SELECT driver.name, driver.kart, driver.note, event_class.class_name, event.start_date FROM driver
JOIN event ON event.id = driver.event_id
JOIN event_class ON driver.class_id = event_class.id
WHERE driver.id={$driver['id']}");
while (list($name, $kart, $class, $date) = $result->fetch_row()) {
	$driver['name'] = $name;
	$driver['kart'] = $kart;
	$driver['nort'] = $note;
	$driver['class'] = $class;
	$driver['date'] = $date;
}
$id = $driver['id'];
$sub_result = $mysqli->query("SELECT tire_id FROM driver_tire WHERE driver_id=$id");
$tire_array = array();
while (list($tire_id) = $sub_result->fetch_row()) {
    array_push($tire_array, $tire_id);
}
//handle engine
$sub_result = $mysqli->query("SELECT engine_id FROM driver_engine WHERE driver_id=$id");
$engine_array = array();
while (list($engine_id) = $sub_result->fetch_row()) {
    array_push($engine_array, $engine_id);
}
//handle chassis
$sub_result = $mysqli->query("SELECT chassis_id FROM driver_chassis WHERE driver_id=$id");
$chassis_array = array();
while (list($chassis_id) = $sub_result->fetch_row()) {
    array_push($chassis_array, $chassis_id);
}

$tire_string = implode(",", $tire_array);
$engine_string = implode(",", $engine_array);
$chassis_string = implode(",", $chassis_array);
if (!$tire_string) {
    $tire_string = "";
}
if (!$engine_string) {
    $engine_string = "";
}
if (!$chassis_string) {
    $chassis_string = "";
}
$driver['tires'] = $tire_string;
$driver['chassis'] = $chassis_string;
$driver['engines'] = $engine_string;
$mysqli->close();
print json_encode($driver);
?>