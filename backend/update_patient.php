<?php
include 'db_config.php';

$id = $_POST['id'];
$name = $_POST['name'];
$address = $_POST['address'];
$dob = $_POST['dob'];

$sql = "UPDATE patients SET name = ?, address = ?, dob = ? WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sssi", $name, $address, $dob, $id);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to update patient']);
}

$stmt->close();
$conn->close();
?>
