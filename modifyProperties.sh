#!/bin/bash

#############################################################################
# Copyright 2013-2016 Avaya Inc., All Rights Reserved.
#
# THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Avaya Inc.
#
# The copyright notice above does not evidence any actual or intended
# publication of such source code.
#
# Some third-party source code components may have been modified from their
# original versions by Avaya Inc.
#
# The modifications are Copyright 2013-2016 Avaya Inc., All Rights Reserved.
#
# Avaya - Confidential & Restricted. May not be distributed further without
# written permission of the Avaya owner.
#############################################################################


function adminTimeoutConfigfile() #identify configuration file for Admin UI httpsession timeout
{
   ADMIN_HOME=$TOMCAT_DIR/webapps/admin
   echo "Admin war base directory: $ADMIN_HOME" >> $INSTALL_DIR_PARENT/logs/${SHORT_PRODUCT_NAME}_utility.log
   ADMIN_TIMEOUT_CONFIG_FILE=$ADMIN_HOME/WEB-INF/web.xml
   if [[ ! -e $ADMIN_TIMEOUT_CONFIG_FILE ]]; then
    	echo `date +%F_%T` "Error opening $ADMIN_TIMEOUT_CONFIG_FILE.  Is Admin war properly deployed?"
    	exit 1
   fi	
}

function appTimeoutConfigfile() #identify configuration file for application httpsession timeout
{
   APP_TIMEOUT_CONFIG_FILE=$TOMCAT_DIR/conf/web.xml
   if [[ ! -e $APP_TIMEOUT_CONFIG_FILE ]]; then
    	echo `date +%F_%T` "Error opening $APP_TIMEOUT_CONFIG_FILE.  Is Tomcat installed?"
    	exit 1
   fi 
}

function aemMaxSessionsConfigfile() #identify configuration file for setting maximum concurrent httpsessions that can be active
{
   AEM_HOME=$TOMCAT_DIR/webapps/aem
   echo "Aem war base directory: $AEM_HOME" >> $INSTALL_DIR_PARENT/logs/${SHORT_PRODUCT_NAME}_utility.log
   
   AEM_MAX_SESSIONS_CONFIG_FILE=$AEM_HOME/META-INF/context.xml
   
   if [[ ! -e $AEM_MAX_SESSIONS_CONFIG_FILE ]]; then
    	echo `date +%F_%T` "Error opening $AEM_MAX_SESSIONS_CONFIG_FILE.  Application is not AMM!"
   fi 
}

function aadsMaxSessionsConfigfile() #identify configuration file for setting maximum concurrent httpsessions that can be active
{
   AADS_HOME=$TOMCAT_DIR/webapps/acs
   echo "AADS war base directory: $AADS_HOME" >> $INSTALL_DIR_PARENT/logs/${SHORT_PRODUCT_NAME}_utility.log
   
   AADS_MAX_SESSIONS_CONFIG_FILE=$AADS_HOME/META-INF/context.xml
   
   if [[ ! -e $AADS_MAX_SESSIONS_CONFIG_FILE ]]; then
    	echo `date +%F_%T` "Error opening $AADS_MAX_SESSIONS_CONFIG_FILE.  Application is not AADS!"
   fi 
}

function notifMaxSessionsConfigfile() #identify configuration file for setting maximum concurrent httpsessions that can be active
{
   NOTIF_HOME=$TOMCAT_DIR/webapps/notification
   echo "Notification war base directory: $NOTIF_HOME" >> $INSTALL_DIR_PARENT/logs/${SHORT_PRODUCT_NAME}_utility.log
   
   NOTIF_MAX_SESSIONS_CONFIG_FILE=$NOTIF_HOME/META-INF/context.xml
   
   if [[ ! -e $NOTIF_MAX_SESSIONS_CONFIG_FILE ]]; then
    	echo `date +%F_%T` "Error opening $NOTIF_MAX_SESSIONS_CONFIG_FILE.  Is Tomcat installed?"
    	exit 1
   fi 
}

