<?php

$dir = "audio_uploads/";
$files = glob($dir . "*.webm");

function cleanUp($paths) {
    foreach ($paths as $path) {
        if (file_exists($path)) {
            @unlink($path);
        }
    }
}

if (empty($files)) {
    echo json_encode([
        "status" => "error",
        "message" => "❌ No audio parts found."
    ]);
    exit;
}

// Step 1: Sort files naturally
natsort($files);
$files = array_values($files);

// Step 2: Convert .webm to .wav
$wavFiles = [];
foreach ($files as $index => $file) {
    $cleanWav = tempnam($dir, "clean_") . ".wav";
    $cmd = "ffmpeg -i " . escapeshellarg($file) .
           " -ar 44100 -ac 2 -y " . escapeshellarg($cleanWav) .
           " > /dev/null 2>&1";
    shell_exec($cmd);

    if (!file_exists($cleanWav)) {
        cleanUp([$cleanWav]);
        echo json_encode([
            "status" => "error",
            "message" => "❌ Failed to convert: $file"
        ]);
        exit;
    }

    $wavFiles[] = $cleanWav;
}

// Step 3: Generate concat list
$concatListPath = $dir . "file_list.txt";
file_put_contents($concatListPath, '');

foreach ($wavFiles as $wav) {
    $safePath = str_replace("'", "'\\''", $wav);
    file_put_contents($concatListPath, "file '" . $safePath . "'\n", FILE_APPEND);
}

// Step 4: Merge WAVs
$mergedWav = $dir . "merged.wav";
$mergeCmd = "ffmpeg -f concat -safe 0 -i " . escapeshellarg($concatListPath) .
            " -ar 44100 -ac 2 -c:a pcm_s16le -y " . escapeshellarg($mergedWav) .
            " > /dev/null 2>&1";
shell_exec($mergeCmd);

if (!file_exists($mergedWav)) {
    cleanUp($wavFiles);
    cleanUp([$concatListPath]);
    echo json_encode([
        "status" => "error",
        "message" => "❌ Failed to merge WAV files."
    ]);
    exit;
}

// Step 5: Convert to MP3
$timestamp = date("Y-m-d_H-i-s");
$finalMp3 = $dir . "final_$timestamp.mp3";
$cmdFinal = "ffmpeg -i " . escapeshellarg($mergedWav) .
            " -codec:a libmp3lame -qscale:a 2 -y " . escapeshellarg($finalMp3) .
            " > /dev/null 2>&1";
shell_exec($cmdFinal);

if (!file_exists($finalMp3)) {
    cleanUp([$mergedWav, $concatListPath]);
    cleanUp($wavFiles);
    echo json_encode([
        "status" => "error",
        "message" => "❌ Failed to create MP3."
    ]);
    exit;
}

// Step 6: Final cleanup
cleanUp($files);          // Original .webm
foreach ($wavFiles as $wav) {
    cleanUp([$wav]);                          // .wav file
    cleanUp([preg_replace('/\.wav$/', '', $wav)]); // underlying tempnam file
}
cleanUp([$mergedWav]);    // Merged wav
cleanUp([$concatListPath]); // file_list.txt

echo json_encode([
    "status" => "success",
    "message" => "✅ Final MP3 created.",
    "file" => $finalMp3
]);

