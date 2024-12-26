# UNIBE App Control

**UNIBE App Control** es una aplicación móvil desarrollada en Flutter, diseñada para el control de acceso en la Universidad Iberoamericana del Ecuador (UNIBE).

## Tabla de Contenidos

- [Introducción](#introducción)
- [Características](#características)
- [Requisitos Previos](#requisitos-previos)
- [Instalación](#instalación)
- [Uso](#uso)
- [Contacto](#contacto)
- [Estructura del Proyecto](#estructura-del-proyecto)
## Introducción

Este proyecto tiene como objetivo proporcionar un sistema eficiente y moderno para el control de acceso de estudiantes en las instalaciones de la universidad. La aplicación utiliza **Firebase** para la gestión de usuarios y datos, y sigue las mejores prácticas en el desarrollo móvil.

## Características

- **Gestión de usuarios**: Roles para administradores y estudiantes.
- **Gestión de ciclos escolares**: Crear, actualizar y asociar estudiantes a ciclos.
- **Autenticación segura**: Integración con Firebase Authentication.
- **Interfaz de usuario intuitiva**: Diseños estilizados para una experiencia agradable.
- **Funcionalidad de carné virtual**: Muestra un carné con información del estudiante, un código QR y su fotografía.

## Requisitos Previos

Antes de instalar y ejecutar este proyecto, asegúrate de tener lo siguiente:

1. **Flutter SDK** (versión estable más reciente).
2. **Dart SDK** (incluido en Flutter).
3. Un editor de texto compatible (por ejemplo, [Visual Studio Code](https://code.visualstudio.com/) o Android Studio).
4. Una cuenta en [Firebase](https://firebase.google.com/).
5. **Node.js** (si usas Firebase Hosting).

## Instalación

1. Clona este repositorio en tu máquina local:

   ```bash
   git clone https://github.com/tu-usuario/unibe_app_control.git
   cd unibe_app_control
2. Instala las dependencias del proyecto:
   ```bash
   flutter pub get
4. Configura Firebase en el proyecto:
  - Crea un nuevo proyecto en Firebase.
  - Descarga el archivo google-services.json (para Android) y/o GoogleService-      Info.plist (para iOS).
  - Coloca estos archivos en los directorios correspondientes (android/app para   Android, ios/Runner para iOS).
5. Ejecuta la aplicación:
      ```bash
      flutter run
## Uso
Administrador:
  - Crear cuentas de estudiantes (masivamente o individualmente).
  - Gestionar ciclos escolares.
  - Habilitar o suspender cuentas de estudiantes.
    
Estudiantes:
  - Iniciar sesión para visualizar su carné.
  - Escanear códigos QR para registrar accesos.

## Contacto
- Desarrollador: Geovanny Rodolfo Vera Murillo
- Email: geovanny00vera@gmail.com

## Estructura del Proyecto
La estructura principal del proyecto es la siguiente:
   ```bash
unibe_app_control/
│
├── lib/
│   ├── main.dart                 # Punto de entrada de la aplicación
│   ├── screens/                  # Pantallas de la aplicación
│   ├── widgets/                  # Componentes reutilizables
│   ├── models/                   # Modelos de datos
│   ├── services/                 # Lógica de negocio y acceso a Firebase
│   └── utils/                    # Utilidades y constantes
│
├── assets/                       # Recursos gráficos y de texto
├── android/                      # Configuración específica de Android
├── ios/                          # Configuración específica de iOS
├── test/                         # Pruebas unitarias y widget tests
└── pubspec.yaml                  # Configuración del proyecto y dependencias




