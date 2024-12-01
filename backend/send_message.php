<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'db_config.php';

if (!isset($_POST['senderId'], $_POST['receiverId'], $_POST['message'])) {
    echo json_encode(['status' => 'error', 'message' => 'Missing parameters']);
    exit;
}

$senderId = $_POST['senderId'];
$receiverId = $_POST['receiverId'];
$message = $_POST['message'];

$sql = "INSERT INTO messages (sender_id, receiver_id, message) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode(['status' => 'error', 'message' => 'Database error: ' . $conn->error]);
    exit;
}

$stmt->bind_param("iis", $senderId, $receiverId, $message);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to send message']);
}

$stmt->close();
$conn->close();
?>
