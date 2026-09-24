# Troubleshooting

Problemas habituales durante la puesta a punto y el uso del devbox.

| Síntoma o error | Causa habitual | Solución |
|---|---|---|
| `glibc` / `libstdc++` demasiado antiguos | El host no cumple los requisitos del VS Code Server. | Conectar al contenedor Debian 12 mediante Remote-SSH y mantener el sistema base sin modificar. |
| `chown: invalid group` | El GID ya existe en Debian con otro nombre. | Usar los identificadores numéricos `UID:GID`. |
| `Permission denied (publickey,password)` | La clave no está autorizada o `.ssh` / `authorized_keys` tiene propietario o permisos incorrectos. | Verificar la clave pública, el propietario, `~/.ssh` con permisos `700` y `authorized_keys` con permisos `600`. |
| No se puede leer o escribir la carpeta del host | UID/GID o ACL del host no permiten el acceso. | Comprobar que coinciden el UID/GID y que el grupo dedicado tiene acceso recursivo a la carpeta. |
| La clave de host remoto ha cambiado | Se regeneraron las claves SSH del contenedor. | Mantener `/etc/ssh` en un volumen persistente. Si se borró el volumen, limpiar `known_hosts` y aceptar la nueva clave. |
| VS Code no instala el servidor remoto | `RemoteCommand` en `~/.ssh/config` o permisos incorrectos en el home del usuario. | Quitar `RemoteCommand` y comprobar `User`, `Port`, `IdentityFile` y los permisos del home. |
| `permission denied while trying to connect to the docker API` | El socket de Docker pertenece a `root`. | Usar `sudo docker ...` y mantener la regla `NOPASSWD` del contenedor. |
| El acceso al Docker del host supone un riesgo excesivo | `/var/run/docker.sock` permite controlar el daemon Docker del host. | No expongas el devbox fuera de una red de confianza y elimina ese montaje si no necesitas administrar Docker desde el contenedor. |
| No aparecen los contenedores del proyecto | El proyecto se abrió desde una ruta distinta a la montada en el host. | Montar la ruta real y abrir el proyecto desde esa misma ruta. |
| `git push` falla porque no hay identidad SSH | `authorized_keys` solo permite entrar al devbox; no sirve para autenticarse contra Git. | Montar las claves SSH del host en modo solo lectura. |
| Los cambios en `.bashrc` o el home no aparecen tras un rebuild | El volumen `home-user` conserva el contenido anterior. | Aplicar los cambios en el `CMD` o recrear el volumen si se desea empezar de cero. |
| El contenedor conserva configuraciones antiguas | Se están reutilizando los volúmenes persistentes. | Revisar `home-user` y `etc-ssh`; usar `docker compose down -v` solo si se quieren borrar. |

Para comprobar que el entorno funciona correctamente, consulta la [lista de
verificación](comprobacion.md).
