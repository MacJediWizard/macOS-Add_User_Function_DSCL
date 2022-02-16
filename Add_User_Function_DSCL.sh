#!/bin/bash

##########################################################################################
# General Information
##########################################################################################
#
#	Script created By William Grzybowski February 7, 2022
#
#	Version 1.0	- Initial Creation of Script.
#
#	This script and function was built to properly create a user account on mscOS
#	with no errors or issues, down to the picture.
#
#	The steps are as follows:
#
#	*	Get the next UniquID from macOS
#	*	Get a Random User Picture from the default location
#	*	Use DCSL to Create User
#	*	Use DSCL to set shell for User
#	*	Use DSCL to set Real Name for User
#	*	Use DSCL to set the Primary Group for User
#	*	Use DSCL to set NSFHomeDirectory for User
#	*	Use DSCL to set Group Membership for User
#	*	Use DSCL to to delete any existing User Photo and Set new random User Photo
#	*	Use DSCL to set the UniqueID for User
#	*	Use DSCL to set the Password for the User
#	*	Complete the process and create the Home Directory
#
##########################################################################################


##########################################################################################
# License information
##########################################################################################
#
#	Copyright (c) 2022 William Grzybowski
#
#	Permission is hereby granted, free of charge, to any person obtaining a copy
#	of this software and associated documentation files (the "Software"), to deal
#	in the Software without restriction, including without limitation the rights
#	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#	copies of the Software, and to permit persons to whom the Software is
#	furnished to do so, subject to the following conditions:
#
#	The above copyright notice and this permission notice shall be included in all
#	copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#	SOFTWARE.
#
##########################################################################################


##########################################################################################
# Logging Information
##########################################################################################
# Default Log File Path is below
#	 /Library/Logs/User_Creation_Logs/User_Creation_Log_${logFileDate}.log

myLogFilePath=""	# Path to log file. Recommended /Library/Logs/<Company Name>
myLogFileName=""	# Name of Actual Log File. <YourLogFileName.log>


##########################################################################################
# Variables for Function
##########################################################################################

# Passed from Command Line Argument
myUserName="${1}"	# Required to be entered in argument
myPassword="${2}"	# Required to be entered in argument
myRealName="${3}"	# Required to be entered in argument
isLocalAdmin="${4}"	# Is part of admin group. YES or NO
myDefaultShell="${5}"	# Default is zsh if empty
myPrimaryGroup="${6}"	# Default Group is 20 for staff group if empty



# Get Unique ID from DSCL
getUniqueID=$(dscl . list /users UniqueID | awk '{print $2}' | sort -n | tail -1)

lastUsedUniqueID=${getUniqueID}
nextUniqueID="1"
userUniqueID=$((${lastUsedUniqueID} + ${nextUniqueID}))

