<?php
include 'connect.php';
header("Content-type: text/json");
$mysqli = new mysqli($host, $user, $passw, $database);
$output = array();
$output['mysql_error'] = ($mysqli->connect_errno > 0);

echo json_encode($output);
?>