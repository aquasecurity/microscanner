# MicroScanner
WORK IN PROGRESS - Scan your container images for vulnerabilities

## Overview
Aqua Security's *microscanner* lets you check your container images for vulnerabilities. If your image has any known high-severity issue, microscanner can fail the image build, making it easy to include as a step in your CI/CD pipeline. 

## Registering for a token
To use microscanner you'll first need to register for a token. 

```
$ docker run --rm -it aquasec/microscanner --register <email address>
```

We'll send a microscanner token to the email address you specify. 

This process will prompt you to agree to the [Terms and Conditions for microscanner]() **TODO!!**.

## Running microscanner 
The microscanner is designed to be run as part of building a container image. You add the microscanner executable into the image, and a step to run the scan, which will examine the contents of the image filesystem for vulnerabilities. If high severity vulnerabilities are found, this will fail the image build (though you can force the scanner to exit with zero by setting the ```--continue-on-failure``` flag).

### Adding microscanner to your Dockerfile
The following lines add microscanner to a Dockerfile, and execute it.

**TODO!! NOTES FOR BETA TESTERS** The latest version of microscanner is not yet in place at https://get.aquasec.com. Instead, you'll need a local copy of the binary, which we will send you (or you can extract from the aquasec/microscanner:latest container image if you prefer). Instead of ```ADD https://get.aquasec.com/microscanner``` use ```COPY microscanner /microscanner```

```
ADD https://get.aquasec.com/microscanner
RUN chmod +x microscanner
RUN microscanner <TOKEN> [--continue-on-failure]
```

### Windows version
There is also a Windows version of the executable, which is added to a Dockerfile in a similar way. **TODO!!** Check this
```
ADD https://get.aquasec.com/microscanner.exe
RUN microscanner.exe <TOKEN> [--continue-on-failure]
```

### Example 
Example Dockerfile

**TODO!! NOTES FOR BETA TESTERS** See note above about using a local copy of the microscanner binary

```
FROM debian:jessie-slim
RUN apt-get update && apt-get -y install ca-certificates
ADD https://get.aquasec.com/microscanner
RUN chmod +x microscanner
ARG token
RUN /microscanner ${token}
RUN echo "No vulnerabilities!"
```
Pass the token obtained on registration in at build time.
```
$ docker build --build-arg=token=<TOKEN> --no-cache .
```
### Continue on failure
Specifying the ```--continue-on-failure``` flag allows you to continue the build even if high severity issues are found. **TODO!!** Are the results logged out as part of the build? 

## Best practices 

* Since the token is a [secret value](https://blog.aquasec.com/managing-secrets-in-docker-containers), it's a good idea to pass this in as a build argument rather than hard-coding it into your Dockerfile. 
* The step that runs microscanner needs to appear in your Dockerfile after you have added or built files and directories for the container image. Build steps happen in the order they are defined in the Dockerfile, so anything that gets added to the image after the microscanner is run won't be scanned for vulnerabilities. 
* The --no-cache option ensures that microcanner is run every time, which is necessary even if your image contents haven't changed in case new vulnerabilities have been discovered. Of course this forces all the steps in the Dockerfile to be re-run, which could slow down your build. To allow for earlier stages to be cached but still ensure that microscanner is run every time you might want to consider a [cache-busting technique such as the one described here](https://github.com/moby/moby/issues/1996#issuecomment-185872769).

**TODO!!** Anything we might want to say about multi-stage builds? E.g. having the scan step as a final stage? 

## Usage limits
Your token will be rate-limited to a reasonable number of scans. Currently this is set to 100 scans per day, though this could change. If you hit rate-limiting issues please do get in touch to discuss your use-case.  

## Supported operating system packages

* Debian >= 7, unstable
* Ubuntu LTS releases >= 12.04
* Red Hat Enterprise Linux >= 5
* CentOS >= 5
* Alpine >= 3.3
* Oracle Linux >= 5
* **TODO!!** Windows

## Issues and feedback
If you come across any problems or would like to give us feedback on MicroScanner we encourage you to raise issues here on GitHub. 

## Community Edition vs Enterprise Edition

The freely-available Community Edition of microscanner scans for vulnerabilities in the image's installed packages. 

Customers of Aqua's commercial Container Security Product have access to additional Enterprise Edition scanning features such as scanning files for vulnerabilities, and scanning for sensitive data included in a container image.  **TODO!!** Check description of Enterprise Edition / commercial version. 
