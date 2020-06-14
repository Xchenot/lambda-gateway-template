# Lambda Gateway Template

This project provides a template to deploy a Lambda attached to its API Gateway deploy with terraform.
It's work with docker.

## Prerequisites

The only tools you need to build this project are :

- Docker Compose
- Makefile support (see GNU Make for windows OS)

## Install

To install the project, just clone it:

``` bash
$ git clone git@github.com:Xchenot/lambda-gateway-template.git
```

## Docker

If you want to manage the Node container, you can use:

``` bash
$ docker-compose run node sh
```

If you want to manage the terraform container, you can use:

``` bash
$ docker-compose run terraform sh
$ terraform init
$ terraform apply
```

## Dependencies


## Testing

If you want to test the Node API, you can use:

``` bash
$ make node-test
```

## Deploying

## Destroying

## Unlocking


## Bash History

## Troubleshooting

```
Calling the invoke API action failed with this message: Lambda was unable to decrypt the environment variables because KMS access was denied. Please check the function's KMS key settings. KMS Exception: UnrecognizedClientExceptionKMS Message: The security token included in the request is invalid.
```
Terraform destroy and apply should resolve it
