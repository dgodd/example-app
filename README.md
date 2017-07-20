## Example App

This is a small application to test vendoring dependencies into cloud foundry.

Running:
```
docker-compose run --rm vendor
```
will build the dependencies in the build.sh file.  In this case just Proj.4.

Then running:
```
cf push example-app
```
will push the dependencies and attempt to run a python file which tries to import the dependencies.