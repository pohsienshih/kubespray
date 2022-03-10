# Offline deployment

## manage-offline-container-images.sh

Container image collecting script for offline deployment

This script has two features:
(1) Get container images from an environment which is deployed online.
(2) Deploy local container registry and register the container images to the registry.

Step(1) should be done online site as a preparation, then we bring the gotten images
to the target offline environment.
Then we will run step(2) for registering the images to local registry.

Step(1) can be operated with:

```shell
manage-offline-container-images.sh   create
```

Step(2) can be operated with:

```shell
manage-offline-container-images.sh   register
```

If you want to push the images to external registry, you can fill in the following parmeters, then be operated with:
```
EXTERNAL_REGISTRY="your-external-registry"
EXTERNAL_REGISTRY_ACCOUNT=""
EXTERNAL_REGISTRY_PASSWORD=""
```
```shell
manage-offline-container-images.sh   register  external
```

## generate_list.sh

This script generates the list of downloaded files and the list of container images by `roles/download/defaults/main.yml` file.

Run this script will execute `generate_list.yml` playbook in kubespray root directory and generate four files,
all downloaded files url in files.list, all container images in images.list, jinja2 templates in *.template.

```shell
./generate_list.sh
tree temp
temp
├── files.list
├── files.list.template
├── images.list
└── images.list.template
0 directories, 5 files
```

In some cases you may want to update some component version, you can declare version variables in ansible inventory file or group_vars,
then run `./generate_list.sh -i [inventory_file]` to update file.list and images.list.

### Get the required images and files
After `images.list` and `files.list` be generated. You can download the images and files by using the mirror scripts.

> Execute the following command in your online environment.
1. Pull all images in `images.list` and save to files. After execution, you will get the `offline_images.tar.gz` in current folder. Bring this file to your disconected environment.
```shell
./1_pull_and_save_images.sh
```
2.  Download all files in `files.list`. After execution, you will get the `offline_files.tar.gz` in current folder. Bring this file to your disconected environment.
```shell
./3_get_offline_files.sh
```

### Push the images to your private registry

1. Modify the NEW_REGISTRY to your private registry.
```shell
vim 2_tag_push_image.sh
```
```
#!/bin/bash
NEW_REGISTRY="private-registry.example.com"
K8S_GCR_IMAGE_REPO="example"
#------------------------------------------------
```

Some `k8s.gcr.io` images do not have the Namespace/Project name, e.g. `k8s.gcr.io/kube-proxy:v1.19.9`. This will lead some registries (like HARBOR) failed to push image (https://github.com/goharbor/harbor/issues/5255). So we need to retag these images with the new Namespace/Project name (`K8S_GCR_IMAGE_REPO`) to avoid this issue. 

You must also config `kube_image_repo` to `private-registry.example.com/NEW_NAMESPACE` which is in `group_vars/all/offline.yml`.

2. Push the images to your private registry.
```shell
./2_tag_push_image.sh
```

