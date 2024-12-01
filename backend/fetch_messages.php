<?php
include 'db_config.php';

$userId = $_GET['userId'];

// Ensure the userId is being passed correctly
if (empty($userId)) {
    echo json_encode(['status' => 'error', 'message' => 'userId is missing']);
    exit;
}

$sql = "SELECT * FROM messages WHERE receiver_id = ? or sender_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ii", $userId, $userId);
$stmt->execute();
$result = $stmt->get_result();

$messages = [];
while ($row = $result->fetch_assoc()) {
    $messages[] = $row;
}

// Check if any messages were fetched
if (empty($messages)) {
    echo json_encode(['status' => 'error', 'message' => 'No messages found']);
    exit;
}

echo json_encode($messages);

$stmt->close();
$conn->close();
?>
