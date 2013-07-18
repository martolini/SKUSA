<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);

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
if (!$event_classes)
    $event_classes = "";
if (!$start_date)
    $start_date = date("Y-m-d");
if (!$end_date)
    $end_date = date("Y-m-d");
    
$event_array = explode(",", $event_classes);


$query = "INSERT INTO event (name, location, organization, start_date, end_date) VALUES ('$event_name', '$event_location', '$event_ord', '$start_date', '$end_date')";
$result = $mysqli->query($query);
$event_id = $mysqli->insert_id;
foreach ($event_array as $class_name) {
    if ($class_name != "")
        $mysqli->query("INSERT INTO event_class (event_id, class_name) VALUES ($event_id, '$class_name')");
}
$mysqli->close();
?>