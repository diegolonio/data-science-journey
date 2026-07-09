<?php
// ---------------------------------------------------------------------------
// CRUD de catalogo_animalitos en PHP puro con PDO.
// Se conecta a tu Postgres del host usando las variables de entorno que
// define docker-compose.yml (con valores por defecto por si acaso).
// ---------------------------------------------------------------------------

$config = [
    'host' => getenv('DB_HOST') ?: '127.0.0.1',
    'port' => getenv('DB_PORT') ?: '5432',
    'db'   => getenv('DB_NAME') ?: 'analysis',
    'user' => getenv('DB_USER') ?: 'postgres',
    'pass' => getenv('DB_PASSWORD') ?: 'password',
];

// Conexión
try {
    $dsn = "pgsql:host={$config['host']};port={$config['port']};dbname={$config['db']}";
    $pdo = new PDO($dsn, $config['user'], $config['pass'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    die("<h1>Error de conexión a la base de datos</h1><pre>"
        . htmlspecialchars($e->getMessage()) . "</pre>");
}

$campos = ['nombre', 'id_tipo_animal', 'sexo', 'fecha_nacimiento',
           'fecha_ingreso', 'estado_salud', 'ubicacion'];

// Convierte "" en NULL para que Postgres reciba nulos y no cadenas vacías
function limpiar($valor) {
    return ($valor === '' || $valor === null) ? null : $valor;
}

$mensaje = '';

// --- Procesar acciones (crear / actualizar / borrar) -----------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $accion = $_POST['accion'] ?? '';

    if ($accion === 'crear') {
        $sql = "INSERT INTO public.catalogo_animalitos
                (nombre, id_tipo_animal, sexo, fecha_nacimiento,
                 fecha_ingreso, estado_salud, ubicacion)
                VALUES (?, ?, ?, ?, ?, ?, ?)";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            limpiar($_POST['nombre']), limpiar($_POST['id_tipo_animal']),
            limpiar($_POST['sexo']), limpiar($_POST['fecha_nacimiento']),
            limpiar($_POST['fecha_ingreso']), limpiar($_POST['estado_salud']),
            limpiar($_POST['ubicacion']),
        ]);
        $mensaje = 'Registro creado';
    } elseif ($accion === 'actualizar') {
        $sql = "UPDATE public.catalogo_animalitos SET
                    nombre = ?, id_tipo_animal = ?, sexo = ?,
                    fecha_nacimiento = ?, fecha_ingreso = ?,
                    estado_salud = ?, ubicacion = ?
                WHERE id_animalito = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            limpiar($_POST['nombre']), limpiar($_POST['id_tipo_animal']),
            limpiar($_POST['sexo']), limpiar($_POST['fecha_nacimiento']),
            limpiar($_POST['fecha_ingreso']), limpiar($_POST['estado_salud']),
            limpiar($_POST['ubicacion']), (int)$_POST['id_animalito'],
        ]);
        $mensaje = 'Registro actualizado';
    } elseif ($accion === 'borrar') {
        $stmt = $pdo->prepare("DELETE FROM public.catalogo_animalitos WHERE id_animalito = ?");
        $stmt->execute([(int)$_POST['id_animalito']]);
        $mensaje = 'Registro borrado';
    }

    // Patrón PRG: redirige tras el POST para evitar reenvíos al recargar
    header('Location: index.php?msg=' . urlencode($mensaje));
    exit;
}

$mensaje = $_GET['msg'] ?? '';

// --- Si estamos editando, cargamos el registro a modificar -----------------
$editando = null;
if (isset($_GET['editar'])) {
    $stmt = $pdo->prepare("SELECT * FROM public.catalogo_animalitos WHERE id_animalito = ?");
    $stmt->execute([(int)$_GET['editar']]);
    $editando = $stmt->fetch(PDO::FETCH_ASSOC);
}

// --- Lista completa --------------------------------------------------------
$animalitos = $pdo->query(
    "SELECT * FROM public.catalogo_animalitos ORDER BY id_animalito"
)->fetchAll(PDO::FETCH_ASSOC);

