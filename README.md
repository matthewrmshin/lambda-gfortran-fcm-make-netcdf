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

`docker run --rm -t -i -u "$(id -u):$(id -g)" -v "/path/to/source:/opt/myapp" -v "/path/to/package:/tmp/package" 'matthewrmshin/lambda-gfortran-fcm-make-netcdf' -F '/opt/myapp'`

On running the container, it will do:
* Call `fcm make`.
  * Any trailing arguments are given to `fcm make`.
  * Use `docker run -e KEY=VALUE ...` options to define environment variables.
  * The default working directory is under `/tmp/myapp`.
* If `/tmp/package` exists:
  * Copy `/var/task/lib/*.so*` to `/tmp/package/lib/`.
  * Copy `/tmp/myapp/build/{bin,etc,lib}` to `/tmp/package/{bin,etc,lib}`.

To package things up...
* Add a Python module with a lambda handler function to the root of package
  directory. It should do:
  * Invoke `/var/task/bin/...` with `subprocess.run` or otherwise.
  * Turn event + input into input to the Fortran executable.
  * Send output from the Fortran executable to a suitable location.
* Create a zip file with content of the package directory.
* Deploy the package.

The [lambda-jules](https://github.com/matthewrmshin/lambda-jules) repository
contains some example usage.
