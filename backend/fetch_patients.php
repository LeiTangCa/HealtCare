<?php
include 'db_config.php';

$sql = "SELECT patients.id as patientid, patients.patient_number AS patient_number, patients.password AS password, patients.name AS name, patients.address AS address, patients.dob AS dob, users.id AS id FROM patients join users WHERE patients.id=users.patient_id";
$result = $conn->query($sql);

$patients = [];
while ($row = $result->fetch_assoc()) {
    $patients[] = $row;
}

echo json_encode($patients);

$conn->close();
?>
