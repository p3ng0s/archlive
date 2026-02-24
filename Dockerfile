FROM archlinux:latest

RUN pacman -Syy --noconfirm
RUN pacman -Syu --noconfirm
RUN pacman --noconfirm -S fakeroot debugedit sudo dialog rsync patch diffutils \
                        pv make gcc cmake extra-cmake-modules libx11 libxft \
                        libxinerama archiso pkgconf git imlib2 i3lock imagemagick \
                        xautomation cowsay fortune-mod lolcat figlet doge xclip \
                        zathura man java-runtime-common libxss  libxtst libxfixes \
                        libxdamage libxcomposite imake python python-gitpython gtk-doc \
                        gobject-introspection
RUN useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY . /

VOLUME ./out /out/

CMD [ "sh", "/build.sh", "-d" ]
