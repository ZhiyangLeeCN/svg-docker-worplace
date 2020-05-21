FROM golang:1.14.2

# Ignore APT warnings about not having a TTY
ENV DEBIAN_FRONTEND noninteractive

# install build essentials
RUN apt-get update && \
    apt-get install -y wget build-essential pkg-config --no-install-recommends

# Install ImageMagick deps
RUN apt-get -q -y install libjpeg-dev libpng-dev libtiff-dev libxml2 libwebp-dev librsvg2-bin zip unzip\
    libgif-dev libx11-dev libltdl-dev libtool-bin ocl-icd-opencl-dev libfreetype6 --no-install-recommends

ENV IMAGEMAGICK_VERSION=7.0.10-13

ENV POTRACE_VERSION=1.16

ENV FREETYPE_VERSION=2.10.2

RUN cd && \
    wget https://nchc.dl.sourceforge.net/project/freetype/freetype2/${FREETYPE_VERSION}/freetype-${FREETYPE_VERSION}.tar.gz && \
    tar xvzf freetype-${FREETYPE_VERSION}.tar.gz && \
    cd freetype-${FREETYPE_VERSION} && \
    ./configure && \
    make && make install && \
    ldconfig /usr/local/lib

RUN cd && \
	wget https://github.com/ImageMagick/ImageMagick/archive/${IMAGEMAGICK_VERSION}.tar.gz && \
	tar xvzf ${IMAGEMAGICK_VERSION}.tar.gz && \
	cd ImageMagick* && \
	./configure \
	    --disable-opencl \
	    --disable-silent-rules \
	    --without-magick-plus-plus \
	    --with-freetype=yes \
	    --enable-shared \
	    --with-rsvg=yes \
	    --with-jpeg=yes \
        --with-png=yes \
	    --enable-static \
	    --with-modules=yes \
	    --enable-openmp \
	    --without-perl \
	    --with-modules \
        --with-webp=yes \
        --with-openjp2=yes \
        --with-openexr=yes \
        --with-librsvg=yes \
        --with-heic=yes \
	    --with-fontpath \
	    --disable-docs \
#	    ac_cv_prog_c_openmp=-Xpreprocessor\ -fopenmp \
#	    ac_cv_prog_cxx_openmp=-Xpreprocessor\ -fopenmp \
#	    LDFLAGS=-lomp \
	    && make -j$(nproc) && make install && \
	ldconfig /usr/local/lib

RUN cd && \
	wget  https://downloads.sourceforge.net/potrace/potrace-${POTRACE_VERSION}.tar.gz && \
	tar xvzf potrace-${POTRACE_VERSION}.tar.gz && \
	cd potrace* && \
	./configure --prefix=/usr \
                --disable-static \
                --docdir=/usr/share/doc/potrace-1.16 \
                --enable-a4 \
                --enable-metric \
                --with-libpotrace && \
    make && make install && \
	ldconfig /usr/local/lib

# Install potrace to transform png to svg
#RUN apt-get -q -y install potrace

# mini size
RUN apt-get clean autoclean \
	&& apt-get autoremove --yes \
	&& rm -rf /var/lib/{apt,dpkg,cache,log}/



RUN go get github.com/allegro/bigcache
RUN go get github.com/astaxie/beego/orm
RUN go get github.com/go-sql-driver/mysql
RUN go get github.com/ghodss/yaml
RUN go get github.com/json-iterator/go
RUN go get gopkg.in/gographics/imagick.v3/imagick
#RUN go get github.com/gobuffalo/packr/v2
RUN go get github.com/gobuffalo/packr
RUN go get github.com/gobuffalo/packd
RUN go get github.com/sirupsen/logrus
RUN go get github.com/gobuffalo/logger
RUN go get github.com/karrick/godirwalk
RUN go get github.com/gobuffalo/envy
RUN go get github.com/google/uuid
RUN go get github.com/pkg/errors
RUN go get github.com/nats-io/nats.go
RUN go get github.com/go-redis/redis
RUN go get github.com/esap/wechat

RUN go get github.com/markbates/pkger/cmd/pkger
RUN go get github.com/markbates/safe
RUN go get github.com/markbates/errx
RUN go get github.com/markbates/oncer

RUN go get -u github.com/gin-gonic/gin
RUN go get github.com/gorilla/websocket
RUN go get github.com/ipipdotnet/ipdb-go

VOLUME /go/build/
