<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);

$event_id = $_GET['id'];
$event_name = $_GET['name'];
$event_location = $_GET['loc'];
$event_org = $_GET['org'];
$event_classes = $_GET['classes'];
$start_date = $_GET['start_date'];
$end_date = $_GET['end_date'];

if (!$event_name)
    $event_name = "temp";
if (!$event_location)
    $event_location = "temp";
if (!$event_org)
    $event_org = "";
if (!$start_date)
    $start_date = date("Y-m-d");
if (!$end_date)
    $end_date = date("Y-m-d");
    
$event_classes_array = explode("," ,$event_classes);
$old_class_result = $mysqli->query("SELECT id, class_name FROM event_class WHERE event_id=$event_id");
while (list($cid, $cname) = $old_class_result->fetch_row()) {
    if (!in_array($cname, $event_classes_array)) {
        $mysqli->query("DELETE FROM event_class WHERE id=$cid");
    }
    else {
        unset($event_classes_array[array_search($cname, $event_classes_array)]);
    }
}

foreach ($event_classes_array as $event_class_name) {
    $query = "INSERT INTO event_class (event_id, class_name) VALUES ($event_id, '$event_class_name');";
    $mysqli->query($query);
}


$query = "UPDATE event SET name='$event_name', location='$event_location', organization='$event_org', start_date='$start_date', end_date='$end_date' WHERE id=$event_id";
$result = $mysqli->query($query);
$mysqli->close();
?>