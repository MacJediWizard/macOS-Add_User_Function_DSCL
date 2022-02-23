# Add_User_Function_DSCL

## This script and function was built to properly create a user account on macOS
  with no errors or issues, down to the picture.

The steps are as follows:

    *	Get the next UniquID from macOS
    *	Get a Random User Picture from the default location
    *	Use DCSL to Create User
    *	Use DSCL to set shell for User
    *	Use DSCL to set Real Name for User
    *	Use DSCL to set the Primary Group for User
    *	Use DSCL to set NSFHomeDirectory for User
    *	Use DSCL to set Group Membership for User
    *	Use DSCL to to delete any existing User Photo and Set new random User Photo
    *	Use DSCL to set the UniqueID for User
    *	Use DSCL to set the Password for the User
    *	Complete the process and create the Home Directory

## Logging

In the script there is Logging built in. You can use the defaults or set the log file in variables. 
The default location is: /Library/Logs/User_Creation_Logs/User_Creation_Log_${logFileDate}.log

If you want to set the LogFile path and name enter the info under: Logging Information
myLogFilePath=""	# Path to log file. Recommended /Library/Logs/[Company Name]
myLogFileName=""	# Name of Actual Log File. [YourLogFileName.log]

## Variables

This script can take the following Variables in the command path.
exampleScript.sh "myUserName" "myPassword" "myRealName" "isLocalAdmin" "myDefaultShell" "myPrimaryGroup"

### Variable Description:

    * myUserName="${1}"	# Required to be entered in argument
    * myPassword="${2}"	# Required to be entered in argument
    * myRealName="${3}"	# Required to be entered in argument
    * isLocalAdmin="${4}"	# Is part of admin group. YES or NO
    * myDefaultShell="${5}"	# Default is zsh if empty
    * myPrimaryGroup="${6}"	# Default Group is 20 for staff group if empty

You could also use this with JAMF by adjusting the Variables either to $4 $5 $6 etc or programmatically entering the variables. I use this code with JAMF to   create User accounts on during the Enrollment process
