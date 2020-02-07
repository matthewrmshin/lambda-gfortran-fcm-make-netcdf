<p>
  <a href="https://github.com/matthewrmshin/lambda-gfortran-fcm-make-netcdf/actions"><img alt="GitHub Actions status" src="https://github.com/matthewrmshin/lambda-gfortran-fcm-make-netcdf/workflows/Docker%20Image%20CI/badge.svg"></a>
</p>


# lambda-gfortran-fcm-make-netcdf

Dockerfile based on [AWS Lambda](https://hub.docker.com/r/lambci/lambda/)
Python 3.8 runtime Environment with:
* [GFortran](https://gcc.gnu.org/wiki/GFortran)
* [FCM Make](https://github.com/metomi/fcm/) - the Fortran build system
* [netCDF](https://www.unidata.ucar.edu/software/netcdf/)

The aim is to provide an easy way to use FCM Make and GFortran to build a
Fortran executable that has a dependency on the netCDF library.

The shared libraries are placed under `/var/task/`, which can then be extracted
easily to be part of a lambda package.

The container is currently based on the Python 3.8 lambda runtime, so the
Fortran executable is expected to run as a subprocess invoked by a Python
lambda handler function.

## Usage

Get the image from Docker Hub:

`docker pull matthewrmshin/lambda-gfortran-fcm-make-netcdf`

Use the image to run `fcm make` to build the Fortran source tree in the current
working directory:

`docker run --rm -t -i -u "$(id -u):$(id -g)" -v "$PWD:/tmp/myapp" 'matthewrmshin/lambda-gfortran-fcm-make-netcdf' fcm make`

Note: The working directory is `/tmp/myapp`. The executables should be located
under `./build/bin/`.

To package things up...
* (Hopefully, a more automated way will follow.)
* Create a new directory. Change directory to it.
  E.g. `mkdir 'package'; pushd 'package'`.
* Copy the shared libraries out of the docker image into `./lib/`.
  E.g. `mkdir 'lib'; docker run --rm -t -i -v "$PWD:/tmp/package" 'matthewrmshin/lambda-gfortran-fcm-make-netcdf' cp -r '/var/task/lib' '/tmp/package/'`.
* Copy the executable files to `./bin/`. E.g. `mkdir bin; cp -p ../build/bin/* bin/`.
* Add some runtime configuration, e.g. namelists to the package if appropriate.
* Add a Python module with a lambda handler function. It should do:
  * Invoke `/var/task/bin/...` with `subprocess.run` or otherwise.
  * Turn event + input into input to the Fortran executable.
  * Send output from the Fortran executable to a suitable location.
  * (Example to follow.)
* Review the content. Remove anything unnecessary.
* Create a zip file with content of the current directory.
* Deploy the package.

The [lambda-jules](https://github.com/matthewrmshin/lambda-jules) repository
contains some example usage.
