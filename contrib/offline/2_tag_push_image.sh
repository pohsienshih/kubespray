#!/bin/bash
NEW_REGISTRY="Your Private Registry"
K8S_IMAGE_REPO="example"
#------------------------------------------------

tar -zxvf offline_images.tar.gz
# Load the Docker images
ls -al saved_images_files |  grep tar |awk '{print $9}' | xargs -I @ docker load -i ./saved_images_files/@

# Login to your private registry
sudo docker login $NEW_REGISTRY

while IFS= read -r line; do
   ORGIN_REGISTRY=$(echo $line | sed 's/\(\/.*\)//g')

   # Some k8s.gcr.io images do not have the Namespace/Project name. This will lead some registries (like HARBOR)
   # failed to push image. So we need to retag these images with the new Namespace/Project name to avoid this issue.
   # https://github.com/goharbor/harbor/issues/5255
   NEW_IMAGE=$(echo $line | sed "s/$ORGIN_REGISTRY/$NEW_REGISTRY\/$K8S_GCR_IMAGE_REPO/g")
 

   # Tag the Image
   sudo docker tag $line $NEW_IMAGE
   # Push the Image
   sudo docker push $NEW_IMAGE

   sudo docker rmi $line

   echo "ORIGIN IMAGE: "$line
   echo "NEW IMAGE: "$NEW_IMAGE
   printf "\n\n"
done < saved_images_files/images.list

echo "Compete"