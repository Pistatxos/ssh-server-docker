FROM debian:12

# Parámetros de build (llegan desde docker-compose.yaml, que los lee del .env).
# USER_UID/USER_GID deben coincidir con el usuario del host para que los
# ficheros del workspace montado no queden con otro propietario.
# ADMIN_GID: grupo adicional (devbox) al que se añade el usuario de trabajo.
ARG USER_NAME
ARG USER_UID
ARG USER_GID
ARG ADMIN_GID
# UID/GID se exponen también en runtime porque el CMD los necesita para el chown.
ENV USER_UID=${USER_UID}
ENV USER_GID=${USER_GID}
ENV USER_NAME=${USER_NAME}

# Todo en una sola capa para no dejar las listas de apt en capas intermedias.
RUN apt-get update && apt-get install -y --no-install-recommends \
        # Servidor SSH y sudo
        openssh-server sudo \
        # Python con venv y pip
        python3 python3-venv python3-pip \
        # Necesarios para git y para añadir el repo de Docker
        git curl ca-certificates gnupg \
        zoxide \
        # Utilidades varias de terminal
        nano zip unzip tree htop jq wget tmux less iputils-ping \
    # Repo oficial de Docker: solo se instala el cliente (CLI + compose), el
    # daemon es el del host, accesible a través del socket montado.
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" \
        > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/* \
    # Directorio que sshd necesita para arrancar
    && mkdir -p /run/sshd \
    # Crea los grupos solo si el GID no existe ya en la imagen
    && (getent group ${USER_GID} || groupadd -g ${USER_GID} ${USER_NAME}) \
    && (getent group ${ADMIN_GID} || groupadd -g ${ADMIN_GID} devbox) \
    # Usuario de trabajo con el mismo UID/GID que en el host
    && useradd -m -s /bin/bash -u ${USER_UID} -g ${USER_GID} ${USER_NAME} \
    && usermod -aG sudo,${ADMIN_GID} ${USER_NAME} \
    # docker sin contraseña vía sudo (para usar el socket del host)
    && echo "${USER_NAME} ALL=(ALL) NOPASSWD: /usr/bin/docker" > /etc/sudoers.d/${USER_NAME}-docker \
    # ~/.ssh con los permisos que exige sshd
    && mkdir -p /home/${USER_NAME}/.ssh \
    && chmod 700 /home/${USER_NAME}/.ssh \
    && chown -R ${USER_UID}:${USER_GID} /home/${USER_NAME}/.ssh

EXPOSE 22

# Al arrancar (no en build, porque el home es un volumen y taparía lo
# hecho en la imagen):
#   1. Añade la inicialización de zoxide al .bashrc si aún no está.
#   2. Reasigna el propietario del home y .ssh, que el volumen puede traer como root.
#   3. Fuerza autenticación por clave pública, incluso si /etc/ssh procede de
#      un volumen creado antes de este cambio.
#   4. Lanza sshd en primer plano como proceso principal del contenedor.
CMD (grep -q 'zoxide init bash' /home/${USER_NAME}/.bashrc 2>/dev/null || echo 'eval "$(zoxide init bash)"' >> /home/${USER_NAME}/.bashrc); chown ${USER_UID}:${USER_GID} /home/${USER_NAME} && chown ${USER_UID}:${USER_GID} /home/${USER_NAME}/.ssh && sed -ri 's/^[#[:space:]]*PasswordAuthentication[[:space:]].*/PasswordAuthentication no/' /etc/ssh/sshd_config && sed -ri 's/^[#[:space:]]*PubkeyAuthentication[[:space:]].*/PubkeyAuthentication yes/' /etc/ssh/sshd_config && sed -ri 's/^[#[:space:]]*KbdInteractiveAuthentication[[:space:]].*/KbdInteractiveAuthentication no/' /etc/ssh/sshd_config && grep -q '^PasswordAuthentication no$' /etc/ssh/sshd_config || echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config; grep -q '^PubkeyAuthentication yes$' /etc/ssh/sshd_config || echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config; grep -q '^KbdInteractiveAuthentication no$' /etc/ssh/sshd_config || echo 'KbdInteractiveAuthentication no' >> /etc/ssh/sshd_config; exec /usr/sbin/sshd -D
