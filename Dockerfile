FROM lambci/lambda:build-python3.7

LABEL description="GFortran & netCDF & FCM Make on Amazon Lambda Environment" \
      maintainer="matthew.shin@metoffice.gov.uk" \
      version="0.1"

# Dependencies for FCM Make.
RUN yum -y update && yum -y install gcc-gfortran glibc-static perl-core
RUN yum -y install libcurl-devel

# Dependencies for netCDF libraries.
# Note: NetCDF libraries on EPEL do not work with modern GFortran,
#       so building from source here.
#RUN yum -y install libcurl-devel make m4 zlib-devel \
#    && yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
#    && yum -y install hdf5 hdf5-devel hdf5-static

# Install FCM Make
WORKDIR /opt
ENV FCM_VN=2019.09.0
RUN curl -L "https://github.com/metomi/fcm/archive/${FCM_VN}.tar.gz" | tar -xz
WORKDIR /usr/local/bin
RUN echo -e '#!/bin/sh'"\n"'exec /opt/fcm-'"${FCM_VN}"'/bin/fcm "$@"' >'fcm' \
    && chmod +x 'fcm'

# Build and install netCDF libraries.
WORKDIR /opt
ENV ZLIB_VN=1.2.11
ENV HDF5_VN=1.10.2
ENV NC_VN=4.6.1
ENV NF_VN=4.4.4
RUN curl -L "http://www.zlib.net/zlib-${ZLIB_VN}.tar.gz" | tar -xz
RUN curl -L "https://www.hdfgroup.org/package/source-gzip-2/?wpdmdl=11810&refresh=5b3b3b8b256791530608523" | tar -xz
RUN curl -L "https://github.com/Unidata/netcdf-c/archive/v${NC_VN}.tar.gz" | tar -xz
RUN curl -L "https://github.com/Unidata/netcdf-fortran/archive/v${NF_VN}.tar.gz" | tar -xz
ENV LOCALDIR=/usr/local
WORKDIR /opt/zlib-${ZLIB_VN}
RUN ./configure --prefix="${LOCALDIR}" && make install
WORKDIR /opt/hdf5-${HDF5_VN}
RUN ./configure --with-zlib="${LOCALDIR}" --prefix="${LOCALDIR}" --enable-hl \
    && make install
WORKDIR /opt/netcdf-c-${NC_VN}
RUN ./configure --prefix="${LOCALDIR}" && make install && nc-config --all
WORKDIR /opt/netcdf-fortran-${NF_VN}
ENV LD_LIBRARY_PATH=${LOCALDIR}/lib
RUN env CPPFLAGS=-I${LOCALDIR}/include LDFLAGS=-L${LOCALDIR}/lib \
    ./configure --prefix="${LOCALDIR}" \
    && make install && nf-config --all

WORKDIR /opt
