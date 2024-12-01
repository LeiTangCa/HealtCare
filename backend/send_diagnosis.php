<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'db_config.php';

// Check if required parameters are present
if (!isset($_POST['doctorId'], $_POST['patientId'], $_POST['diagnosis'])) {
    echo json_encode(['status' => 'error', 'message' => 'Missing parameters']);
    exit;
}

$doctorId = $_POST['doctorId'];
$patientId = $_POST['patientId'];
$diagnosis = $_POST['diagnosis'];

// Validate non-empty values
if (empty($doctorId) || empty($patientId) || empty($diagnosis)) {
    echo json_encode(['status' => 'error', 'message' => 'Empty parameter(s)']);
    exit;
}

$sql = "INSERT INTO diagnoses (doctor_id, patient_id, diagnosis) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode(['status' => 'error', 'message' => 'Database error: ' . $conn->error]);
    exit;
}

$stmt->bind_param("iis", $doctorId, $patientId, $diagnosis);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to send diagnosis']);
}

$stmt->close();
$conn->close();
?>
