![MicroScanner](microscanner.png)

A free-to-use tool that scans container images for package vulnerabilities.

## Overview
Aqua Security's MicroScanner lets you check your container images for vulnerabilities. If your image has any known high-severity issue, MicroScanner can fail the image build, making it easy to include as a step in your CI/CD pipeline. 

> Note: this freely-available Community Edition enables scanning by adding some lines to your Dockerfile, incorporating the *microscanner* binary as part of the image build. This is aimed at individual developers and open source projects who may not have control over the full CI/CD pipeline. The <a href="https://www.aquasec.com/use-cases/continuous-image-assurance/">Aqua Security commercial solution</a> scans container images without requiring any modification to the image or its Dockerfile, and is designed to be hooked into your CI/CD pipeline after the image build is complete, and/or to scan images from a public or private container registry. 

> Another note: this freely-available Community Edition of MicroScanner scans for vulnerabilities in the image's installed packages. Aqua's commercial customers have access to [additional Enterprise Edition scanning features](#aqua-security-edition-comparison), such as scanning files for vulnerabilities, and scanning for sensitive data included in a container image. 

## Registering for a token
To use MicroScanner you'll first need to register for a token. 

```
$ docker run --rm -it aquasec/microscanner --register <email address>
```

We'll send a token to the email address you specify. 

This process will prompt you to agree to the [Terms and Conditions for MicroScanner](TERMS.md).

## Running *microscanner* 
MicroScanner is designed to be run as part of building a container image. You add the *microscanner* executable into the image, and a step to run the scan, which will examine the contents of the image filesystem for vulnerabilities. If high severity vulnerabilities are found, this will fail the image build (though you can force the scanner to exit with zero by setting the ```--continue-on-failure``` flag).

### Adding *microscanner* to your Dockerfile
The following lines add *microscanner* to a Dockerfile, and execute it.

```
ADD https://get.aquasec.com/microscanner /
RUN chmod +x /microscanner
RUN /microscanner <TOKEN> [--continue-on-failure]
```

### Add ca-certificates if needed
You may also need to add ca-certificates to the image if they are not already build into the parent image, or added in your Dockerfile, so that *microscanner* can make an HTTPS connection. For example (Debian): 

```
RUN apt-get update && apt-get -y install ca-certificates
```

or (Alpine):
```
RUN apk add --no-cache ca-certificates && update-ca-certificates
```

When you build the image, missing CA certificates will result in an error like this: 
```
ERROR: failed fetching server information: request failed: Get https://microscanner.aquasec.com/api: x509: failed to load system roots and no roots provided
```

### Example 
Example Dockerfile

```
FROM debian:jessie-slim
RUN apt-get update && apt-get -y install ca-certificates
ADD https://get.aquasec.com/microscanner /
RUN chmod +x /microscanner
ARG token
RUN /microscanner ${token}
RUN echo "No vulnerabilities!"
```
Pass the token obtained on registration in at build time.
```
$ docker build --build-arg=token=<TOKEN> --no-cache .
```
The output includes JSON output describing any vulnerabilities found in your image.

### Continue on failure
Specifying the ```--continue-on-failure``` flag allows you to continue the build even if high severity issues are found. 

### Remove microscanner from image 
You may choose to remove the *microscanner* executable from the image by changing the RUN line to 

```
RUN /microscanner ${token} && rm /microscanner
```

## Best practices 

* Since the token is a [secret value](https://blog.aquasec.com/managing-secrets-in-docker-containers), it's a good idea to pass this in as a build argument rather than hard-coding it into your Dockerfile. 
* The step that runs *microscanner* needs to appear in your Dockerfile after you have added or built files and directories for the container image. Build steps happen in the order they are defined in the Dockerfile, so anything that gets added to the image after *microscanner* is run won't be scanned for vulnerabilities. 
* The --no-cache option ensures that microcanner is run every time, which is necessary even if your image contents haven't changed in case new vulnerabilities have been discovered. Of course this forces all the steps in the Dockerfile to be re-run, which could slow down your build. To allow for earlier stages to be cached but still ensure that microscanner is run every time you might want to consider a [cache-busting technique such as the one described here](https://github.com/moby/moby/issues/1996#issuecomment-185872769).
* Don't want to build *microscanner* into the image you're deploying? You can create a separate Dockerfile dedicated for vulnerability scanning which starts FROM the image to be scanned, and adds and runs *microscanner*. The build based on this Dockerfile would be used purely for scanning purposes, and based on the output of this separate build you can make decisions on whether to deploy that image. 

## Fair use policy
Your token will be rate-limited to a reasonable number of scans. If you hit rate-limiting issues please do get in touch to discuss your use-case.

## Supported operating system packages

* Debian >= 7, unstable
* Ubuntu LTS releases >= 12.04
* Red Hat Enterprise Linux >= 5
* CentOS >= 5
* Alpine >= 3.3
* Oracle Linux >= 5

## Aqua Security edition comparison

Capability | MicroScanner | [Aqua Pay-Per-Scan](https://aws.amazon.com/marketplace/pp/B075SDHDM1) | [Aqua CSP](https://www.aquasec.com/products/aqua-container-security-platform/) 
-- | --------------- | --------------- | ----------------- 
Pricing model | Free | Per scan | Enterprise license
Embedded in image build | X |   | optional
No Dockerfile changes required |   | X | X
Integration with CI/CD tooling |   | X | X
Registry scan |   | X | X
Package vulnerability scanning | X | X | X 
File vulnerability scanning |   | X | X 
Sensitive data scanning |   | X | X 
Image configuration checks |   | X | X
Malware scanning |   | X | X
OSS license checks |   | X | X
Block untrusted images |   |   | X 
Secrets management |   |   | X 
Runtime protection |   |  | X 
CIS Compliance checks |   |   | X 

## Issues and feedback
If you come across any problems or would like to give us feedback on MicroScanner we encourage you to raise issues here on GitHub. 

## Binary hash
$ md5 microscanner
MD5 (microscanner) = ed68908a0b8afef502ddee96d0bb2915
