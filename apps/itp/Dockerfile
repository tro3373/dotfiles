ARG img_name
ARG img_ver
FROM $img_name:$img_ver

# =====================================================================
# Workaround for pip install open-interpreter
#   ERROR:  Could not build wheels for tiktoken,
#           which is required to install pyproject.toml-based projects
#
RUN apt update && \
      apt install -y curl build-essential gcc make && \
      apt clean && \
      rm -rf /var/lib/apt/lists/*
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
ENV TZ=Asia/Tokyo
# =====================================================================

RUN pip install --upgrade pip
RUN pip install open-interpreter

# ARG docker_username=docker_user
# ARG docker_groupname=docker_user
# ARG docker_uid=1000
# ARG docker_gid=1000
# RUN groupadd -g $docker_gid $docker_groupname && \
#     useradd -m -s /bin/bash -u $docker_uid -g $docker_gid $docker_username && \
#     sed -i -e "s,^#alias l,alias l,g" /home/$docker_username/.bashrc
# USER $docker_username

WORKDIR /root
ENTRYPOINT ["interpreter"]
# CMD ["tail", "-f", "/dev/null"]
