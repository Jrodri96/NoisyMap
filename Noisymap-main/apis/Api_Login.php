<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configurar el tipo de contenido
header('Content-Type: application/json');

// Conexión a la base de datos
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "monitoreo_ruido";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Conexión fallida: " . $conn->connect_error]));
}

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['User'], $data['Password'])) {
    $user = $data['User'];
    $password = $data['Password'];

    $sql = "SELECT ID, Password FROM usuarios WHERE User = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $user);
    $stmt->execute();
    $stmt->bind_result($id, $hashed_password);
    $stmt->fetch();

    if ($hashed_password) {
        if (password_verify($password, $hashed_password)) {
            echo json_encode([
                "status" => 1,
                "message" => "Inicio de sesión exitoso",
                "ID" => $id
            ]);
        } else {
            echo json_encode(["status" => 0, "message" => "Credenciales inválidas"]);
        }
    } else {
        echo json_encode(["status" => 0, "message" => "El usuario no existe"]);
    }

    $stmt->close();
} else {
    echo json_encode(["status" => "missing_fields", "message" => "Faltan campos en la solicitud"]);
}

$conn->close();
?>
