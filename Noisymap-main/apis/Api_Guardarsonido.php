<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "monitoreo_ruido";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["status" => 0, "message" => "Error en la conexión: " . $conn->connect_error]));
}

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['userID'], $data['noiseLevel'], $data['latitude'], $data['longitude'])) {
    $userID = $data['userID'];
    $noiseLevel = $data['noiseLevel'];
    $latitude = $data['latitude'];
    $longitude = $data['longitude'];

    if (is_numeric($noiseLevel) && $noiseLevel >= 0 && $noiseLevel <= 150 && is_numeric($latitude) && is_numeric($longitude)) {
        // Insertamos en la tabla con las columnas separadas para la fecha y la hora
        $stmt = $conn->prepare("INSERT INTO ruido (Usuario_ID, Nivel_Ruido, Latitud, Longitud, Fecha, Hora) VALUES (?, ?, ?, ?, DATE(NOW()), TIME(NOW()))");
        $stmt->bind_param("iddd", $userID, $noiseLevel, $latitude, $longitude);
        
        if ($stmt->execute()) {
            echo json_encode(["status" => 1, "message" => "Ruido guardado exitosamente"]);
        } else {
            echo json_encode(["status" => 0, "message" => "Error al guardar el ruido: " . $stmt->error]);
        }
        
        $stmt->close();
    } else {
        echo json_encode(["status" => 0, "message" => "Datos inválidos"]);
    }
} else {
    echo json_encode(["status" => 0, "message" => "Faltan datos en la solicitud"]);
}

$conn->close();
?>
