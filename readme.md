# Toolset for building and deploying a CMaNGOS-classic server
## Taken from https://github.com/jrtashjian/cmangos-docker

Build the builder-base image with the build_image_local.sh script and provide the builder-base directory as an argument example:
```sh
# While in wow_server/
chmod +x ./builder-base/build_image_local.sh
./builder-base/build_image_local.sh ./builder-base
```