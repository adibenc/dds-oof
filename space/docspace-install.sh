#!/bin/bash

 #
 # (c) Copyright Ascensio System SIA 2021
 #
 # This program is a free software product. You can redistribute it and/or
 # modify it under the terms of the GNU Affero General Public License (AGPL)
 # version 3 as published by the Free Software Foundation. In accordance with
 # Section 7(a) of the GNU AGPL its Section 15 shall be amended to the effect
 # that Ascensio System SIA expressly excludes the warranty of non-infringement
 # of any third-party rights.
 #
 # This program is distributed WITHOUT ANY WARRANTY; without even the implied
 # warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR  PURPOSE. For
 # details, see the GNU AGPL at: http://www.gnu.org/licenses/agpl-3.0.html
 #
 # You can contact Ascensio System SIA at 20A-12 Ernesta Birznieka-Upisha
 # street, Riga, Latvia, EU, LV-1050.
 #
 # The  interactive user interfaces in modified source and object code versions
 # of the Program must display Appropriate Legal Notices, as required under
 # Section 5 of the GNU AGPL version 3.
 #
 # Pursuant to Section 7(b) of the License you must retain the original Product
 # logo when distributing the program. Pursuant to Section 7(e) we decline to
 # grant you any rights under trademark law for use of our trademarks.
 #
 # All the Product's GUI elements, including illustrations and icon sets, as
 # well as technical writing content are licensed under the terms of the
 # Creative Commons Attribution-ShareAlike 4.0 International. See the License
 # terms at http://creativecommons.org/licenses/by-sa/4.0/legalcode
 #

PARAMETERS="$PARAMETERS -it COMMUNITY";
DOCKER="";
LOCAL_SCRIPTS="false"
product="docspace"
product_sysname="onlyoffice";
FILE_NAME="$(basename "$0")"

while [ "$1" != "" ]; do
	case $1 in
		-ls | --localscripts )
			if [ "$2" == "true" ] || [ "$2" == "false" ]; then
				PARAMETERS="$PARAMETERS ${1}";
				LOCAL_SCRIPTS=$2
				shift
			fi
		;;
		
		-gb | --gitbranch )
			if [ "$2" != "" ]; then
				PARAMETERS="$PARAMETERS ${1}";
				GIT_BRANCH=$2
				shift
			fi
		;;

		docker )
			DOCKER="true";
			shift && continue
		;;

		package )
			DOCKER="false";
			shift && continue
		;;

		"-?" | -h | --help )
			if [ -z "$DOCKER" ]; then
				echo "Run 'bash $FILE_NAME docker' to install docker version of application or 'bash $FILE_NAME package' to install deb/rpm version."
				echo "Run 'bash $FILE_NAME docker -h' or 'bash $FILE_NAME package -h' to get more details."
				exit 0;
			fi
			PARAMETERS="$PARAMETERS -ht $FILE_NAME";
		;;
	esac
	PARAMETERS="$PARAMETERS ${1}";
	shift
done

root_checking () {
	if [ ! $( id -u ) -eq 0 ]; then
		echo "To perform this action you must be logged in with root rights"
		exit 1;
	fi
}

command_exists () {
	type "$1" &> /dev/null;
}

install_curl () {
	if command_exists apt-get; then
		apt-get -y update
		apt-get -y -q install curl
	elif command_exists yum; then
		yum -y install curl
	fi

	if ! command_exists curl; then
		echo "command curl not found"
		exit 1;
	fi
}

read_installation_method () {
	echo "Select 'Y' to install ${product_sysname^^} $product using Docker (recommended). Select 'N' to install it using RPM/DEB packages.";
	read -p "Install with Docker [Y/N/C]? " choice
	case "$choice" in
		y|Y )
			DOCKER="true";
		;;

		n|N )
			DOCKER="false";
		;;

		c|C )
			exit 0;
		;;

		* )
			echo "Please, enter Y, N or C to cancel";
		;;
	esac

	if [ "$DOCKER" == "" ]; then
		read_installation_method;
	fi
}

root_checking

if ! command_exists curl ; then
	install_curl;
fi

if command_exists docker &> /dev/null && docker ps -a --format '{{.Names}}' | grep -q "${product_sysname}-api"; then
    DOCKER="true"
elif command_exists apt-get &> /dev/null && dpkg -s ${product}-api >/dev/null 2>&1; then
    DOCKER="false"
elif command_exists yum &> /dev/null && rpm -q ${product}-api >/dev/null 2>&1; then
    DOCKER="false"
fi
 
if [ -z "$DOCKER" ]; then
	read_installation_method;
fi

if [ -z $GIT_BRANCH ]; then
	DOWNLOAD_URL_PREFIX="https://download.${product_sysname}.com/${product}"
else
	DOWNLOAD_URL_PREFIX="https://raw.githubusercontent.com/${product_sysname^^}/${product}-buildtools/${GIT_BRANCH}/install/OneClickInstall"
fi

if [ "$DOCKER" == "true" ]; then
	if [ "$LOCAL_SCRIPTS" == "true" ]; then
		bash install-Docker.sh ${PARAMETERS} || EXIT_CODE=$?
	else
		curl -s -O  ${DOWNLOAD_URL_PREFIX}/install-Docker.sh
		echo install-Docker.sh ${PARAMETERS} || EXIT_CODE=$?
		# bash install-Docker.sh ${PARAMETERS} || EXIT_CODE=$?
		# rm install-Docker.sh
	fi
else
	if [ -f /etc/redhat-release ] ; then
		if [ "$LOCAL_SCRIPTS" == "true" ]; then
			bash install-RedHat.sh ${PARAMETERS} || EXIT_CODE=$?
		else
			curl -s -O ${DOWNLOAD_URL_PREFIX}/install-RedHat.sh
			bash install-RedHat.sh ${PARAMETERS} || EXIT_CODE=$?
			# rm install-RedHat.sh
		fi
	elif [ -f /etc/debian_version ] ; then
		if [ "$LOCAL_SCRIPTS" == "true" ]; then
			bash install-Debian.sh ${PARAMETERS} || EXIT_CODE=$?
		else
			curl -s -O ${DOWNLOAD_URL_PREFIX}/install-Debian.sh
			bash install-Debian.sh ${PARAMETERS} || EXIT_CODE=$?
			# rm install-Debian.sh
		fi
	else
		echo "Not supported OS";
		exit 1;
	fi
fi

exit ${EXIT_CODE:-0}
