<?php

function get_client_ip()
{
    $ipaddress = '';
    if (isset($_SERVER['HTTP_CLIENT_IP'])) {
        $ipaddress = $_SERVER['HTTP_CLIENT_IP'];
    } else if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $ipaddress = $_SERVER['HTTP_X_FORWARDED_FOR'];
    } else if (isset($_SERVER['HTTP_X_FORWARDED'])) {
        $ipaddress = $_SERVER['HTTP_X_FORWARDED'];
    } else if (isset($_SERVER['HTTP_FORWARDED_FOR'])) {
        $ipaddress = $_SERVER['HTTP_FORWARDED_FOR'];
    } else if (isset($_SERVER['HTTP_FORWARDED'])) {
        $ipaddress = $_SERVER['HTTP_FORWARDED'];
    } else if (isset($_SERVER['REMOTE_ADDR'])) {
        $ipaddress = $_SERVER['REMOTE_ADDR'];
    } else {
        $ipaddress = 'UNKNOWN';
    }

    return $ipaddress;
}

$ip = get_client_ip();
$platform = $_POST["platform"];
$os = $_POST["os"];
$os_ver = $_POST["os_ver"];
$cpu = $_POST["cpu"];
$core = $_POST["core"];
$ram = $_POST["ram"];
$gpu_vendor = $_POST["gpu_vendor"];
$gpu_renderer = $_POST["gpu_renderer"];
$device_vendor = $_POST["device_vendor"];
$device_model = $_POST["device"];
$browser = $_POST["browser"];
$browser_ver = $_POST["browser_ver"];
$engine = $_POST["engine"];
$engine_ver = $_POST["engine_ver"];
$user_agent = $_POST["user_agent"];
$resolution = $_POST["resolution"];
$language = $_POST["language"];
$time_zone = $_POST["time_zone"];

// Get system date & time
$dateTime = date("Y-m-d H:i:s");

// Create folder if not exists
$folder = "Device_info";
if (!is_dir($folder)) {
    mkdir($folder, 0777, true);
}

// Generate next available file name (info1.txt, info2.txt, ...)
$i = 1;
do {
    $filename = "$folder/info$i.txt";
    $i++;
} while (file_exists($filename));

// Prepare details
$details = "Date/Time          : $dateTime
IP Address         : $ip
OS Name            : $os 
OS Version         : $os_ver 
Platform           : $platform
CPU Architecture   : $cpu 
CPU Core           : $core 
GPU Vendor         : $gpu_vendor 
GPU Renderer       : $gpu_renderer 
Device Vendor      : $device_vendor
Device Model       : $device_model
RAM                : $ram
Browser Name       : $browser 
Browser Version    : $browser_ver 
Engine             : $engine 
Engine Version     : $engine_ver 
User Agent         : $user_agent
Resolution         : $resolution 
Language           : $language 
Time Zone          : $time_zone 
";

// Output on screen
echo "$details";

// Write to new file
$file = fopen($filename, "w");
fwrite($file, $details . "\n--------------------------------------\n");
fclose($file);
?>
