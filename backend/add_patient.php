<?php
include 'db_config.php';

$name = $_POST['name'];
$address = $_POST['address'];
$dob = $_POST['dob'];
$patientNumber = $_POST['patientNumber'];
$password = $_POST['password'];

$sql = "INSERT INTO patients (name, address, dob, patient_number, password) VALUES (?, ?, ?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sssss", $name, $address, $dob, $patientNumber, $password);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to add patient']);
}

$stmt->close();
$conn->close();
?>
