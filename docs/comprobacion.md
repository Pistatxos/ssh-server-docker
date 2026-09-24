# Comprobación del entorno

Lista de comprobaciones para validar el devbox después del primer arranque o de
un rebuild.

## Usuario y grupos

Desde el devbox:

```bash
whoami
id <USER_NAME>
```

Sustituye `<USER_NAME>` por el valor definido en `.env`. Debe aparecer ese
usuario y el grupo dedicado configurado en `ADMIN_GID`.

## Acceso a los archivos del host

Crea un archivo de prueba dentro de la ruta montada:

```bash
touch /ruta/del/proyecto/prueba-devbox.txt
```

Comprueba desde el host que el archivo existe y bórralo después:

```bash
rm /ruta/del/proyecto/prueba-devbox.txt
```

## Conexión desde VS Code

Comprueba que puedes conectarte mediante `Remote-SSH` y abrir el proyecto desde
la ruta real que está montada en el host.

El VS Code Server debe instalarse dentro del contenedor, sin errores de
compatibilidad con `glibc` o `libstdc++`.

## Python

Dentro de un proyecto Python:

```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -c "print('ok')"
```

En VS Code, selecciona `.venv` como intérprete y verifica que puedes ejecutar y
depurar el proyecto.

## Docker

Desde el devbox:

```bash
sudo docker ps
sudo docker compose version
```

`docker ps` debe mostrar los contenedores reales del host. `sudo` puede ser
necesario porque el socket de Docker pertenece a `root`.

## Git por SSH

Si has montado las claves SSH del host, comprueba la autenticación contra tu
servidor Git:

```bash
ssh -T git@github.com
```

Adapta el dominio al proveedor que uses. El comando debe autenticar con la
identidad esperada.

## Persistencia

Reinicia el contenedor desde el host:

```bash
docker compose restart
```

Después, vuelve a conectarte por SSH y comprueba que se mantienen el usuario,
los archivos y la configuración. La huella SSH tampoco debería cambiar mientras
no se borre el volumen `etc-ssh`.
