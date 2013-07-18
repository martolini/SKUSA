<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);

// Works as of PHP 5.2.9 and 5.3.0.
if ($mysqli->connect_error) {
    die('Connect Error: ' . $mysqli->connect_error);
}

$query = "SELECT id, Class, FirstName, LastName, No, Transponder1 FROM events ORDER BY id";
$result = $mysqli->query($query);
$output = array();
while (list($id, $class, $firstname, $lastname, $carreg, $amb) = $result->fetch_row()) {
    $output[$id] = array(
        'class' => $class,
        'firstname' => $firstname,
        'lastname' => $lastname,
        'kart' => $carreg,
        'amb' => $amb
    );
}
$mysqli->close();

echo json_encode($output);
?>