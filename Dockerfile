FROM archlinux:latest

RUN pacman -Syu --noconfirm
RUN pacman --noconfirm -S make gcc cmake extra-cmake-modules libx11 libxft libxinerama archiso pkgconf git imlib2

COPY ./archlive/ /archlive/
COPY ./build.sh /

VOLUME ./out /out/

CMD [ "sh", "/build.sh" ]
