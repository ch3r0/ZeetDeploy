FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

RUN cd /root && \
    sed -i 's/^#\s*\(deb.*partner\)$/\1/g' /etc/apt/sources.list && \
    sed -i 's/^#\s*\(deb.*restricted\)$/\1/g' /etc/apt/sources.list && \ 
    apt-get update -y && \ 
    apt-get install -yqq locales  && \ 
    apt-get install -yqq \
        mate-desktop-environment-core \
        mate-themes \
        mate-accessibility-profiles \
        mate-applet-appmenu \
        mate-applet-brisk-menu \
        mate-applets \
        mate-applets-common \
        mate-calc \
        mate-calc-common \
        mate-dock-applet \
        mate-hud \
        mate-indicator-applet \
        mate-indicator-applet-common \
        mate-menu \
        mate-notification-daemon \
        mate-notification-daemon-common \
        mate-utils \
        mate-utils-common \
        mate-window-applets-common \
        mate-window-buttons-applet \
        mate-window-menu-applet \
        mate-window-title-applet \
        ubuntu-mate-icon-themes \
        ubuntu-mate-themes \
        tightvncserver \
        pulseaudio && \
    apt-get install --no-install-recommends -yqq \
        supervisor \
        sudo \
        tzdata \
        vim \
        mc \
        ca-certificates \
        chromium \
        xterm \
        curl \
        wget \
        wmctrl \
        epiphany-browser && \
    ln -fs /usr/share/zoneinfo/UTC /etc/localtime && dpkg-reconfigure -f noninteractive tzdata && \
    apt-get -y install \
        git \
        libxfont-dev \
        xserver-xorg-core \
        libx11-dev \
        libxfixes-dev \
        libssl-dev \
        libpam0g-dev \
        libtool \
        libjpeg-dev \
        flex \
        bison \
        gettext \
        autoconf \
        libxml-parser-perl \
        libfuse-dev \
        xsltproc \
        libxrandr-dev \
        python-libxml2 \
        nasm \
        xserver-xorg-dev \
        fuse \
        build-essential \
        pkg-config \
        libpulse-dev m4 intltool dpkg-dev \
        libfdk-aac-dev \
        libopus-dev \
        libmp3lame-dev \
        mplayer \
        screen && \
    git clone -b main https://github.com/rojserbest/VoiceChatPyroBot.git && cd VoiceChatPyroBot && \     
    apt-get update && apt build-dep pulseaudio -y && \
    cd /tmp && apt source pulseaudio && \
    pulsever=$(pulseaudio --version | awk '{print $2}') && cd /tmp/pulseaudio-$pulsever && ./configure \
    && cd /root && \
    #git clone -b master https://github.com/neutrinolabs/xrdp.git && \
    #git clone -b master https://github.com/neutrinolabs/xorgxrdp.git && \
    git clone -b devel https://github.com/neutrinolabs/xrdp.git && \
    git clone -b devel https://github.com/neutrinolabs/xorgxrdp.git && \
    cd /root/xrdp && ./bootstrap && ./configure --enable-fuse --enable-jpeg --enable-vsock --enable-fdkaac --enable-opus --enable-mp3lame --enable-pixman && make && make install && \
    cd /root/xorgxrdp  && ./bootstrap && ./configure && make && make install && \
    cd /root && \
    rm -R /root/xrdp && \
    rm -R /root/xorgxrdp && \
    # bugfix clipboard bug: [xrdp-chansrv] <defunct> && \
    apt-mark manual libfdk-aac1 && \
    apt install pavucontrol && \
    apt-get -y purge \
        libxfont-dev \
        libx11-dev \
        libxfixes-dev \
        libssl-dev \
        libpam0g-dev \
        libtool \
        libjpeg-dev \
        flex \
        bison \
        gettext \
        autoconf \
        libxml-parser-perl \
        libfuse-dev \
        xsltproc \
        libxrandr-dev \
        python-libxml2 \
        nasm \
        xserver-xorg-dev \
        build-essential \
        pkg-config \
        libfdk-aac-dev \
        libopus-dev \
        libmp3lame-dev && \
        #        fuse \
    apt-get -y autoclean && apt-get -y autoremove && \
    apt-get -y purge $(dpkg --get-selections | grep deinstall | sed s/deinstall//g) && \
    rm -rf /var/lib/apt/lists/*  && \
    echo "mate-session" > /etc/skel/.xsession && \
    sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini  && \
    sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini  && \
    sed -i -e '/DisconnectedTimeLimit=/ s/=.*/=0/' /etc/xrdp/sesman.ini && \
    sed -i -e '/IdleTimeLimit=/ s/=.*/=0/' /etc/xrdp/sesman.ini && \
    xrdp-keygen xrdp auto  && \
    mkdir -p /var/run/xrdp && \
    chmod 2775 /var/run/xrdp  && \
    mkdir -p /var/run/xrdp/sockdir && \
    chmod 3777 /var/run/xrdp/sockdir && \
    touch /etc/skel/.Xauthority && \
    mkdir /run/dbus/ && chown messagebus:messagebus /run/dbus/ && \
    #dbus-uuidgen > /etc/machine-id && \
    #ln -sf /var/lib/dbus/machine-id /etc/machine-id && \  
    echo "[program:xrdp-sesman]" > /etc/supervisor/conf.d/xrdp.conf && \
    echo "command=/usr/local/sbin/xrdp-sesman --nodaemon" >> /etc/supervisor/conf.d/xrdp.conf && \
    echo "process_name = xrdp-sesman" >> /etc/supervisor/conf.d/xrdp.conf && \
    echo "[program:xrdp]" >> /etc/supervisor/conf.d/xrdp.conf && \
    echo "command=/usr/local/sbin/xrdp -nodaemon" >> /etc/supervisor/conf.d/xrdp.conf && \
    echo "process_name = xrdp" >> /etc/supervisor/conf.d/xrdp.conf
#RUN     echo "[program:dbus-daemon]" > /etc/supervisor/conf.d/dbus-daemon.conf && \
#    echo "command=/usr/bin/dbus-daemon --system --nofork" >> /etc/supervisor/conf.d/dbus-daemon.conf && \
#    echo "process_name = dbus-daemon" >> /etc/supervisor/conf.d/dbus-daemon.conf && \
#    echo "user = messagebus"  >> /etc/supervisor/conf.d/dbus-daemon.conf

COPY xrdp.ini /etc/xrdp/xrdp.ini

COPY autostartup.sh /root/
CMD ["/bin/bash", "/root/autostartup.sh"]
                                    
EXPOSE 3389 22
