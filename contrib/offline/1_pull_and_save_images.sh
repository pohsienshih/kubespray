#!/bin/bash

mkdir saved_images_files
while IFS= read -r line; do
   # Pull Image
   sudo docker pull $line
   IMAGE_NAME=$(echo $line | sed 's/\(.*\/\)//g;s/:/-/g')

   # Save Image to file
   sudo docker save -o ./saved_images_files/"$IMAGE_NAME.tar" $line
   
   # Remove the Image
   sudo docker rmi $line

   echo "$IMAGE_NAME.tar be saved successfully."
   printf "\n"

done < temp/images.list
cp temp/images.list saved_images_files
tar -zcvf offline_images.tar.gz  saved_images_files
rm -rf saved_images_files

echo ""
echo "offline_images.tar.gz is created to contain your container images."
echo "Please keep this file and bring it to your offline environment."