<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);

$query = "SELECT id, name, location, organization, start_date, end_date from event";
$result = $mysqli->query($query);
$output = array();
while (list($id, $name, $location, $organization, $start_date, $end_date) = $result->fetch_row()) {
    $classes_result = $mysqli->query("SELECT class_name from event_class WHERE event_id = $id");
    $class_array = array();
    while (list($class_name) = $classes_result->fetch_row()) {
        array_push($class_array, $class_name);
    }
    if (!$name)
        $name = "";
    if (!$location)
        $location = "";
    $class_string = implode(",", $class_array);
    if (!$class_string)
        $class_string = "";
    if (!$location)
        $location = "";
    if (!$organization)
        $organization = "";
    if (!$start_date)
        $start_date = "";
    if (!$end_date)
        $end_date = "";
    $output[$id] = array(
        'id' => $id,
        'name' => $name,
        'location' => $location,
        'organization' => $organization,
        'classes' => $class_string,
        'start_date' => $start_date,
        'end_date' => $end_date
    );
}

$mysqli->close();
print json_encode($output);
?>