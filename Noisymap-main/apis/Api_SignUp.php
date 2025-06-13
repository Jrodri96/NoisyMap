<?php
// Habilitar CORS
header("Access-Control-Allow-Origin: *"); // Permite todas las solicitudes de cualquier dominio
header("Access-Control-Allow-Methods: GET, POST, OPTIONS"); // Métodos permitidos
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Permite el encabezado 'Content-Type' y 'Authorization'

// En caso de una solicitud OPTIONS (usada para verificar permisos CORS)
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

// Verificar conexión
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Conexión fallida: " . $conn->connect_error]));
}

// Leer los datos de la solicitud JSON
$data = json_decode(file_get_contents("php://input"), true);

// Verificar que los campos estén presentes
if (isset($data['ID'], $data['Nombre'], $data['User'], $data['Password'], $data['Telefono'], $data['Fecha_Nacimiento'], $data['Direccion'])) {
    $id = $data['ID'];
    $nombre = $data['Nombre'];
    $user = $data['User'];
    $password = password_hash($data['Password'], PASSWORD_BCRYPT);
    $telefono = $data['Telefono'];
    $fecha_nacimiento = $data['Fecha_Nacimiento'];
    $direccion = $data['Direccion'];

    // Validar si el ID ya existe
    $idCheck = $conn->query("SELECT * FROM usuarios WHERE ID='$id'");
    if ($idCheck->num_rows > 0) {
        echo json_encode(["status" => "error", "message" => "El ID ya existe"]); // ID ya existe
        exit();
    }

    // Validar si el nombre de usuario ya existe
    $userCheck = $conn->query("SELECT * FROM usuarios WHERE User='$user'");
    if ($userCheck->num_rows > 0) {
        echo json_encode(["status" => "error", "message" => "El usuario ya existe"]); // Nombre de usuario ya existe
        exit();
    }

    // Preparar la consulta SQL para insertar el nuevo usuario
    $sql = "INSERT INTO usuarios (ID, Nombre, User, Password, Telefono, Fecha_Nacimiento, Direccion) VALUES (?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssssss", $id, $nombre, $user, $password, $telefono, $fecha_nacimiento, $direccion);

    // Ejecutar la consulta
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Registro exitoso"]); // Registro exitoso
    } else {
        echo json_encode(["status" => "error", "message" => "Error en el registro"]); // Error en el registro
    }

    $stmt->close();
} else {
    echo json_encode(["status" => "error", "message" => "Faltan campos en la solicitud"]); // Faltan campos
}

$conn->close();
?>