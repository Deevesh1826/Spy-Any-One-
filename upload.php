<?php
if (isset($_FILES['audio'])) {
    $uploadDir = 'audio_uploads/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0755, true);
    }

    // Upload audio
    $filename = $uploadDir . 'audio_' . time() . '_' . rand(1000, 9999) . '.webm';
    if (move_uploaded_file($_FILES['audio']['tmp_name'], $filename)) {

        // ✅ Append file path to file_list.txt
        $listFile = $uploadDir . 'file_list.txt';
        file_put_contents($listFile, $filename . PHP_EOL, FILE_APPEND | LOCK_EX);

        echo "✅ Audio uploaded & path added to list.";
    } else {
        echo "❌ Failed to upload audio.";
    }
} else {
    echo "❌ No audio data received.";
}
?>