function modifyFileForTimeout()
{
   echo `date +%F_%T` "Modifying $1 with value $2............"
   
   sed -i "/<session-timeout>/s,<session-timeout>.*</session-timeout>,<session-timeout>$2</session-timeout>,"  $1
		
   #sudo chmod 0600 $1
  
   RC=$?
   if [[ $RC == 0 ]]; then
   		echo `date +%F_%T` "Finished  SUCCESSFULLY............."
   else
   		echo `date +%F_%T` "Finished  UNSUCCESSFULLY with return code $RC!"
   		exit $RC
   fi
}

function modifyFileForMaxSessions()
{
   echo `date +%F_%T` "Modifying $1 with value $2............"
   maxSessions=$(echo $2|tr -d '\r')
   sed -i -r "s/(maxActiveSessions=\")[^\"]+\"/\1$maxSessions\"/" $1
		 
   RC=$?
   if [[ $RC == 0 ]]; then
   		echo `date +%F_%T` "Finished  SUCCESSFULLY............."
   else
   		echo `date +%F_%T` "Finished  UNSUCCESSFULLY with return code $RC!"
   		exit $RC
   fi
}

export INSTALL_DIR=`readlink -f $0`
export INSTALL_DIR=`dirname $INSTALL_DIR | sed -e "s,/misc,,"`
export INSTALL_DIR_PARENT=$( dirname $( dirname $INSTALL_DIR ) )
declare -i RC=0


. $INSTALL_DIR/config/install.properties
. $INSTALL_DIR/misc/common.sh

CASSANDRA_CLUSTER_NAME="AvayaMsgCluster-1"
CASS_USR=`sed -n -e '/^databaseUser/s,.*=,,p' $INSTALL_DIR/config/cas-settings.properties`
CASS_PW=`sed -n -e '/^databasePassword/s,.*=,,p' $INSTALL_DIR/config/cas-settings.properties`

echo "Cassandra base directory is........$CASSANDRA_DIR" >> $INSTALL_DIR_PARENT/logs/${SHORT_PRODUCT_NAME}_utility.log
processSQLFile(){
        $CASSANDRA_DIR/bin/cqlsh \
        -u $CASS_USR \
        -p $CASS_PW \
        -k cas_common_data \
        -f $1
}

#Called when AMMTomcat service executes e.g during a new node addition,node restart
echo `date +%F_%T` "Running the $0 script" >> $INSTALL_DIR_PARENT/logs/${SHORT_PRODUCT_NAME}_utility.log

#Get session related properties from Cassandra
if [[ "$INCLUDE_AADS_ONLY" ]]; then
	${INSTALL_DIR}/misc/clitool-acs.sh getSessionProperties > tmp.txt
else
	processSQLFile  $INSTALL_DIR/cassandra/ApplicationProperties.sql
fi

#Pass the configuration file & property value as parameters
while IFS=, read appHttpSessionTimeout adminHttpSessionTimeout maxConcurrentSessions; do
	appTimeoutConfigfile
	modifyFileForTimeout $APP_TIMEOUT_CONFIG_FILE $appHttpSessionTimeout
	adminTimeoutConfigfile
	modifyFileForTimeout $ADMIN_TIMEOUT_CONFIG_FILE $adminHttpSessionTimeout
	aemMaxSessionsConfigfile
	[[ "$INCLUDE_AMM" ]] && modifyFileForMaxSessions $AEM_MAX_SESSIONS_CONFIG_FILE $maxConcurrentSessions
	aadsMaxSessionsConfigfile
	[[ "$INCLUDE_AADS_ONLY" ]] && modifyFileForMaxSessions $AADS_MAX_SESSIONS_CONFIG_FILE $maxConcurrentSessions
	notifMaxSessionsConfigfile
	modifyFileForMaxSessions $NOTIF_MAX_SESSIONS_CONFIG_FILE $maxConcurrentSessions
done < tmp.txt
rm tmp.txt

sleep 5