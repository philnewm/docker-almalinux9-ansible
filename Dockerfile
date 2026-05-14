FROM quay.io/almalinuxorg/9-init
LABEL maintainer="philnewm"
ENV container="docker"

RUN echo "max_parallel_downloads=20" >> /etc/dnf/dnf.conf

RUN dnf -y update && dnf clean all

# Ensure systemd-logind is not masked
RUN rm -f /etc/systemd/system/systemd-logind.service;

RUN dnf -y install rpm dnf-plugins-core \
    && dnf -y install \
        epel-release \
        initscripts \
        sudo \
        which \
        hostname \
        libyaml \
        python3 \
        python3-pip \
        python3-pyyaml \
        iproute \
        glibc-langpack-en \
    && dnf clean all

RUN echo 'LANG=en_US.UTF-8' > /etc/locale.conf

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN dnf -y install libcurl --allowerasing && dnf clean all
RUN pip3 install --upgrade pip

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Fix shadow file permissions
# Note https://github.com/rocky-linux/sig-cloud-instance-images/issues/56
RUN chmod 0640 /etc/shadow

# Setup ansible user
RUN set -eux; \
    group=$(if command -v yum >/dev/null 2>&1; then echo wheel; else echo sudo; fi); \
    useradd -m -s /bin/bash ansible; \
    usermod -aG "$group" ansible; \
    echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible; \
    chmod 0644 /etc/sudoers.d/ansible

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/sbin/init"]
