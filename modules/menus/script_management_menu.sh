#!/bin/bash

# List all available scripts
list_scripts() {
    local script_dir="$1"
    local count=1
    
    if [ ! -d "$script_dir" ]; then
        echo -e "${RED}Error: Directory not found: $script_dir${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Available Scripts in $script_dir:${NC}\n"
    
    for script in "$script_dir"/*.sh; do
        if [ -f "$script" ]; then
            local script_name=$(basename "$script")
            local description=""
            
            # Try to extract description from script header comment
            description=$(head -n 5 "$script" | grep -i "description:" | cut -d ":" -f 2- | tr -d '\r' | xargs)
            
            if [ -z "$description" ]; then
                description="No description available"
            fi
            
            printf "${CYAN}%2d)${NC} %-30s - %s\n" "$count" "$script_name" "$description"
            ((count++))
        fi
    done
}

# Edit a script
edit_script() {
    local script_path="$1"
    local editor="${EDITOR:-nano}"
    
    if [ ! -f "$script_path" ]; then
        echo -e "${RED}Error: Script not found: $script_path${NC}"
        return 1
    fi
    
    $editor "$script_path"
}

# Delete a script with confirmation
delete_script() {
    local script_path="$1"
    
    if [ ! -f "$script_path" ]; then
        echo -e "${RED}Error: Script not found: $script_path${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Are you sure you want to delete: ${CYAN}$(basename "$script_path")${NC}? (y/n)"
    read -r confirm
    
    if [ "$confirm" = "y" ]; then
        rm "$script_path"
        echo -e "${GREEN}Script deleted successfully!${NC}"
    else
        echo -e "${YELLOW}Deletion cancelled.${NC}"
    fi
}

# Create a new script
create_new_script() {
    local script_dir="$1"
    
    echo -e "${CYAN}Enter script name (without .sh):${NC} "
    read -r script_name
    
    if [ -z "$script_name" ]; then
        echo -e "${RED}Error: Script name cannot be empty${NC}"
        return 1
    fi
    
    local script_path="$script_dir/${script_name}.sh"
    
    if [ -f "$script_path" ]; then
        echo -e "${RED}Error: Script already exists: $script_path${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Enter script description:${NC} "
    read -r description
    
    # Create script with template
    cat > "$script_path" << EOL
#!/bin/bash

# Description: $description
# Created: $(date '+%Y-%m-%d %H:%M:%S')
# Author: Auto-Browser CLI

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BROWSER_WIDTH=900
BROWSER_HEIGHT=600

# Your script code here


EOL
    
    chmod +x "$script_path"
    echo -e "${GREEN}Script created successfully: $script_path${NC}"
    
    echo -e "\n${CYAN}Would you like to edit the script now? (y/n)${NC} "
    read -r edit_now
    
    if [ "$edit_now" = "y" ]; then
        edit_script "$script_path"
    fi
}

# Script management menu
script_management_menu() {
    while true; do
        show_banner
        echo -e "${YELLOW}=== Script Management ===${NC}\n"
        echo -e "1) List Scripts"
        echo -e "2) Create New Script"
        echo -e "3) Edit Script"
        echo -e "4) Delete Script"
        echo -e "5) Run Script"
        echo -e "6) View Script Details"
        echo -e "\n0) Back to Main Menu"
        
        echo -e "\n${CYAN}Select an option:${NC} "
        read -r choice

        case $choice in
            1)
                show_banner
                list_scripts "$SCRIPTS_DIR"
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read -r
                ;;
            2)
                show_banner
                create_new_script "$SCRIPTS_DIR"
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read -r
                ;;
            3)
                show_banner
                list_scripts "$SCRIPTS_DIR"
                echo -e "\n${CYAN}Enter script number to edit:${NC} "
                read -r script_num
                
                script_path=$(ls "$SCRIPTS_DIR"/*.sh 2>/dev/null | sed -n "${script_num}p")
                if [ -n "$script_path" ]; then
                    edit_script "$script_path"
                else
                    echo -e "${RED}Invalid script number${NC}"
                    sleep 2
                fi
                ;;
            4)
                show_banner
                list_scripts "$SCRIPTS_DIR"
                echo -e "\n${CYAN}Enter script number to delete:${NC} "
                read -r script_num
                
                script_path=$(ls "$SCRIPTS_DIR"/*.sh 2>/dev/null | sed -n "${script_num}p")
                if [ -n "$script_path" ]; then
                    delete_script "$script_path"
                else
                    echo -e "${RED}Invalid script number${NC}"
                    sleep 2
                fi
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read -r
                ;;
            5)
                show_banner
                list_scripts "$SCRIPTS_DIR"
                echo -e "\n${CYAN}Enter script number to run:${NC} "
                read -r script_num
                
                script_path=$(ls "$SCRIPTS_DIR"/*.sh 2>/dev/null | sed -n "${script_num}p")
                if [ -n "$script_path" ]; then
                    chmod +x "$script_path"
                    "$script_path"
                else
                    echo -e "${RED}Invalid script number${NC}"
                    sleep 2
                fi
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read -r
                ;;
            6)
                show_banner
                list_scripts "$SCRIPTS_DIR"
                echo -e "\n${CYAN}Enter script number to view details:${NC} "
                read -r script_num
                
                script_path=$(ls "$SCRIPTS_DIR"/*.sh 2>/dev/null | sed -n "${script_num}p")
                if [ -n "$script_path" ]; then
                    show_banner
                    echo -e "${YELLOW}=== Script Details ===${NC}\n"
                    echo -e "${CYAN}File:${NC} $(basename "$script_path")"
                    echo -e "${CYAN}Path:${NC} $script_path"
                    echo -e "${CYAN}Size:${NC} $(stat -f %z "$script_path") bytes"
                    echo -e "${CYAN}Created:${NC} $(stat -f %Sc "$script_path")"
                    echo -e "${CYAN}Modified:${NC} $(stat -f %Sm "$script_path")"
                    echo -e "${CYAN}Permissions:${NC} $(stat -f %Sp "$script_path")"
                    echo -e "\n${CYAN}First 10 lines:${NC}\n"
                    head -n 10 "$script_path"
                else
                    echo -e "${RED}Invalid script number${NC}"
                    sleep 2
                fi
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read -r
                ;;
            0) return;;
            *)
                echo -e "\n${RED}Invalid option. Please try again.${NC}"
                sleep 2
                ;;
        esac
    done
}
