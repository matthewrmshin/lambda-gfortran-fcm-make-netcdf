FROM lambci/lambda:build-python3.7 AS base

RUN yum -y update && yum -y install gcc-gfortran libcurl-devel

FROM base AS install-netcdf

# Build and install netCDF libraries.
ENV ZLIB_VN=1.2.11
ENV HDF5_VN=1.10.2
ENV NC_VN=4.6.1
ENV NF_VN=4.4.4
WORKDIR /opt
RUN curl -L "http://www.zlib.net/zlib-${ZLIB_VN}.tar.gz" | tar -xz
RUN curl -L "https://www.hdfgroup.org/package/source-gzip-2/?wpdmdl=11810&refresh=5b3b3b8b256791530608523" | tar -xz
RUN curl -L "https://github.com/Unidata/netcdf-c/archive/v${NC_VN}.tar.gz" | tar -xz
RUN curl -L "https://github.com/Unidata/netcdf-fortran/archive/v${NF_VN}.tar.gz" | tar -xz
WORKDIR /opt/zlib-${ZLIB_VN}
RUN ./configure --prefix=/var/task && make install
WORKDIR /opt/hdf5-${HDF5_VN}
RUN ./configure --with-zlib=/var/task --prefix=/var/task --enable-hl \
    && make install
WORKDIR /opt/netcdf-c-${NC_VN}
RUN env CPATH=/var/task/include LD_LIBRARY_PATH=/var/task/lib \
    CPPFLAGS=-I/var/task/include LDFLAGS=-L/var/task/lib \
    ./configure --prefix=/var/task && make install && /var/task/bin/nc-config --all
WORKDIR /opt/netcdf-fortran-${NF_VN}
RUN env CPATH=/var/task/include LD_LIBRARY_PATH=/var/task/lib \
    CPPFLAGS=-I/var/task/include LDFLAGS=-L/var/task/lib \
    ./configure --prefix=/var/task && make install && /var/task/bin/nf-config --all

FROM base AS install-fcm-make

COPY --from=install-netcdf /var/task /var/task
RUN cp -p \
    /usr/lib64/libgfortran.so.* \
    /usr/lib64/libquadmath.so.* \
    /var/task/lib/

# Dependencies for FCM Make.
RUN yum -y install perl-core

# Install FCM Make
ENV FCM_VN=2019.09.0
WORKDIR /opt
RUN curl -L "https://github.com/metomi/fcm/archive/${FCM_VN}.tar.gz" | tar -xz
RUN ln -s "fcm-${FCM_VN}" '/opt/fcm' \
    && cp -p '/opt/fcm/usr/bin/fcm' '/usr/local/bin/fcm'
CMD bash

LABEL description="Amazon Lambda + GFfortran + FCM Make + netCDF" \
      maintainer="matthew.shin@metoffice.gov.uk" \
      version="1"
