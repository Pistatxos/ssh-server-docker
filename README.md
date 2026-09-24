# Devbox SSH en Docker para VS Code Remote-SSH

## Descripción

Este proyecto crea un entorno de desarrollo basado en Docker para usar VS Code
Remote-SSH cuando el sistema anfitrión no es compatible con el runtime que
requiere VS Code Server.

La idea es simple: mantener el host sin tocarlo y mover la parte de desarrollo a
un contenedor moderno con Debian. VS Code se conecta por SSH a ese devbox y
trabaja sobre los archivos reales del host, montados dentro del contenedor.

Esto es útil en sistemas antiguos, NAS, entornos restringidos o infraestructuras
donde no conviene instalar herramientas modernas directamente sobre la base del
servidor.

## ¿Qué resuelve?

- Compatibilidad con VS Code Remote-SSH en hosts viejos o limitados
- Evitar modificar la instalación base del sistema
- Mantener un entorno de desarrollo reproducible
- Trabajar con archivos reales del anfitrión sin duplicarlos
- Usar Docker desde el contenedor cuando la infraestructura lo requiere

## ¿Cómo funciona?

1. El host conserva los archivos del proyecto.
2. Se levanta un contenedor Debian 12 con SSH y herramientas de desarrollo.
3. VS Code se conecta a ese contenedor por SSH.
4. El contenedor monta los directorios del proyecto desde el host.
5. El VS Code Server se ejecuta dentro del devbox, no sobre la base del sistema.

## Estructura del proyecto

```text
.
├── Dockerfile
├── docker-compose.yaml
├── .env.example
├── .gitignore
├── authorized_keys.example
├── docs/
│   ├── como-usarlo.md
│   ├── comprobacion.md
│   └── troubleshooting.md
└── README.md
```

## Documentación

- [Cómo usarlo](docs/como-usarlo.md)
- [Comprobación del entorno](docs/comprobacion.md)
- [Troubleshooting](docs/troubleshooting.md)
