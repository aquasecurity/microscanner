# MicroScanner is now retired in favour of Trivy

Now that you can [embed Trivy in a Dockerfile](https://github.com/aquasecurity/trivy#embed-in-dockerfile), we recommend using our open source scanner [Trivy](https://github.com/aquasecurity/trivy) for vulnerability scanning your container images, as well as filesystems and source code repositories.

This [video](https://youtu.be/cCJhN9nl1NY) explains more about replacing MicroScanner with Trivy. 

[![Replacing MicroScanner with Trivy](http://i3.ytimg.com/vi/cCJhN9nl1NY/hqdefault.jpg)](https://youtu.be/cCJhN9nl1NY "Replacing MicroScanner with Trivy")

---

![MicroScanner](microscanner.png)

[![Build Status](https://travis-ci.org/aquasecurity/microscanner.svg?branch=master)](https://travis-ci.org/aquasecurity/microscanner)
[![Docker image](https://images.microbadger.com/badges/version/aquasec/microscanner.svg)](https://microbadger.com/images/aquasec/microscanner "Get your own version badge on microbadger.com")

A free-to-use tool that scans container images for package vulnerabilities. **Retired** please use Trivy instead, as described at the top of this README.

Table of Contents
=================

* [Overview](#overview)
* [Registering for a token](#registering-for-a-token)
* [Running <em>microscanner</em>](#running-microscanner)
    * [Adding <em>microscanner</em> to your Dockerfile](#adding-microscanner-to-your-dockerfile)
    * [Add ca-certificates if needed](#add-ca-certificates-if-needed)
    * [Example](#example)
    * [Continue on failure](#continue-on-failure)
    * [No verify](#no-verify)
    * [HTML](#html)
    * [Remove microscanner from image](#remove-microscanner-from-image)
    * [One-liner](#one-liner)
    * [Scan an existing image](#scan-an-existing-image)
* [Best practices](#best-practices)
* [Fair use policy](#fair-use-policy)
* [Supported operating system packages](#supported-operating-system-packages)
* [Issues and feedback](#issues-and-feedback)
* [Binary hash](#binary-hash)

## Overview
Aqua Security's MicroScanner lets you check your container images for vulnerabilities. If your image has any known high-severity issue, MicroScanner can fail the image build, making it easy to include as a step in your CI/CD pipeline.

- If you're using Jenkins, you can find the plug-in for MicroScanner [here](https://github.com/jenkinsci/aqua-microscanner-plugin).
- CircleCi users can use the Orb located [here.](https://github.com/aquasecurity/circleci-orb-microscanner)

> Note: This freely-available Community Edition enables scanning by adding some lines to your Dockerfile, incorporating the *microscanner* binary as part of the image build. This is aimed at individual developers and open source projects who may not have control over the full CI/CD pipeline. The <a href="https://www.aquasec.com/use-cases/continuous-image-assurance/">Aqua Security commercial solution</a> scans container images without requiring any modification to the image or its Dockerfile, and is designed to be hooked into your CI/CD pipeline after the image build is complete, and/or to scan images from a public or private container registry.

> Another note: This freely-available Community Edition of MicroScanner scans for vulnerabilities in the image's installed packages. Aqua's commercial customers have access to [additional Enterprise Edition scanning features](#aqua-security-edition-comparison), such as scanning files for vulnerabilities, and scanning for sensitive data included in a container image.

## Registering for a token
To use MicroScanner you'll first need to register for a token. *Since MicroScanner is now deprecated, no new tokens are being issued.* 

```
$ docker run --rm -it aquasec/microscanner --register <email address>
```
Or get a token by registering here https://microscanner.aquasec.com/signup

We'll send you a token to the email address you specify.

This process will prompt you to agree to the [Terms and Conditions for MicroScanner](TERMS.md).

## Running *microscanner*
MicroScanner is designed to be run as part of building a container image. You add the *microscanner* executable into the image, and a step to run the scan, which will examine the contents of the image filesystem for vulnerabilities. If high severity vulnerabilities are found, this will fail the image build (though you can force the scanner to exit with zero by setting the ```--continue-on-failure``` flag).

### Adding *microscanner* to your Dockerfile
The following lines add *microscanner* to a Dockerfile, and execute it.

```dockerfile
ADD https://get.aquasec.com/microscanner /
RUN chmod +x /microscanner
RUN /microscanner <TOKEN> [--continue-on-failure]
```

### Add ca-certificates if needed
You may also need to add ca-certificates to the image if they are not already built into the parent image, or added in your Dockerfile, so that *microscanner* can make an HTTPS connection. For example (Debian):

```dockerfile
RUN apt-get update && apt-get -y install ca-certificates
```

or (Alpine):
```dockerfile
RUN apk add --no-cache ca-certificates && update-ca-certificates
```

When you build the image, missing CA certificates will result in an error like this:
```
ERROR: failed fetching server information: request failed: Get https://microscanner.aquasec.com/api: x509: failed to load system roots and no roots provided
```

### Example
Example Dockerfile

```dockerfile
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

### No verify
Specifying the ```--no-verify``` flag allows you to continue the build even if CA certificates are not installed.

### HTML
Specifying the ```--html``` flag provides output in HTML format.

### Remove microscanner from image
You may choose to remove the *microscanner* executable from the image by changing the RUN line to

```dockerfile
RUN /microscanner ${token} && rm /microscanner
```
### One-liner
The following line installs, runs, and cleans up *microscanner* in one layer so that it doesn't add to the size of the final image.
```dockerfile
RUN apk add --no-cache ca-certificates && update-ca-certificates && \
    wget -O /microscanner https://get.aquasec.com/microscanner && \
    chmod +x /microscanner && \
    /microscanner <token> && \
    rm -rf /microscanner
```
(If you need the ca-certificates in the image for other purposes, you may want to leave that as a separate step in the Dockerfile.)

### Scan an existing image
[microscanner-wrapper](https://github.com/lukebond/microscanner-wrapper) makes it easy to use MicroScanner to scan existing images.

It works by creating a new temporary Dockerfile dedicated to vulnerability scanning which starts FROM the image to be scanned, and adds and runs *microscanner*. This is used to build a temporary image which can then be discarded. Based on the output you can make decisions on whether to deploy the image.

This approach also has the advantage that the *microscanner* executable doesn't need to be built into the image you eventually deploy.

## Best practices

* Since the token is a [secret value](https://blog.aquasec.com/managing-secrets-in-docker-containers), it's a good idea to pass this in as a build argument rather than hard-coding it into your Dockerfile.
* The step that runs *microscanner* needs to appear in your Dockerfile after you have added or built files and directories for the container image. Build steps happen in the order they are defined in the Dockerfile, so anything that gets added to the image after *microscanner* is run won't be scanned for vulnerabilities.
* The `--no-cache` option ensures that *microscanner* is run every time, which is necessary even if your image contents haven't changed in case new vulnerabilities have been discovered. Of course this forces all the steps in the Dockerfile to be re-run, which could slow down your build. To allow for earlier stages to be cached but still ensure that *microscanner* is run every time you might want to consider a [cache-busting technique such as the one described here](https://github.com/moby/moby/issues/1996#issuecomment-185872769).

## Fair use policy
Your token will be rate-limited to a reasonable number of scans. If you hit rate-limiting issues please do get in touch to discuss your use-case.

## Supported operating system packages

* Debian >= 7, unstable
* Ubuntu LTS releases >= 12.04
* Red Hat Enterprise Linux >= 5
* CentOS >= 5
* Alpine >= 3.3
* Oracle Linux >= 5

## Issues and feedback
MicroScanner is now deprecated. If you have any issues replacing MicroScanner with Trivy, please raise those as issues on the [Trivy repository](https://github.com/aquasecurity/trivy/issues).

## Binary hash
```sh
$ sha256sum microscanner
8e01415d364a4173c9917832c2e64485d93ac712a18611ed5099b75b6f44e3a5  microscanner
```