# Get random User Account Picture Folder
userPicturesPath="/Library/User Pictures/"
randomUserPicturesPath=( $( ls "${userPicturesPath}" ) )
randomFolder=$[$RANDOM % ${#randomUserPicturesPath[@]}]
randomUserPictureFolder=${randomUserPicturesPath[$randomFolder]}
completeUserPictureFolderPath="/Library/User Pictures/${randomUserPicturesPath[$randomFolder]}/"

# Get random User Account Picture
getRandomUserPicture=( $( ls "${completeUserPictureFolderPath}" ) )
randomPicture=$[$RANDOM % ${#getRandomUserPicture[@]}]
randomUserPicture=${getRandomUserPicture[$randomPicture]}
completeUserPicture="${completeUserPictureFolderPath}${randomUserPicture}"


##########################################################################################
# Core Script
##########################################################################################

#Build Logging for script
logFileDate=`date +"%Y-%b-%d %T"`


if [[ "${myLogFilePath}" != "" ]]; then
	logFilePath="${myLogFilePath}"
else
	logFilePath="/Library/Logs/User_Creation_Logs"
fi


if [[ "${myLogFileName}" != "" ]]; then
	logFile="${logFilePath}/${myLogFileName}"
else
	logFile="${logFilePath}/User_Creation_Log_${logFileDate}.log"
fi	
	

# Check if log path exists
if [ ! -d "$logFilePath" ]; then
	mkdir $logFilePath
fi


# Logging Script
function readCommandOutputToLog(){
	if [ -n "$1" ];	then
		IN="$1"
	else
		while read IN 
		do
			echo "$(date +"%Y-%b-%d %T") : $IN" | tee -a "$logFile"
		done
	fi
}

( # To Capture output into Date and Time log file
	
	# Get Local Info
	logBannerDate=`date +"%Y-%b-%d %T"`
	
	echo " "
	echo "##########################################################################################"
	echo "#                                                                                        #"
	echo "#            Starting the User Creation on the Mac - $logBannerDate                #"
	echo "#                                                                                        #"
	echo "##########################################################################################"
	echo "User Creation process on the Mac has Started..."
		
		
	# Create User Account
	
	# Checking for Username
	if [[ "${myUserName}" != "" ]]; then
		echo "Creating User:${myUserName}"
		dscl . -create /Users/${myUserName}
	else
		echo "Username Required! Exiting Script."
		exit 1
	fi
		
	
	# Checking Default Shell Choice
	if [[ "${myDefaultShell}" != "" ]]; then
		echo "Creating bash shell for User:${myUserName}"
		dscl . -create /Users/${myUserName} UserShell /bin/${myDefaultShell}
	else
		echo "Creating bash shell for User:${myUserName}"
		dscl . -create /Users/${myUserName} UserShell /bin/zsh
	fi
	
	
	# Checking for Real Name
	if [[ "${myRealName}" != "" ]]; then
		echo "Creating Real Name for User:${myUserName}"
		dscl . -create /Users/${myUserName} RealName "${myRealName}"
	else
		echo "Real Name Required! Exiting Script."
		exit 1
	fi
	
	
	# Checking Primary Group Choice
	if [[ "${myPrimaryGroup}" != "" ]]; then
		echo "Creating Primary Group for User:${myUserName}"
		dscl . -create /Users/${myUserName} PrimaryGroupID ${myPrimaryGroup}
	else
		echo "Creating Primary Group for User:${myUserName}"
		dscl . -create /Users/${myUserName} PrimaryGroupID 20
	fi
	
	
	# Creating NFSHomeDirectory
	echo "Creating NFSHomeDirectory for User:${myUserName}"
	dscl . -create /Users/${myUserName} NFSHomeDirectory /Users/${myUserName}
	
	
	# Checking Group Membership
	if [[ "${isLocalAdmin}" == "YES" ]]; then
		echo "Creating Group Membership for User:${myUserName}"
		dscl . -append /Groups/admin GroupMembership ${myUserName}
	fi
	
	
	# Delete the hex entry for jpegphoto
	if [[ "${completeUserPicture}" != "" ]]; then
		echo "Creating Account Photo for User:${myUserName}"
		dscl . delete /Users/${myUserName} jpegphoto
		dscl . delete /Users/${myUserName} Picture
		dscl . create /Users/${myUserName} Picture "${completeUserPicture}"
	else
		echo "User Photo Required! Exiting Script."
		exit 1
	fi
	
	
	# Set UniqueID for User
	if [[ "${userUniqueID}" != "" ]]; then
		echo "Creating UniqueID for User:${myUserName}"
		dscl . -create /Users/${myUserName} UniqueID ${userUniqueID}
	else
		echo "Unique User ID Required! Exiting Script."
		exit 1
	fi
	
	
	# Set User Password
	if [[ "${myPassword}" != "" ]]; then
		echo "Creating Password for User:${myUserName}"
		dscl . -passwd /Users/${myUserName} "${myPassword}"
	
	else
		echo "User Password Required! Exiting Script."
		exit 1
	fi
	
	
	# Create the home directory
	echo "Creating Home Directory Folders for ${myUserName}"
	createhomedir -c -u ${myUserName}
	
	
	echo "User Account:${myUserName} is complete!"
	
	
) 2>&1 | readCommandOutputToLog # To Capture output into Date and Time log file