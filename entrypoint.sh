#!/bin/bash
export DOCKER_WD="$(pwd)"
source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
echo "EXECUTING entrypoint"
if [[ "$DOCKER_WD" == /opt/application* ]]; then 
 
   WD_APP_NAME="$(echo $DOCKER_WD | cut -d "/" -f 4)"
   if [ ! -z $WD_APP_NAME ] && [ -d /opt/application/$WD_APP_NAME/app/.meteor ]; then
      export APP_NAME="$WD_APP_NAME"
      echo "Inside [$APP_NAME]"

   fi
fi

if [ "$APP_NAME" == "default" ]; then
   echo "Setting APP_TEMPLATE to meteor-dev-kalan"
   export APP_TEMPLATE="meteor-dev-kalan"
fi
export APP_LOCALDB="/home/meteor/meteorlocal/$APP_NAME"
export LINK_LOCAL="$(readlink /opt/application/$APP_NAME/app/.meteor/local)"

if [ ! -z $ADD_MODULE ]; then
  echo "adding package $ADD_MODULE"
  if [ ! -d /opt/application/$APP_NAME/packages ];then
      mkdir -p /opt/application/$APP_NAME/packages
  fi

  #export METEOR_PACKAGE_DIRS="/opt/application/$APP_NAME/packages"
  cd /opt/application/$APP_NAME/packages 
  if [ ! -d /opt/application/$APP_NAME/packages/$ADD_MODULE ];then
      git clone https://github.com/$GIT_REPO/$ADD_MODULE.git 
  fi
  if [ "$ADD_MODULE" == "orion" ];then
     echo "Reimporting local packages for module $ADD_MODULE"
     mkdir -p /opt/application/$APP_NAME/app/packages
     if [ -d /opt/application/$APP_NAME/app/packages/materialize ];then
         ln -s /opt/application/$APP_NAME/packages/orion/packages/materialize /opt/application/$APP_NAME/app/packages/materialize
     fi
     cd /opt/application/$APP_NAME/app
     
     meteor remove orionjs:materialize
     #meteor add materialize:materialize@=0.97.0
     meteor add orionjs:materialize@=1.8.1
  fi
  export ADD_MODULE=""
  exit 0
fi

#if [ -d /opt/application/$APP_NAME/packages ];then
      #export METEOR_PACKAGE_DIRS="/opt/application/$APP_NAME/packages"
#fi

