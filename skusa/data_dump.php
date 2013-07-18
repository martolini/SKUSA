<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);

// Works as of PHP 5.2.9 and 5.3.0.
if ($mysqli->connect_error) {
    die('Connect Error: ' . $mysqli->connect_error);
}

$query = "SELECT id, name, kart, class_id FROM driver where event_id = 1";
$result = $mysqli->query($query);
$driver = array();
while (list($id, $name, $kart, $class_id) = $result->fetch_row()) {
    $sub_query = "SELECT tire_id, engine_id, chassis_id from driver_tire JOIN driver_engine JOIN driver_chassis WHERE driver_tire.driver_id=$id AND driver_engine.driver_id=$id AND driver_chassis.driver_id=$id";
    $sub_result = $mysqli->query($sub_query);
    $tire_array = array();
    $engine_array = array();
    $chassis_array = array();
    while (list($tire_id, $engine_id, $chassis_id) = $sub_result->fetch_row()) {
        array_push($tire_array, $tire_id);
        array_push($engine_array, $engine_id);
        array_push($chassis_array, $chassis_id);
    }
    $tire_string = implode(",", $tire_array);
    $engine_array = implode(", ", $engine_array);
    $chassis_array = implode(", ", $chassis_array);
    
    $class_result = $mysqli->query("SELECT class_name FROM event_class WHERE id = $class_id");
    $class_name = "";
    while (list($q_class_name) = $class_result->fetch_row()) {
        $class_name = $q_class_name;
    }
    
    $driver[$id] = array(
        'name' => $name,
        'kart' => $kart,
        'tires' => $tire_string,
        'engines' => $engine_string,
        'chassis' => $tire_string,
        'class' => $class_name
    );
}


$mysqli->close();

echo json_encode($driver);
?>