#!/bin/bash

# Source all menu modules
source "modules/menus/browser_settings_menu.sh"
source "modules/menus/automation_settings_menu.sh"
source "modules/menus/openrouter_settings_menu.sh"
source "modules/menus/script_management_menu.sh"
source "modules/menus/demo_menu.sh"
source "modules/menus/logs_menu.sh"
source "modules/menus/help_menu.sh"

# Display welcome message
show_welcome() {
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
    echo -e "${CYAN}Version:${NC} $(get_version)"
    echo -e "${CYAN}Author:${NC} Your Name"
    echo -e "${CYAN}License:${NC} MIT\n"
}

# Initialize application
initialize_app() {
    # Create required directories
    mkdir -p logs exports scripts templates
    
    # Initialize config files if they don't exist
    if [ ! -f "$CONFIG_FILE" ]; then
        cp config.example.yaml "$CONFIG_FILE"
    fi
    
    if [ ! -f "$ENV_FILE" ]; then
        cp .env.example "$ENV_FILE"
    fi
    
    if [ ! -f "$OPENROUTER_CONFIG" ]; then
        echo "api_key: " > "$OPENROUTER_CONFIG"
        echo "base_url: https://openrouter.ai/api/v1" >> "$OPENROUTER_CONFIG"
    fi
}

# Display status information
show_status() {
    show_banner
    echo -e "${YELLOW}=== System Status ===${NC}\n"
    
    # Check configuration
    echo -e "\n${CYAN}Configuration:${NC}"
    echo -e "Config File: $([ -f "$CONFIG_FILE" ] && echo "${GREEN}OK${NC}" || echo "${RED}Missing${NC}")"
    echo -e "Env File: $([ -f "$ENV_FILE" ] && echo "${GREEN}OK${NC}" || echo "${RED}Missing${NC}")"
    echo -e "OpenRouter Config: $([ -f "$OPENROUTER_CONFIG" ] && echo "${GREEN}OK${NC}" || echo "${RED}Missing${NC}")"
    
    # Check directories
    echo -e "\n${CYAN}Directories:${NC}"
    echo -e "Logs: $([ -d "logs" ] && echo "${GREEN}OK${NC}" || echo "${RED}Missing${NC}")"
    echo -e "Scripts: $([ -d "scripts" ] && echo "${GREEN}OK${NC}" || echo "${RED}Missing${NC}")"
    echo -e "Templates: $([ -d "templates" ] && echo "${GREEN}OK${NC}" || echo "${RED}Missing${NC}")"
    
    # Check OpenRouter connection
    echo -e "\n${CYAN}OpenRouter Connection:${NC}"
    if [ -n "$(get_openrouter_setting "api_key")" ]; then
        response=$(curl -s -H "Authorization: Bearer $(get_openrouter_setting "api_key")" \
            "$(get_openrouter_setting "base_url")/models")
        if echo "$response" | grep -q "error"; then
            echo -e "${RED}Failed${NC}"
        else
            echo -e "${GREEN}Connected${NC}"
        fi
    else
        echo -e "${YELLOW}Not Configured${NC}"
    fi
    
    echo -e "\n${CYAN}Press Enter to continue...${NC}"
    read -r
}

# Main menu
main_menu() {
    # Initialize application
    initialize_app
    
    while true; do
        show_welcome
        echo -e "${YELLOW}=== Main Menu ===${NC}\n"
        echo -e "1) Browser Settings"
        echo -e "2) Automation Settings"
        echo -e "3) OpenRouter Settings"
        echo -e "4) Script Management"
        echo -e "5) Demo Scripts"
        echo -e "6) View Logs"
        echo -e "7) Help & Documentation"
        echo -e "8) System Status"
        echo -e "\n0) Exit"
        
        echo -e "\n${CYAN}Select an option:${NC} "
        read -r choice

        case $choice in
            1) browser_settings_menu;;
            2) automation_settings_menu;;
            3) openrouter_settings_menu;;
            4) script_management_menu;;
            5) demo_menu;;
            6) logs_menu;;
            7) help_menu;;
            8) show_status;;
            0)
                echo -e "\n${GREEN}Thank you for using Auto-Browser!${NC}"
                exit 0
                ;;
            *)
                echo -e "\n${RED}Invalid option. Please try again.${NC}"
                sleep 2
                ;;
        esac
    done
}
