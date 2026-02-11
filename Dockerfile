FROM archlinux:latest

RUN pacman -Syu --noconfirm
RUN pacman --noconfirm -S rsync patch diffutils make gcc cmake extra-cmake-modules libx11 libxft libxinerama archiso pkgconf git imlib2

COPY . /

VOLUME ./out /out/

CMD [ "sh", "/build.sh" ]
