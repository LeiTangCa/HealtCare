<?php
include 'db_config.php';

$userId = $_GET['userId'];

// Ensure the userId is being passed correctly
if (empty($userId)) {
    echo json_encode(['status' => 'error', 'message' => 'userId is missing']);
    exit;
}

$sql = "SELECT * FROM diagnoses WHERE patient_id = ? or doctor_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ii", $userId, $userId);
$stmt->execute();
$result = $stmt->get_result();

$diagnoses = [];
while ($row = $result->fetch_assoc()) {
    $diagnoses[] = $row;
}

// Check if any messages were fetched
if (empty($diagnoses)) {
    echo json_encode(['status' => 'error', 'message' => 'No messages found']);
    exit;
}

echo json_encode($diagnoses);

$stmt->close();
$conn->close();
?>
