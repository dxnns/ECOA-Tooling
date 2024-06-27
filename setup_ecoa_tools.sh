#!/bin/bash

# -----------------------------------------------------------------------------
# Script to set up and run ECOA AS6-tools using Anaconda
# Author: Dennis Güler
# Date: 2024-06-27
# Version: 1.4
# Description: This script installs Anaconda, sets up a conda environment, 
#              updates the lxml version in pyproject.toml, and runs the ECOA GUI.
# -----------------------------------------------------------------------------

# Define Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print error messages
error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

# Step 1: Install Anaconda if not already installed
if [ -d "$HOME/anaconda3" ]; then
    echo -e "${BLUE}Anaconda is already installed. Skipping installation.${NC}"
else
    echo -e "${BLUE}Downloading and installing Anaconda...${NC}"
    wget -O Anaconda3-latest-Linux-x86_64.sh https://repo.anaconda.com/archive/Anaconda3-2024.02-1-Linux-x86_64.sh || error "Failed to download Anaconda."
    bash Anaconda3-latest-Linux-x86_64.sh -b || error "Failed to install Anaconda."
    eval "$($HOME/anaconda3/bin/conda shell.bash hook)" || error "Failed to initialize conda."
    conda init || error "Failed to initialize conda in the shell."
fi

# Reload the shell to ensure conda is initialized
source ~/.bashrc

# Step 2: Create and activate conda environment
echo -e "${BLUE}Creating and activating conda environment 'ecoa-tools-env'...${NC}"
conda create -y -n ecoa-tools-env || error "Failed to create conda environment."
source activate ecoa-tools-env || error "Failed to activate conda environment."

# Step 3: Install lxml package
echo -e "${BLUE}Installing lxml package...${NC}"
conda install -y anaconda::lxml || error "Failed to install lxml package."

# Step 4: Change directory to /ecoa-exvt
echo -e "${BLUE}Changing directory to ecoa-exvt...${NC}"
cd ecoa-exvt || error "Failed to change directory to ecoa-exvt."

# Step 5: Update lxml version in pyproject.toml
echo -e "${BLUE}Updating lxml version in pyproject.toml to 5.2.2...${NC}"
sed -i 's/lxml.*/lxml==5.2.2"/' pyproject.toml || error "Failed to update lxml version in pyproject.toml."

# Step 6: Install the project in editable mode
echo -e "${BLUE}Installing the project in editable mode...${NC}"
pip install -e . || error "Failed to install the project."

# Step 7: Change back to the previous directory
echo -e "${BLUE}Changing back to the previous directory...${NC}"
cd - || error "Failed to change back to the previous directory."

# Step 8: Change directory to ecoa-gui
echo -e "${BLUE}Changing directory to ecoa-gui...${NC}"
cd ecoa-gui || error "Failed to change directory to ecoa-gui."

# Step 9: Install required packages
echo -e "${BLUE}Installing required packages from requirements.txt...${NC}"
pip install -r requirements.txt || error "Failed to install required packages."

# Step 10: Change directory to src
echo -e "${BLUE}Changing directory to src...${NC}"
cd src || error "Failed to change directory to src."

# Step 11: Run the ECOA GUI
echo -e "${BLUE}Running the ECOA GUI...${NC}"
python ecoa_gui.py || error "Failed to run the ECOA GUI."

# Instruction for setting up the interpreter in Visual Studio Code
echo -e "${YELLOW}-------------------------------------------------------------${NC}"
echo -e "${YELLOW} To use the correct Python interpreter in Visual Studio Code: ${NC}${NC}"
echo -e "${YELLOW} 1. Open Visual Studio Code.                                ${NC}"
echo -e "${YELLOW} 2. Press Ctrl+Shift+P to open the command palette.          ${NC}"
echo -e "${YELLOW} 3. Type 'Python: Select Interpreter' and select it.         ${NC}"
echo -e "${YELLOW} 4. Choose the interpreter located at:                      ${NC}"
echo -e "${YELLOW}    $HOME/anaconda3/envs/ecoa-tools-env/bin/python           ${NC}${NC}"
echo -e "${YELLOW} This ensures that Visual Studio Code uses the correct       ${NC}"
echo -e "${YELLOW} Python environment for thr project.                        ${NC}"
echo -e "${YELLOW}-------------------------------------------------------------${NC}"

echo -e "${GREEN}ECOA tools setup and GUI execution completed successfully.${NC}"
