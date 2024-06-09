# bsapi

WIP

Only local development, testing and deployment is supported at the moment.

Use .env.template to create a .env file with the required environment variables.

Make targets:

```sh
make help
```

to security test a module (function-app in this case):

```sh
make terraform_build
make checkov dir_and_test_id=function-app/examples/base
```
