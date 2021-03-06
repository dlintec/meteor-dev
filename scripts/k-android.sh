#!/bin/bash  
source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
current_app=$(kalan-var "CURRENT_APP")

if  grep -q "ANDROID_HOME" $HOME/.bashrc; then
    echo "Android tools already installed"
    touch ~/.android/repositories.cfg

else

   #wget https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip 
   #unzip sdk-tools-linux-3859397 -d /home/meteor/android
   #echo 'export ANDROID_HOME=/usr/lib/android-sdk' >> ~/.bashrc
   #echo 'export PATH=$PATH:/home/meteor/android/tools:/home/meteor/android/tools/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools' >> ~/.bashrc
   #touch ~/.android/repositories.cfg
   
   wget https://dl.google.com/android/repository/tools_r25.2.3-linux.zip
   unzip tools_r25.2.3-linux -d /home/meteor/android25
   rm -rf tools_r25.2.3-linux.zip
   echo 'export ANDROID_HOME=/home/meteor/android25' >> ~/.bashrc
   echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin' >> ~/.bashrc
   touch ~/.android/repositories.cfg
   export ANDROID_HOME=/home/meteor/android25
   export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin
   sdkmanager 'build-tools;25.0.3' 
   sdkmanager 'platforms;android-25' 
   sdkmanager 'platform-tools'
   #sdkmanager 'ndk-bundle'
   #mkdir ~/.gradle
   #echo 'org.gradle.daemon=true' >> ~/.gradle/gradle.properties
   
fi

meteor add-platform android
