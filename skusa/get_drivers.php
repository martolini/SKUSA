<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);

$event_id = $_GET['id'];
$ipod = $_GET['ipod'];

// Works as of PHP 5.2.9 and 5.3.0.
if ($mysqli->connect_error) {
    die('Connect Error: ' . $mysqli->connect_error);
}

$found = false;
$ipod_res = $mysqli->query("SELECT id FROM scanners WHERE uuid like '$ipod'");
while (list($ipodid) = $ipod_res->fetch_row()) {
    $ipod = $ipodid;
    $found = true;
}

if (!$found) {
    $mysqli->query("INSERT INTO scanners (uuid) VALUES ('$ipod')");
    $ipod = $mysqli->insert_id;
}

$query = "SELECT id, name, kart, note, class_id, synced_with FROM driver WHERE event_id = $event_id";
$result = $mysqli->query($query);
$driver = array();
while (list($id, $name, $kart, $note, $class_id, $synced_with) = $result->fetch_row()) {
    $ipod_array = explode(",",$synced_with);
    if (in_array($ipod, $ipod_array)) {
        $driver[$id] = array(
            'synced' => true
            );
        continue;
    }
    else {
        $mysqli->query("UPDATE driver SET synced_with = IFNULL(concat(synced_with, ',$ipod'), '$ipod') WHERE id=$id"); 
    }
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

    if (!$note) {
        $note = "";
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
        'class' => $class_name,
        'synced' => false
    );
}

$mysqli->close();

echo json_encode($driver);
?>