<?php

include 'connect.php';
require_once('external/parsecsv.lib.php');

function create_driver($list) {
    $name = str_replace("'", "", $list['first name'] . " " . $list['last name']);
    $driverclass = $list['class'];
    $kart = $list['kart #'];
    return (object) array(
        'name' => $name,
        'class' => $driverclass,
        'kart' => $kart);
}

function createTables($db) {

  $db->query("CREATE TABLE IF NOT EXISTS `settings` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `tire_range` varchar(20) DEFAULT '0-10000',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;");

  $db->query("CREATE TABLE IF NOT EXISTS `driver` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `event_id` int(11) DEFAULT NULL,
  `name` varchar(40) DEFAULT NULL,
  `kart` varchar(6) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=269 DEFAULT CHARSET=latin1;");

  $db->query("CREATE TABLE IF NOT EXISTS `driver_chassis` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `driver_id` int(11) DEFAULT NULL,
  `chassis_id` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;");

  $db->query("CREATE TABLE IF NOT EXISTS `driver_engine` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `driver_id` int(11) DEFAULT NULL,
  `engine_id` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;");

  $db->query("CREATE TABLE IF NOT EXISTS `driver_tire` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `driver_id` int(11) DEFAULT NULL,
  `tire_id` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;");

  $db->query("CREATE TABLE IF NOT EXISTS `event` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(40) DEFAULT NULL,
  `location` varchar(40) DEFAULT NULL,
  `organization` varchar(40) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;");

  $db->query("CREATE TABLE IF NOT EXISTS `event_class` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `event_id` int(11) DEFAULT NULL,
  `class_name` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_class` (`event_id`,`class_name`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;");

}

function parseCSV($csvfile) {
    global $host, $user, $passw, $database;
    $db = new mysqli($host, $user, $passw, $database);
    if ($db->connect_errno > 0)
        die("Could not connect to database.");
    createTables($db);
    $csv = new parseCSV();
    $csv->auto($csvfile);
    $drivers = array();
    $driverclasses = array();
    foreach ($csv->data as $line) {
        if (!($line['first name'] || $line['last name']))
            continue;
        array_push($drivers, create_driver($line));
        if (!in_array($line['class'], $driverclasses))
            array_push($driverclasses, $line['class']);
    }
    $event_result = $db->query("INSERT INTO event (name, location, organization) VALUES ('NEW EVENT', 'Somewhere', 'Someone')");
    $event_id = $db->insert_id;
    $class_ids = array();
    foreach ($driverclasses as $class) {
        $db->query("INSERT INTO event_class (event_id, class_name) VALUES ({$event_id}, '{$class}')");
        array_push($class_ids, $db->insert_id);
    }
    foreach ($drivers as $driver) {
        $class_id = $class_ids[array_search($driver->class, $driverclasses)];
        $db->query("INSERT INTO driver (event_id, name, kart, class_id) VALUES ({$event_id}, '{$driver->name}' , '{$driver->kart}', {$class_id})");
    }
    $db->close();
    echo "</br>The event has now loaded into the database with name NEW EVENT";

}

function loadTable($path) {
    $tablename = "events";
    global $host, $user, $passw, $database;
    $mycon = new mysqli($host, $user, $passw, $database);
    
    if ($mycon->connect_errno) {
        echo $mycon->connect_error;
    }
    $createQuery = "DROP TABLE IF EXISTS $tablename";
    $mycon->query($createQuery);
    $createQuery = "CREATE TABLE `$tablename` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `No` varchar(10) DEFAULT NULL,
    `Class` varchar(17) DEFAULT NULL,
    `FirstName` varchar(12) DEFAULT NULL,
    `LastName` varchar(14) DEFAULT NULL,
    `CarRegistration` varchar(8) DEFAULT NULL,
    `DriverRegistration` varchar(8) DEFAULT NULL,
    `Transponder1` int(7) DEFAULT NULL,
    `Transponder2` varchar(7) DEFAULT NULL,
    `Additional1` varchar(50) DEFAULT NULL,
    `Additional2` varchar(17) DEFAULT NULL,
    `Additional3` varchar(35) DEFAULT NULL,
    `Additional4` varchar(48) DEFAULT NULL,
    `Additional5` varchar(10) DEFAULT NULL,
    `Additional6` varchar(10) DEFAULT NULL,
    `Additional7` varchar(10) DEFAULT NULL,
    `Additional8` varchar(10) DEFAULT NULL,
    `dummy` varchar(10) DEFAULT NULL,
    PRIMARY KEY (`id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8;";
    if ($mycon->query($createQuery) === TRUE) {
        echo "Created table $tablename. <br>";
    }
    else {
        echo mysqli_error($mycon);
    }
    
    $loadQuery = "LOAD DATA LOCAL
    INFILE '$path'
    INTO TABLE $tablename
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES
    (No, Class, FirstName, LastName, CarRegistration, DriverRegistration, Transponder1, Transponder2, Additional1, Additional2, Additional3, Additional4, Additional5, Additional6, Additional7, Additional8, dummy)";
    if ($mycon->query($loadQuery) === TRUE) {
        echo "CSV loaded sucessfully.\n";
    }
    else {
        echo "Error loading CSV.\n";
    }
    $mycon->close();
}
?>