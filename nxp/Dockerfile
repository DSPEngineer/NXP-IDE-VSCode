###############################################################################
# AUTHOR Jose Pagan <jose.pagan@terex.com >
#   DATE 03/11/2025
#
#
###############################################################################

ARG BASE_IMAGE=ubuntu:22.04
FROM $BASE_IMAGE

ARG BASE_IMAGE
ARG WORKING=workspace
ARG USERNAME=build
ARG UUID=6000
ARG GGID=6000

ENV HOME="/home/${USERNAME}"
ENV USER=${USERNAME}
ENV USERNAME=${USERNAME}


###############################################################################
# [2] Basic linux applications
RUN  apt-get -y update \
  && apt-get install -y --no-install-recommends \
        autoconf \
        autoconf-archive \
        bash-completion \
        black \
        build-essential \
        bzip2 \
        catch2 \
        curl \
        diffutils\ 
        git \
        gpg \
        gpiod \
        iproute2 \
        libgpiod2 \
        libdrm2 \
        libgbm1 \
        libnss3 \
        meld \
        net-tools \
        ssh \
        sudo \
        tar \
        unzip \
        usbutils \
        vim \
        wget \
        x11-apps \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

###############################################################################
# [3] Python
RUN  apt-get -y update \
  && apt-get install -y --no-install-recommends \
        mypy \
        python3 \
        python3-pip \
        python-is-python3 \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

###############################################################################
# [4] Linux editors
RUN  apt-get -y update \
  && apt-get install -y --no-install-recommends \
        emacs \
        nano \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

########################################################################
## [5] To install VSCode: (or code-insiders) directly from Microsoft
RUN  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
  && install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg \
  && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null \
  && rm -f packages.microsoft.gpg \
  && apt update \
  && apt install code -q -y \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


###############################################################################
# [6] NXP Required for IDE
RUN  apt-get -y update \
  && apt-get install -y --no-install-recommends \
     libswt-gtk* \
     whiptail \
     libwebkitgtk-6.0-4 \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

########################################################################
## Install the NXP SDK as a layer,

## Set default arguments for SDK install
ARG FTP_SRV="controls-Precision-7920-Tower"
ARG NXP_SDK_FILE_NAME="MCUXpressoInstaller.deb"
ARG NXP_SDK_FTP_NAME="${NXP_SDK_FILE_NAME}.bin"
ARG NXP_TARGET_DIR="/tmp/NXP-software"

########################################################################
## Needed for unattended CLT install:
## ENV LICENSE_ALREADY_ACCEPTED=Y

## []
RUN  mkdir -p $NXP_TARGET_DIR \
  && cd $NXP_TARGET_DIR \
  && wget -q ftp://$FTP_SRV/$NXP_SDK_FTP_NAME \
  && chmod +x $NXP_SDK_FTP_NAME

########################################################################
## []
RUN  cd $NXP_TARGET_DIR \
  && $NXP_TARGET_DIR/$NXP_SDK_FTP_NAME --noexec --target ./nxp

################################################################################
## This is needed in the personality docker file
################################################################################
# [] create non-root user with given username
# and allow sudo without password
# and setup default users .bashrc
RUN if [ ${UUID} -ne 6000 ]; then \
        groupadd --gid ${GGID} ${USERNAME}; \
        useradd -r --create-home \
            -d ${HOME} \
            -s /bin/bash \
            --uid ${UUID} \
            --gid ${GGID} \
            -c "${USERNAME}" \
            -G users,nogroup,dialout,sudo,adm \
            ${USERNAME}; \
        passwd -d ${USERNAME}; \
        usermod -aG users,nogroup,dialout,sudo ${USERNAME}; \
        mkdir -m777 -p /${WORKING}; \
        ln -s /${WORKING} ${HOME}/${WORKING}; \
        chown -R ${USERNAME}:${USERNAME} ${HOME}/.* ${HOME}/* ; \
    fi

################################################################################
RUN mkdir -p /run/dbus \
    touch system_bus_socket

USER ${USERNAME}

# []
RUN  cd $NXP_TARGET_DIR/nxp \
  && ./install.sh

#RUN  cd ${HOME}/MCUXpressoInstaller \
#  &&  ./MCUXpressoInstaller install --noexec -nosplash --no-sandbox -p "MCUXpresso SDK Developer" segger zephyr-developer

#  && ./MCUXpressoInstaller install --no-sandbox -p "MCUXpresso SDK Developer" segger zephyr-developer

#ENTRYPOINT [ "/usr/bin/bash", "/opt/ros/humble/setup.bash", "tail -f /dev/null" ]
