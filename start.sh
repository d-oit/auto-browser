#!/bin/bash

# Set script directory as working directory
cd "$(dirname "$0")" || exit 1

# Configuration files and directories
export CONFIG_FILE="config.yaml"
export ENV_FILE=".env"
export OPENROUTER_CONFIG="openrouter.yaml"
export SCRIPTS_DIR="scripts"

# Color definitions
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

# Get version from pyproject.toml
get_version() {
    if [ -f "pyproject.toml" ]; then
        version=$(grep -m1 'version = ' pyproject.toml | cut -d'"' -f2)
        echo "${version:-0.1.0}"
    else
        echo "0.1.0"
    fi
}

# Display banner
show_banner() {
    clear
    echo -e "${YELLOW}"
    cat << "EOF"
    _         _          ____                                  
   / \  _   _| |_ ___   | __ ) _ __ _____      _____  ___ _ __ 
  / _ \| | | | __/ _ \  |  _ \| '__/ _ \ \ /\ / / __|/ _ \ '__|
 / ___ \ |_| | || (_) | | |_) | | | (_) \ V  V /\__ \  __/ |   
/_/   \_\__,_|\__\___/  |____/|_|  \___/ \_/\_/ |___/\___|_|   
EOF
    echo -e "${NC}"
}

# Trap Ctrl+C
trap ctrl_c INT

ctrl_c() {
    echo -e "\n\n${YELLOW}Exiting...${NC}"
    exit 0
}

# Source menu modules
source_menu_modules() {
    # Create modules directory if it doesn't exist
    mkdir -p modules/menus
    
    # Source main menu (which sources other menus)
    if [ -f "modules/menus/main_menu.sh" ]; then
        source "modules/menus/main_menu.sh"
    else
        echo -e "${RED}Error: Main menu module not found${NC}"
        exit 1
    fi
}

# Check if running with sudo/root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}Please do not run this script as root/sudo${NC}"
        exit 1
    fi
}

# Main function
main() {
    # Check if not running as root
    check_root
    
    # Source menu modules
    source_menu_modules
    
    # Launch main menu
    main_menu
}

# Start the application
main "$@"