if [ ! -d /opt/application/$APP_NAME ];then
      echo "No previous folder for app $APP_NAME"

   if [ -z $APP_TEMPLATE ]; then
      cd /opt/application/
      echo "Creating new app $APP_NAME (maka create)"
      #mkdir -p /opt/application/$APP_NAME
      cd /opt/application
      meteor maka create "$APP_NAME"
      cd /opt/application/$APP_NAME
      if [[ -d "$APP_LOCALDB" ]];then
        echo "Cleaning Existing LOCALDB folder..."
        rm -rf $APP_LOCALDB
      fi
      mkdir -p $APP_LOCALDB

      if [ -d /opt/application/$APP_NAME/app/.meteor/local ];then
         echo "Copy generated local to $APP_LOCALDB..."
         cp -ar /opt/application/$APP_NAME/app/.meteor/local/* $APP_LOCALDB
         mv /opt/application/$APP_NAME/app/.meteor/local /opt/application/$APP_NAME/local_backup
      fi
      if [ ! -d /opt/application/$APP_NAME/app/.meteor ];then
        mkdir -p /opt/application/$APP_NAME/app/.meteor
      fi
      cd /opt/application/$APP_NAME/app
      ln -s $APP_LOCALDB /opt/application/$APP_NAME/app/.meteor/local 
      #meteor npm install
      #meteor add npm-bcrypt orionjs:core twbs:bootstrap fortawesome:fontawesome orionjs:bootstrap iron:router
      #meteor add sacha:spin orionjs:filesystem orionjs:image-attribute vsivsi:orion-file-collection

      #meteor remove autopublish insecure

       #meteor add npm-bcrypt 
      #meteor add orionjs:core 
      #meteor add twbs:bootstrap fortawesome:fontawesome orionjs:bootstrap 
      #meteor add iron:router
      #meteor add fourseven:scss
      ##meteor add materialize:materialize@=0.97.0 orionjs:materialize
      ##meteor add kadira:flow-router kadira:blaze-layout

      #meteor update --all-packages
      
      echo "Default meteor app created: $APP_NAME"

   else
      echo "Creating new app from template: [$APP_TEMPLATE]"
      if [ "$APP_TEMPLATE" == "meteor-application-template" ];then
         export APP_SETTINGS_FILE="/opt/application/$APP_NAME/config/settings.development.json"
         export APP_SETTINGS="--settings $APP_SETTINGS_FILE"
         echo "DEFAULT Using  default template"
         cd /opt/application
         git clone https://github.com/$GIT_REPO/$APP_TEMPLATE.git $APP_NAME
      else
         echo "Using repository $APP_TEMPLATE template "
         export APP_WORKDIR="/opt/application/$APP_NAME"
         mkdir -p $APP_WORKDIR
         cd $APP_WORKDIR
         git clone https://github.com/$GIT_REPO/$APP_TEMPLATE.git app
      fi
       mkdir -p $APP_LOCALDB
      if [ -d /opt/application/$APP_NAME/app/.meteor/local ];then
         cp -arv /opt/application/$APP_NAME/app/.meteor/local/* $APP_LOCALDB
         mv /opt/application/$APP_NAME/app/.meteor/local /opt/application/$APP_NAME/local_backup
      fi

       ln -s $APP_LOCALDB /opt/application/$APP_NAME/app/.meteor/local
       echo $APP_SETTINGS > /opt/application/$APP_NAME/app_settings.txt
       cd /opt/application/$APP_NAME/app 

       #meteor npm install
       #meteor add npm-bcrypt 
       #meteor add orionjs:core twbs:bootstrap fortawesome:fontawesome orionjs:bootstrap iron:router
       #meteor remove autopublish insecure
       #meteor update --all-packages

   fi
   echo "New application created:[$APP_NAME]"
   
   echo "    TO enter work dir for that app type: "
   echo "    cd /opt/application/$APP_NAME/app"
   kalan-var "CURRENT_APP" "$APP_NAME"
   exit 0
fi

echo "Existing app"
if [[ ! -d "$APP_LOCALDB" ]];then
  echo "creating LOCALDB folder..."
  mkdir -p $APP_LOCALDB
  export NEW_LOCALDB="$APP_LOCALDB"
fi

file="/opt/application/$APP_NAME/app/.meteor/local"
if [[ -L "$file" && -d "$file" ]];then
    #echo "LOCAL is a symlink to a directory"

    if [ ! "$LINK_LOCAL" == "$APP_LOCALDB" ];then
       echo "LOCAL symlink not same for $APP_NAME $LINK_LOCAL"
       rm /opt/application/$APP_NAME/app/.meteor/local
       ln -s $APP_LOCALDB /opt/application/$APP_NAME/app/.meteor/local 
    fi
else
    #echo "No previous link OK"
   if [[ -d /opt/application/$APP_NAME/app/.meteor/local ]];then

       echo "BACKUP and Copying original folder to LOCALDB..."
       if [[ -d "$APP_LOCALDB" ]];then
           echo "Cleaning Existing LOCALDB folder..."
           rm -rf $APP_LOCALDB
           mkdir -p $APP_LOCALDB
       fi

       cp -ar /opt/application/$APP_NAME/app/.meteor/local/* $APP_LOCALDB
       mv /opt/application/$APP_NAME/app/.meteor/local /opt/application/$APP_NAME/local_backup
       ln -s $APP_LOCALDB /opt/application/$APP_NAME/app/.meteor/local
   else 
      # echo "No previous local on source"
      if [[ -d "$APP_LOCALDB" ]];then
        echo "Cleaning Existing LOCALDB folder:"
        echo "$APP_LOCALDB"
        rm -rf $APP_LOCALDB
        mkdir -p $APP_LOCALDB
      fi

       ln -s $APP_LOCALDB /opt/application/$APP_NAME/app/.meteor/local

   fi     

    cd /opt/application/$APP_NAME/app
    if [ "$APP_NAME" == "default" ]; then
      if [[ -d /opt/application/$APP_NAME/app/node_modules ]];then
          echo "updating"
          #meteor update 
          echo "Starting meteor npm install"
          meteor npm install
       fi
   fi
     #meteor update --all-packages
fi

if [ -e /opt/application/$APP_NAME/app_settings.txt ];then
    APP_SETTINGS="$(cat /opt/application/$APP_NAME/app_settings.txt)"
    echo $APP_SETTINGS
fi

if [ -d /opt/application/$APP_NAME/.maka ];then
    echo "maka start"
  cd /opt/application/$APP_NAME
  meteor maka run
else
  cd /opt/application/$APP_NAME/app
  #echo "Starting application: [$APP_NAME]"
  echo $APP_SETTINGS
  kalan-var "CURRENT_APP" "$APP_NAME"
  echo ""
  echo "Starting meteor. Press Ctrl+Z to stop."
  #echo "CURRENT_APP: [$APP_NAME]"
  meteor $APP_SETTINGS $APP_PARAMETERS
 fi
#exit 0
