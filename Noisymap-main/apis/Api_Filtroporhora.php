<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

header('Content-Type: application/json');

// Configuración de conexión a la base de datos
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "monitoreo_ruido";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Conexión fallida: " . $conn->connect_error]));
}

// Consulta para calcular el promedio de ruido por cada hora considerando todas las fechas
$sql = "
    SELECT 
        HOUR(Hora) AS hora,
        AVG(Nivel_Ruido) AS nivel_ruido_promedio
    FROM ruido
    GROUP BY HOUR(Hora)
    ORDER BY HOUR(Hora)";

$result = $conn->query($sql);

if ($result) {
    $hourlyData = [];
    while ($row = $result->fetch_assoc()) {
        $hourlyData[] = [
            "hora" => str_pad($row['hora'], 2, '0', STR_PAD_LEFT) . ":00",
            "nivel_ruido" => round($row['nivel_ruido_promedio'], 2)
        ];
    }

    echo json_encode(["status" => 1, "hourly" => $hourlyData]);
} else {
    echo json_encode(["status" => 0, "message" => "No se encontraron registros."]);
}

$conn->close();
?>
