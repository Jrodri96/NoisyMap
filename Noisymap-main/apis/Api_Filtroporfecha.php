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

// Obtener los datos JSON del cuerpo de la solicitud
$data = json_decode(file_get_contents("php://input"), true);

// Verificar si se proporciona la fecha
if (!isset($data['fecha'])) {
    die(json_encode(["status" => "error", "message" => "No se proporcionó la fecha."]));
}

$fecha = $conn->real_escape_string($data['fecha']);

// Consulta para estadísticas de resumen
$sql_summary = "
    SELECT 
        AVG(Nivel_Ruido) AS Promedio, 
        MIN(Nivel_Ruido) AS Minimo, 
        MAX(Nivel_Ruido) AS Pico 
    FROM ruido 
    WHERE Fecha = '$fecha'";

$result_summary = $conn->query($sql_summary);

// Consulta para estadísticas por hora
$sql_hourly = "
    SELECT 
        HOUR(Hora) AS hora,
        AVG(Nivel_Ruido) AS nivel_ruido_promedio
    FROM ruido 
    WHERE Fecha = '$fecha'
    GROUP BY HOUR(Hora)
    ORDER BY HOUR(Hora)";

$result_hourly = $conn->query($sql_hourly);

// Procesar resultados
if ($result_summary && $result_hourly) {
    $summary_data = $result_summary->fetch_assoc();

    $hourly_data = [];
    while ($row = $result_hourly->fetch_assoc()) {
        $hourly_data[] = [
            "hora" => str_pad($row['hora'], 2, '0', STR_PAD_LEFT) . ":00",
            "nivel_ruido" => round($row['nivel_ruido_promedio'], 2)
        ];
    }

    echo json_encode([
        "status" => 1,
        "data" => [
            "summary" => $summary_data,
            "hourly" => $hourly_data
        ]
    ]);
} else {
    echo json_encode(["status" => 0, "message" => "No se encontraron registros para la fecha proporcionada."]);
}

$conn->close();
?>
