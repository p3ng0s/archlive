FROM archlinux:latest

RUN pacman -Syy --noconfirm
RUN pacman -Syu --noconfirm
RUN pacman --noconfirm -S fakeroot debugedit sudo dialog rsync patch diffutils \
                        pv make gcc cmake extra-cmake-modules libx11 libxft \
                        libxinerama archiso pkgconf git imlib2 i3lock imagemagick \
                        xautomation cowsay fortune-mod lolcat figlet doge xclip \
                        zathura man java-runtime-common libxss  libxtst libxfixes \
                        libxdamage libxcomposite imake python python-gitpython gtk-doc \
                        gobject-introspection glib2-devel nim nimble base-devel glfw-x11 glu jq git \
                        exfatprogs cryptsetup device-mapper parted dosfstools util-linux sbsigntools

# Fix gtk2 not installed in docker so conquest cannot build -_-
RUN useradd -m builder && \
echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN git clone "https://aur.archlinux.org/gtk2.git" /home/builder/gtk2 && \
    chown -R builder:builder /home/builder/gtk2 && \
    sudo -u builder bash -c "cd /home/builder/gtk2 && makepkg -si --noconfirm"


COPY . /

VOLUME ./out /out/

CMD [ "sh", "/build.sh", "-d" ]
