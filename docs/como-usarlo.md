# Cómo usarlo

## 1. Configura tus variables

Copia el ejemplo de entorno y rellena los valores reales de tu sistema:

```bash
cp .env.example .env
```

Ejemplo:

```env
# Nombre del usuario dentro del contenedor
USER_NAME=xuser
USER_UID=1000
USER_GID=1000
ADMIN_GID=1001
WORKSPACE_PATH=/volume1/Developer
SSH_KEYS_PATH=/var/services/homes/tu_usuario/.ssh
```

- `USER_NAME`: nombre del usuario dentro del contenedor
- `USER_UID` y `USER_GID`: UID y GID del usuario del host
- `ADMIN_GID`: el grupo dedicado para el acceso a la carpeta de trabajo
- `WORKSPACE_PATH`: la ruta real del proyecto o carpeta compartida
- `SSH_KEYS_PATH`: la ruta donde tienes tus claves SSH del host

> Si este proyecto está dentro de un repositorio, añade `.env` a tu `.gitignore`.
>
> El contenedor solo acepta autenticación SSH mediante clave pública. La clave
> privada debe quedarse en tu equipo cliente y no debe publicarse.

## 2. Crea la clave pública autorizada

Copia el ejemplo:

```bash
cp authorized_keys.example authorized_keys
```

Añade tu clave pública al fichero `authorized_keys`:

```bash
cat ~/.ssh/tu_clave.pub >> authorized_keys
```

Esto permite que el contenedor acepte conexiones SSH autenticadas por clave pública.
La clave privada no debe copiarse al repositorio. Si necesitas hacer `git push`
desde el devbox, móntala en modo solo lectura mediante `SSH_KEYS_PATH`.

## 3. Construye y levanta el contenedor

```bash
docker compose up --build -d
```

Esto crea la imagen, levanta el contenedor y deja el servicio accesible por SSH en el puerto `2222`.

## 4. Conéctate desde VS Code

Desde VS Code:

- abre la paleta de comandos
- elige `Remote-SSH: Connect to Host...`
- añade el host:

```bash
ssh -i ~/.ssh/tu_clave.pem -p 2222 <USER_NAME>@localhost
```

Sustituye `<USER_NAME>` por el valor definido en `.env`, o usa la configuración
SSH correspondiente con `IdentityFile ~/.ssh/tu_clave.pem` si prefieres
conectarte por nombre de host.

## 5. Usa el contenedor como entorno de desarrollo

Una vez conectado, el usuario del contenedor será el definido en `USER_NAME` y tendrás acceso a:

- un entorno Linux moderno
- `git`, `python`, `docker`, `curl`, etc.
- acceso a los archivos del host montados en `WORKSPACE_PATH`
- SSH para clonar repositorios y conectarte a otros servidores

## 6. Rebuilds y mantenimiento

Si cambias el `Dockerfile` o la configuración del entorno:

```bash
docker compose up --build -d
```

Si quieres limpiar volúmenes persistentes y recrearlos desde cero:

```bash
docker compose down -v
```

> Ojo: si borras los volúmenes de SSH, puede que tengas que limpiar `known_hosts` en tu cliente.

## 7. Recomendación

Lo ideal es mantener esta carpeta del proyecto fuera del repositorio principal si contiene secretos locales o rutas específicas del host, y dejar el repositorio de código limpio.

