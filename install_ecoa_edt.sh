#!/bin/bash

# -----------------------------------------------------------------------------
# Script to install ECOA EDT (Design Tool) on Ubuntu Linux
# Author: Dennis Güler
# Date: 2024-06-21 
# Version: 1.2
# Description: This script downloads and installs the ECOA EDT tool, installs 
#              the latest Java JDK, updates the ECOA Design Tool configuration,
#              and runs the tool. Optionally, a proxy can be set for downloads.
# -----------------------------------------------------------------------------

# Color definition
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Set variables
ECOA_EDT_URL="https://github.com/ecoa-tools/edt/releases/download/v1.1.0/ECOA.Design.Tool.v1.1.0_linux.zip"
ECOA_EDT_ZIP="ECOA.Design.Tool.v1.1.0_linux.zip"
ECOA_EDT_DIR="ECOA_Design_Tool"
JDK_URL="https://download.oracle.com/java/22/latest/jdk-22_linux-x64_bin.deb"
JDK_DEB="jdk-22_linux-x64_bin.deb"
PROXY=""

# Check for proxy argument
while getopts "p:" opt; do
  case ${opt} in
    p )
      PROXY=$OPTARG
      ;;
    \? )
      echo -e "${RED}Invalid option: $OPTARG${NC}" 1>&2
      exit 1
      ;;
    : )
      echo -e "${RED}Invalid option: $OPTARG requires an argument${NC}" 1>&2
      exit 1
      ;;
  esac
done

# Function to print error messages
error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

# Set wget options with or without proxy
if [ -n "$PROXY" ]; then
  WGET_OPTS="--show-progress -e use_proxy=yes -e http_proxy=$PROXY -e https_proxy=$PROXY"
else
  WGET_OPTS="--show-progress"
fi

# Step 1: Download ECOA EDT Release
echo -e "${BLUE}Downloading ECOA EDT Release...${NC}"
wget $WGET_OPTS $ECOA_EDT_URL -O $ECOA_EDT_ZIP || error "Failed to download ECOA EDT Release."

# Step 2: Unzip the downloaded file
echo -e "${BLUE}Unzipping ECOA EDT Release...${NC}"
unzip -o $ECOA_EDT_ZIP -d $ECOA_EDT_DIR || error "Failed to unzip ECOA EDT Release."

# Step 3: Download and install the latest version of Java JDK
echo -e "${BLUE}Downloading the latest Java JDK...${NC}"
wget $WGET_OPTS $JDK_URL -O $JDK_DEB || error "Failed to download Java JDK."

echo -e "${BLUE}Installing the latest Java JDK...${NC}"
sudo dpkg -i $JDK_DEB || error "Failed to install Java JDK."
sudo apt-get install -f -y || error "Failed to resolve dependencies."

# Delete the downloaded .deb package
echo -e "${BLUE}Deleting the downloaded JDK Debian package...${NC}"
rm $JDK_DEB || error "Failed to delete the JDK Debian package."

# Step 4: Update the "ECOA Design Tool.ini" file
echo -e "${BLUE}Updating ECOA Design Tool.ini...${NC}"
JDK_PATH=$(dirname $(dirname $(readlink -f $(which java))))
INI_FILE=$(find $ECOA_EDT_DIR -name "ECOA Design Tool.ini")

if [[ -f "$INI_FILE" ]]; then
    echo -e "\n-vm\n$JDK_PATH/bin/java" >> "$INI_FILE"
    echo -e "${GREEN}Updated ECOA Design Tool.ini successfully.${NC}"
else
    error "ECOA Design Tool.ini file not found at expected path: $INI_FILE."
fi

# Step 5: Make the "ECOA Design Tool" executable
echo -e "${BLUE}Making the ECOA Design Tool executable...${NC}"
chmod +x "$ECOA_EDT_DIR/ECOA Design Tool v1.1.0/ECOA Design Tool" || error "Failed to make ECOA Design Tool executable."

# Step 6: Run the ECOA Design Tool
echo -e "${BLUE}Running the ECOA Design Tool...${NC}"
cd "$ECOA_EDT_DIR/ECOA Design Tool v1.1.0"
./ECOA\ Design\ Tool || error "Failed to run ECOA Design Tool."

echo -e "${GREEN}ECOA EDT installation and setup completed successfully.${NC}"
