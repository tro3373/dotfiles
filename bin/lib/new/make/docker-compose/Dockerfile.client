ARG img_name
ARG img_ver
FROM $img_name:$img_ver

ARG docker_username=docker_user
ARG docker_groupname=docker_user
ARG docker_uid=1000
ARG docker_gid=1000
RUN groupadd -g $docker_gid $docker_groupname && \
    useradd -m -s /bin/bash -u $docker_uid -g $docker_gid $docker_username
USER $docker_username
WORKDIR /app
