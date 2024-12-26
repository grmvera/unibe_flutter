# UNIBE App Control

**UNIBE App Control** es una aplicación móvil desarrollada en Flutter, diseñada para el control de acceso en el área de tecnología e innovación de la Universidad Iberoamericana del Ecuador (UNIBE).

## Tabla de Contenidos

- [Introducción](#introducción)
- [Características](#características)
- [Requisitos Previos](#requisitos-previos)
- [Instalación](#instalación)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Uso](#uso)
- [Contribuciones](#contribuciones)
- [Licencia](#licencia)
- [Contacto](#contacto)

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
  flutter pub get
3. Configura Firebase en el proyecto:
  - Crea un nuevo proyecto en Firebase.
  - Descarga el archivo google-services.json (para Android) y/o GoogleService-      Info.plist (para iOS).
  - Coloca estos archivos en los directorios correspondientes (android/app para   Android, ios/Runner para iOS).
4. Ejecuta la aplicación:
  flutter run

## Estructura del Proyecto
La estructura principal del proyecto es la siguiente:
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


## Uso
Administrador:
  - Crear cuentas de estudiantes (masivamente o individualmente).
  - Gestionar ciclos escolares.
  - Habilitar o suspender cuentas de estudiantes.
Estudiantes:
  - Iniciar sesión para visualizar su carné.
  - Escanear códigos QR para registrar accesos.


Aquí tienes todo en formato Markdown listo para que puedas copiar y pegar directamente en tu archivo README.md:

markdown
Copiar código
# UNIBE App Control

**UNIBE App Control** es una aplicación móvil desarrollada en Flutter, diseñada para el control de acceso en el área de tecnología e innovación de la Universidad Iberoamericana del Ecuador (UNIBE).

## Tabla de Contenidos

- [Introducción](#introducción)
- [Características](#características)
- [Requisitos Previos](#requisitos-previos)
- [Instalación](#instalación)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Uso](#uso)
- [Contribuciones](#contribuciones)
- [Licencia](#licencia)
- [Contacto](#contacto)

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
Instala las dependencias del proyecto:

bash
Copiar código
flutter pub get
Configura Firebase en el proyecto:

Crea un nuevo proyecto en Firebase.
Descarga el archivo google-services.json (para Android) y/o GoogleService-Info.plist (para iOS).
Coloca estos archivos en los directorios correspondientes (android/app para Android, ios/Runner para iOS).
Ejecuta la aplicación:

bash
Copiar código
flutter run
Estructura del Proyecto
La estructura principal del proyecto es la siguiente:

bash
Copiar código
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
Uso
Administrador:

Crear cuentas de estudiantes (masivamente o individualmente).
Gestionar ciclos escolares.
Habilitar o suspender cuentas de estudiantes.
Estudiantes:

Iniciar sesión para visualizar su carné.
Escanear códigos QR para registrar accesos.
Contribuciones
Las contribuciones son bienvenidas. Por favor, sigue estos pasos:

Haz un fork del repositorio.
Crea una nueva rama para tu característica/bugfix: git checkout -b feature/nueva-caracteristica.
Haz commit de tus cambios: git commit -m 'Agrega una nueva característica'.
Haz push a la rama: git push origin feature/nueva-caracteristica.
Abre un pull request en este repositorio.

## Contacto
Desarrollador: Geovanny Rodolfo Vera Murillo
Email: geovanny00vera@gmail.com
