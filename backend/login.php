<?php
include 'db_config.php';

$username = $_POST['username'];
$password = $_POST['password'];

$sql = "SELECT role, id FROM users WHERE username = ? AND password = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $username, $password);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode(['status' => 'success', 'role' => $row['role'], 'id' => $row['id']]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid credentials']);
}

$stmt->close();
$conn->close();
?>
