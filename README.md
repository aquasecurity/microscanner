# microscanner
WORK IN PROGRESS - Scan your container images for vulnerabilities

## Overview
Aqua Security's *microscanner* lets you check your container images for vulnerabilities. If your image (including any of its dependencies) has any known high-severity issue, microscanner can fail the image build, making it easy to include as a step in your CI/CD pipeline. 

## Registering for a token
To use microscanner you'll first need to register for a token. 

**TODO!!** Either: 
* builds for Mac & Windows as well as Linux so people can run locally to do the registration
* or a containerized version for them to run for this step.
Either way, get the instructions up to date here

```
$ microscanner --register
```

This will prompt you for your email address, and we'll send a microscanner token to that email address. 

By submitting your email address through the registration process you are agreeing to the [Terms and Conditions for microscanner]() **TODO!!**.

## Running microscanner 
The microscanner is designed to be run as part of building a container image. You add the microscanner executable into the image, and a step to run the scan, which will examine the contents of the image filesystem for vulnerabilities. If high severity vulnerabilities are found, this will fail the image build (though you can force the scanner to exit with zero by setting the ```--continue-on-failure``` flag).

### Adding microscanner to your Dockerfile
The following lines add microscanner to a Dockerfile, and execute it.
```
ADD https://get.aquasec.com/microscanner
RUN microscanner <TOKEN> [--continue-on-failure]
```

**TODO!!** Decide whether it's called microscanner-ce or microscanner 

### Example 
Example Dockerfile
```
FROM debian:jessie-slim
RUN apt-get update && apt-get -y install ca-certificates
ADD https://get.aquasec.com/microscanner
ARG token
RUN /microscanner ${token}
RUN echo "No vulnerabilities!"
```
Pass the token obtained on registration in at build time.
```
$ docker build --build-arg=token=<TOKEN> .
```
### Continue on failure
Specifying the ```--continue-on-failure``` flag allows you to continue the build even if high severity issues are found. **TODO!!** Are the results logged out as part of the build? 

## Best practices 

* Since the token is a [secret value](https://blog.aquasec.com/managing-secrets-in-docker-containers), it's a good idea to pass this in as a build argument rather than hard-coding it into your Dockerfile. 
* The step that runs microscanner needs to appear in your Dockerfile after you have added or built files and directories for the container image. Build steps happen in the order they are defined in the Dockerfile, so anything that gets added to the image after the microscanner is run won't be scanned for vulnerabilities. 

**TODO!!** Anything we might want to say about multi-stage builds? E.g. having the scan step as a final stage? 

## Usage limits
Your token will be rate-limited to a reasonable number of scans. Currently this is set to 100 scans per day, though this could change. If you hit rate-limiting issues please do get in touch to discuss your use-case.  

