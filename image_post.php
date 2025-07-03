<?php
// image_post.php

$uploadDir = __DIR__ . '/uploads/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

// Get raw POST data
$input = file_get_contents("php://input");
$data = json_decode($input, true);

// Validate image data
if (!isset($data['image']) || !preg_match('/^data:image\/png;base64,/', $data['image'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => '❌ Invalid image data.']);
    exit;
}

// Clean base64 and decode
$base64 = str_replace('data:image/png;base64,', '', $data['image']);
$base64 = str_replace(' ', '+', $base64);
$imageData = base64_decode($base64);

// Generate filename
$filename = $uploadDir . time() . '_captured.png';

// Save file
if (file_put_contents($filename, $imageData)) {
    http_response_code(200);
    echo json_encode(['status' => 'success', 'message' => '✅ Image saved.', 'file' => basename($filename)]);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => '❌ Failed to save image.']);
}
?>