// Escapa texto para mostrarlo sin riesgo de HTML/JS inyectado
function e($v) { return htmlspecialchars($v ?? '', ENT_QUOTES); }
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>CRUD Animalitos (nginx + PHP)</title>
  <style>
    :root { --guinda: #6f1d46; --guinda-osc: #4a1330; --gris: #f4f4f5; }
    * { box-sizing: border-box; }
    body { font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; margin: 0; background: #fafafa; color: #222; }
    header { background: linear-gradient(135deg, var(--guinda), var(--guinda-osc)); color: #fff; padding: 1.5rem; text-align: center; }
    header h1 { margin: 0; font-size: 1.6rem; }
    main { max-width: 1000px; margin: 0 auto; padding: 1.5rem; }
    .card { background: #fff; border-radius: 10px; padding: 1.25rem; box-shadow: 0 2px 8px rgba(0,0,0,0.08); margin-bottom: 1.5rem; }
    .card h2 { margin-top: 0; color: var(--guinda); font-size: 1.2rem; }
    form.crud { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 0.9rem; }
    label { display: flex; flex-direction: column; font-size: 0.85rem; font-weight: 600; gap: 0.25rem; }
    input { padding: 0.5rem; border: 1px solid #ccc; border-radius: 6px; font-size: 0.95rem; }
    .acciones { grid-column: 1 / -1; display: flex; gap: 0.75rem; }
    button { cursor: pointer; border: none; border-radius: 6px; padding: 0.55rem 1.1rem; font-weight: 600; font-size: 0.9rem; }
    .btn-primary { background: var(--guinda); color: #fff; }
    .btn-secondary { background: #ddd; color: #333; text-decoration: none; display: inline-flex; align-items: center; }
    .btn-mini { padding: 0.3rem 0.6rem; font-size: 0.8rem; }
    .btn-edit { background: #2563eb; color: #fff; text-decoration: none; }
    .btn-del { background: #dc2626; color: #fff; }
    table { width: 100%; border-collapse: collapse; }
    .tabla-wrap { overflow-x: auto; }
    th, td { padding: 0.55rem 0.6rem; text-align: left; border-bottom: 1px solid #eee; font-size: 0.88rem; white-space: nowrap; }
    th { background: var(--gris); color: var(--guinda); }
    tr:hover td { background: #fcf7f9; }
    .msg { margin-bottom: 1rem; padding: 0.6rem 1rem; border-radius: 6px; background: #dcfce7; color: #166534; }
  </style>
</head>
<body>
  <header>
    <h1>Catálogo de Animalitos</h1>
    <p style="margin:0.3rem 0 0; opacity:0.85; font-size:0.9rem;">CRUD con nginx + PHP + PostgreSQL (base <code>analysis</code>)</p>
  </header>

  <main>
    <?php if ($mensaje): ?>
      <div class="msg"><?= e($mensaje) ?></div>
    <?php endif; ?>

    <div class="card">
      <h2><?= $editando ? 'Editar animalito #' . e($editando['id_animalito']) : 'Agregar animalito' ?></h2>
      <form class="crud" method="post" action="index.php">
        <input type="hidden" name="accion" value="<?= $editando ? 'actualizar' : 'crear' ?>">
        <?php if ($editando): ?>
          <input type="hidden" name="id_animalito" value="<?= e($editando['id_animalito']) ?>">
        <?php endif; ?>
        <label>Nombre
          <input name="nombre" maxlength="20" value="<?= e($editando['nombre'] ?? '') ?>" placeholder="Firulais">
        </label>
        <label>Tipo de animal (id)
          <input name="id_tipo_animal" type="number" value="<?= e($editando['id_tipo_animal'] ?? '') ?>" placeholder="1">
        </label>
        <label>Sexo
          <input name="sexo" maxlength="10" value="<?= e($editando['sexo'] ?? '') ?>" placeholder="Macho / Hembra">
        </label>
        <label>Fecha de nacimiento
          <input name="fecha_nacimiento" type="date" value="<?= e($editando['fecha_nacimiento'] ?? '') ?>">
        </label>
        <label>Fecha de ingreso
          <input name="fecha_ingreso" type="date" value="<?= e($editando['fecha_ingreso'] ?? '') ?>">
        </label>
        <label>Estado de salud
          <input name="estado_salud" maxlength="20" value="<?= e($editando['estado_salud'] ?? '') ?>" placeholder="Sano">
        </label>
        <label>Ubicación
          <input name="ubicacion" maxlength="20" value="<?= e($editando['ubicacion'] ?? '') ?>" placeholder="Jaula 3">
        </label>
        <div class="acciones">
          <button type="submit" class="btn-primary"><?= $editando ? 'Actualizar' : 'Guardar' ?></button>
          <?php if ($editando): ?>
            <a href="index.php" class="btn-secondary">Cancelar edición</a>
          <?php endif; ?>
        </div>
      </form>
    </div>

    <div class="card">
      <h2>Registros</h2>
      <div class="tabla-wrap">
        <table>
          <thead>
            <tr>
              <th>ID</th><th>Nombre</th><th>Tipo</th><th>Sexo</th>
              <th>Nacimiento</th><th>Ingreso</th><th>Salud</th><th>Ubicación</th><th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <?php if (!$animalitos): ?>
              <tr><td colspan="9" style="text-align:center; color:#888;">Sin registros todavía</td></tr>
            <?php endif; ?>
            <?php foreach ($animalitos as $a): ?>
              <tr>
                <td><?= e($a['id_animalito']) ?></td>
                <td><?= e($a['nombre']) ?></td>
                <td><?= e($a['id_tipo_animal']) ?></td>
                <td><?= e($a['sexo']) ?></td>
                <td><?= e($a['fecha_nacimiento']) ?></td>
                <td><?= e($a['fecha_ingreso']) ?></td>
                <td><?= e($a['estado_salud']) ?></td>
                <td><?= e($a['ubicacion']) ?></td>
                <td>
                  <a href="index.php?editar=<?= e($a['id_animalito']) ?>" class="btn-mini btn-edit">Editar</a>
                  <form method="post" action="index.php" style="display:inline"
                        onsubmit="return confirm('¿Borrar el animalito #<?= e($a['id_animalito']) ?>?');">
                    <input type="hidden" name="accion" value="borrar">
                    <input type="hidden" name="id_animalito" value="<?= e($a['id_animalito']) ?>">
                    <button type="submit" class="btn-mini btn-del">Borrar</button>
                  </form>
                </td>
              </tr>
            <?php endforeach; ?>
          </tbody>
        </table>
      </div>
    </div>
  </main>
</body>
</html>
