<h1 align="center">El Pistón - Gestión de Taller</h1>

<p align="center">
  Proyecto práctico para la asignatura <b>Programación para Dispositivos Móviles</b> (Ingeniería Informática, 3er año).
</p>

---

<h2>Descripción</h2>
<p><b>El Pistón</b> es una aplicación móvil desarrollada en Flutter para la gestión integral de un taller mecánico. Permite al personal administrativo registrar clientes, gestionar vehículos, asignar mecánicos, administrar el inventario de repuestos y llevar un control detallado de las órdenes de servicio, incluyendo los trabajos realizados, los repuestos usados, los pagos parciales y la facturación diaria. Toda la información se almacena localmente en el dispositivo, garantizando su disponibilidad sin necesidad de conexión a internet.</p>

<h2>Tecnologías y Arquitectura</h2>
<ul>
  <li><b>Flutter</b>: Framework de desarrollo para la interfaz de usuario.</li>
  <li><b>Drift (SQLite)</b>: Base de datos local para la persistencia de datos.</li>
  <li><b>Material 3</b>: Sistema de diseño para una interfaz moderna y adaptable.</li>
  <li><b>Capa de persistencia con SQL explícito</b>: Para la gestión de datos se utilizó Drift, implementando las consultas SQL de forma directa en el repositorio en lugar de recurrir a la generación automática de código. Esta decisión de diseño mantiene la lógica de la base de datos centralizada, transparente y fácilmente auditable, permitiendo un control preciso sobre cada operación y una estructura de proyecto más ligera y cohesionada.</li>
</ul>

<h2>Requisitos e Instalación</h2>

<h3>Versión de Flutter</h3>
<p>El proyecto fue desarrollado utilizando <b>Flutter 3.47.7</b> (Dart 3.13.5) y el <b>Android SDK</b> configurado por defecto.</p>

<h3>Application ID</h3>
<p>El identificador de la aplicación es: <br>
<code>com.yosbielalejandro.piston</code></p>

<h3>Cómo inicializar y ejecutar el proyecto</h3>
<ol>
  <li>Clona el repositorio: <br><code>git clone https://github.com/Yosbiel/El-Piston-App.git</code></li>
  <li>Accede al directorio: <br><code>cd El-Piston-App</code></li>
  <li>Obtén las dependencias: <br><code>flutter pub get</code></li>
  <li>Ejecuta la app en un emulador o dispositivo físico: <br><code>flutter run</code></li>
</ol>

<h3>Cómo generar el APK en modo Release</h3>
<p>Para generar el archivo instalable, ejecuta:</p>
<pre><code>flutter build apk --release</code></pre>
<p>El APK se generará en la ruta: <br>
<code>build/app/outputs/flutter-apk/app-release.apk</code></p>

<h2>Estructura de Carpetas</h2>
<p>El código está organizado manteniendo la separación de responsabilidades:</p>
<ul>
  <li><code>lib/data/</code>: Configuración de la base de datos (<code>database.dart</code>) y el repositorio con toda la lógica de negocio y consultas SQL (<code>repositorio.dart</code>).</li>
  <li><code>lib/models/</code>: Clases de datos (<code>Cliente</code>, <code>Vehiculo</code>, <code>Mecanico</code>, <code>Orden</code>, <code>Trabajo</code>, <code>Repuesto</code>) con sus métodos <code>fromMap</code> y <code>toMap</code>.</li>
  <li><code>lib/views/</code>: Pantallas de la interfaz de usuario (Órdenes, Clientes, Vehículos, Repuestos, Mecánicos, Reportes, Detalle de Orden).</li>
  <li><code>lib/widgets/</code>: Widgets reutilizables (animaciones personalizadas, icono del menú asimétrico).</li>
  <li><code>lib/utils/</code>: Utilidades compartidas (función para mostrar los toasts).</li>
</ul>

<h2>Funcionalidades Principales</h2>
<ul>
  <li><b>Gestión de Clientes:</b> Alta, edición, eliminación y búsqueda por nombre o teléfono (ignorando mayúsculas y acentos).</li>
  <li><b>Gestión de Vehículos:</b> Alta, edición y eliminación. Asociados a un cliente. Incluye un dropdown con marcas predefinidas y opción de "Otra marca...". Validación del año (entre 1900 y el año actual).</li>
  <li><b>Gestión de Mecánicos:</b> Alta, edición y eliminación. Incluye un campo de "Rol / Especialidad" con dropdown y opción de "Añadir nueva función...".</li>
  <li><b>Gestión de Repuestos:</b> Alta, edición y eliminación. Búsqueda por nombre o código. Alerta visual (rojo) cuando el stock es menor a 5 unidades.</li>
  <li><b>Órdenes de Servicio:</b> Alta con dropdowns de vehículo y mecánico. Cambio de estado desde el detalle (recibida, en diagnóstico, en reparación, lista, entregada, cancelada). Una vez cerrada (entregada o cancelada), no se puede modificar.</li>
  <li><b>Detalle de Orden:</b> Permite agregar trabajos (mano de obra), usar repuestos (descuenta stock automáticamente) y registrar pagos parciales. Calcula el total, lo pagado y el saldo pendiente en tiempo real.</li>
  <li><b>Reportes:</b> Facturación del día (solo de órdenes entregadas) y carga de trabajo por mecánico.</li>
  <li><b>Integridad referencial:</b> No se puede eliminar ni editar un cliente, vehículo o mecánico si tiene órdenes activas. No se puede eliminar un repuesto si se ha usado en alguna orden.</li>
</ul>

<h2>Decisiones de Diseño</h2>
<ul>
  <li><b>Interfaz y Colores:</b> Se eligió una paleta basada en un naranja industrial (<code>#E65100</code>) para evocar la temática del taller mecánico, junto con una tipografía moderna (Poppins) para mejorar la legibilidad.</li>
  <li><b>Experiencia de Usuario (UX):</b> Se implementaron animaciones sutiles de entrada (fade in y slide up) al cargar las listas, una animación de escala en el botón de agregar y un icono de menú asimétrico para un toque moderno. Los diálogos tienen un ancho fijo y son scrollables para evitar roturas al girar el dispositivo o abrir el teclado.</li>
  <li><b>Validaciones:</b> Se implementaron validaciones en tiempo real para evitar duplicados (teléfonos, matrículas, códigos de repuestos), verificar la longitud de los campos, el formato numérico y los rangos de año.</li>
  <li><b>Persistencia del Tema:</b> El modo claro/oscuro se guarda en la base de datos, de modo que la preferencia del usuario se mantiene incluso después de cerrar la aplicación.</li>
  <li><b>Listas Largas:</b> En la pantalla de órdenes, los problemas reportados que exceden las dos líneas se muestran con un botón de "...Leer más" que permite expandir el texto sin romper la estética de la lista.</li>
  <li><b>Búsqueda:</b> Todas las listas principales (clientes, vehículos, repuestos y órdenes) cuentan con una barra de búsqueda que filtra los resultados en tiempo real.</li>
</ul>

<h2>Capturas de Pantalla</h2>
<p>Las capturas reales de la aplicación en funcionamiento (modo claro y oscuro, formularios con validaciones, listados, detalle de orden, reportes, menú lateral, etc.) se encuentran en la carpeta <a href="capturas/">capturas/</a>.</p>

---

<p align="center"><i>Desarrollado por Yosbiel Alejandro Díaz Cala.</i></p>
