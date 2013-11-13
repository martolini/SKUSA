<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);

$event_id = $_GET['id'];

// Works as of PHP 5.2.9 and 5.3.0.
if ($mysqli->connect_error) {
    die('Connect Error: ' . $mysqli->connect_error);
}

$query = "SELECT id, name, kart, note, class_id FROM driver where event_id = $event_id";
$result = $mysqli->query($query);
$driver = array();
while (list($id, $name, $kart, $note, $class_id) = $result->fetch_row()) {
    //handle tires
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
    if (!$class_id) {
        $class_id = 0;
    }
    $class_result = $mysqli->query("SELECT class_name FROM event_class WHERE id = $class_id");
    $class_name = "";
    while (list($q_class_name) = $class_result->fetch_row()) {
        $class_name = $q_class_name;
    }
    
    $driver[$id] = array(
        'name' => $name,
        'kart' => $kart,
        'note' => $note,
        'tires' => $tire_string,
        'engines' => $engine_string,
        'chassis' => $chassis_string,
        'class' => $class_name
    );
}


$mysqli->close();

echo json_encode($driver);
?>