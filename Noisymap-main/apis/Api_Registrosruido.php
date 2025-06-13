<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Manejo de solicitudes OPTIONS
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configurar el tipo de contenido
header('Content-Type: application/json');

// Conexión a la base de datos
$servername = "localhost";
$username = "root"; // Cambia por tu usuario de la base de datos
$password = ""; // Cambia por tu contraseña de la base de datos
$dbname = "monitoreo_ruido";

// Establecer la conexión
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar conexión
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Conexión fallida: " . $conn->connect_error]));
}

// Consulta para obtener todos los registros de ruido
$sql = "SELECT Id_Medida, Nivel_Ruido, 
        Fecha, 
        Hora, 
        Latitud, Longitud, Usuario_ID 
        FROM ruido";

$result = $conn->query($sql);

// Verificar si la consulta se ejecutó correctamente
if (!$result) {
    die(json_encode(["status" => "error", "message" => "Error en la consulta: " . $conn->error]));
}

$ruido_data = array();

// Si hay resultados, los procesamos
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        // Convertir valores a float para asegurarte de que se devuelvan como números
        $ruido_data[] = [
            'Id_Medida' => $row['Id_Medida'],
            'Nivel_Ruido' => (float)$row['Nivel_Ruido'],
            'Fecha' => $row['Fecha'],  // No es necesario separar, ya que está por separado en la base de datos
            'Hora' => $row['Hora'],    // No es necesario separar, ya que está por separado en la base de datos
            'Latitud' => (float)$row['Latitud'],
            'Longitud' => (float)$row['Longitud'],
            'Usuario_ID' => $row['Usuario_ID']
        ];
    }
    // Devolvemos los datos en formato JSON
    echo json_encode(["status" => 1, "data" => $ruido_data]);
} else {
    // Si no hay registros, devolvemos un mensaje
    echo json_encode(["status" => 0, "message" => "No se encontraron registros de ruido"]);
}

// Cerrar la conexión
$conn->close();
?>
