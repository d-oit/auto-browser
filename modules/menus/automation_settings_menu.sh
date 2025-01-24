#!/bin/bash

# Update automation setting in config file
update_automation_setting() {
    local key=$1
    local value=$2
    local config_file="$CONFIG_FILE"
    
    if grep -q "^$key=" "$config_file"; then
        sed -i "s|^$key=.*|$key=$value|" "$config_file"
    else
        echo "$key=$value" >> "$config_file"
    fi
}

# Get current automation setting value
get_automation_setting() {
    local key=$1
    local config_file="$CONFIG_FILE"
    grep "^$key=" "$config_file" | cut -d'=' -f2 || echo ""
}

# Configure retry strategy
configure_retry_strategy() {
    show_banner
    echo -e "${YELLOW}=== Retry Strategy Configuration ===${NC}\n"
    
    local current_retries=$(get_automation_setting "MAX_RETRIES")
    local current_delay=$(get_automation_setting "RETRY_DELAY")
    
    echo -e "Current settings:"
    echo -e "Max Retries: ${CYAN}${current_retries:-3}${NC}"
    echo -e "Retry Delay: ${CYAN}${current_delay:-1000}ms${NC}\n"
    
    echo -e "${CYAN}Enter maximum number of retries (default: 3):${NC} "
    read -r retries
    
    echo -e "${CYAN}Enter delay between retries in milliseconds (default: 1000):${NC} "
    read -r delay
    
    retries=${retries:-3}
    delay=${delay:-1000}
    
    update_automation_setting "MAX_RETRIES" "$retries"
    update_automation_setting "RETRY_DELAY" "$delay"
    
    echo -e "\n${GREEN}Retry strategy updated successfully!${NC}"
}

# Configure selector strategy
configure_selector_strategy() {
    show_banner
    echo -e "${YELLOW}=== Selector Strategy Configuration ===${NC}\n"
    
    echo -e "1) XPath"
    echo -e "2) CSS"
    echo -e "3) Text"
    echo -e "4) Aria Label"
    echo -e "5) Custom"
    
    echo -e "\n${CYAN}Select primary selector strategy:${NC} "
    read -r choice
    
    case $choice in
        1) update_automation_setting "SELECTOR_STRATEGY" "xpath";;
        2) update_automation_setting "SELECTOR_STRATEGY" "css";;
        3) update_automation_setting "SELECTOR_STRATEGY" "text";;
        4) update_automation_setting "SELECTOR_STRATEGY" "aria";;
        5)
            echo -e "\n${CYAN}Enter custom selector strategy:${NC} "
            read -r custom_strategy
            update_automation_setting "SELECTOR_STRATEGY" "$custom_strategy"
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            return 1
            ;;
    esac
    
    echo -e "\n${GREEN}Selector strategy updated successfully!${NC}"
}

# Configure wait strategy
configure_wait_strategy() {
    show_banner
    echo -e "${YELLOW}=== Wait Strategy Configuration ===${NC}\n"
    
    local current_timeout=$(get_automation_setting "WAIT_TIMEOUT")
    local current_interval=$(get_automation_setting "WAIT_INTERVAL")
    
    echo -e "Current settings:"
    echo -e "Wait Timeout: ${CYAN}${current_timeout:-30000}ms${NC}"
    echo -e "Check Interval: ${CYAN}${current_interval:-500}ms${NC}\n"
    
    echo -e "${CYAN}Enter wait timeout in milliseconds (default: 30000):${NC} "
    read -r timeout
    
    echo -e "${CYAN}Enter check interval in milliseconds (default: 500):${NC} "
    read -r interval
    
    timeout=${timeout:-30000}
    interval=${interval:-500}
    
    update_automation_setting "WAIT_TIMEOUT" "$timeout"
    update_automation_setting "WAIT_INTERVAL" "$interval"
    
    echo -e "\n${GREEN}Wait strategy updated successfully!${NC}"
}

# Configure screenshot settings
configure_screenshot_settings() {
    show_banner
    echo -e "${YELLOW}=== Screenshot Configuration ===${NC}\n"
    
    local current_quality=$(get_automation_setting "SCREENSHOT_QUALITY")
    local current_type=$(get_automation_setting "SCREENSHOT_TYPE")
    
    echo -e "Current settings:"
    echo -e "Quality: ${CYAN}${current_quality:-80}%${NC}"
    echo -e "Type: ${CYAN}${current_type:-jpeg}${NC}\n"
    
    echo -e "${CYAN}Enter screenshot quality (1-100, default: 80):${NC} "
    read -r quality
    
    echo -e "${CYAN}Select screenshot type:${NC}"
    echo -e "1) JPEG (smaller size)"
    echo -e "2) PNG (better quality)"
    read -r type_choice
    
    quality=${quality:-80}
    case $type_choice in
        1) type="jpeg";;
        2) type="png";;
        *) type="jpeg";;
    esac
    
    update_automation_setting "SCREENSHOT_QUALITY" "$quality"
    update_automation_setting "SCREENSHOT_TYPE" "$type"
    
    echo -e "\n${GREEN}Screenshot settings updated successfully!${NC}"
}

# Configure error handling
configure_error_handling() {
    show_banner
    echo -e "${YELLOW}=== Error Handling Configuration ===${NC}\n"
    
    echo -e "1) Continue on Error"
    echo -e "2) Stop on Error"
    echo -e "3) Prompt on Error"
    
    echo -e "\n${CYAN}Select error handling strategy:${NC} "
    read -r choice
    
    case $choice in
        1) update_automation_setting "ERROR_HANDLING" "continue";;
        2) update_automation_setting "ERROR_HANDLING" "stop";;
        3) update_automation_setting "ERROR_HANDLING" "prompt";;
        *)
            echo -e "${RED}Invalid choice${NC}"
            return 1
            ;;
    esac
    
    echo -e "\n${GREEN}Error handling strategy updated successfully!${NC}"
}

# Automation settings menu
automation_settings_menu() {
    while true; do
        show_banner
        echo -e "${YELLOW}=== Automation Settings ===${NC}\n"
        echo -e "1) Configure Retry Strategy"
        echo -e "2) Configure Selector Strategy"
        echo -e "3) Configure Wait Strategy"
        echo -e "4) Configure Screenshot Settings"
        echo -e "5) Configure Error Handling"
        echo -e "6) Toggle Debug Mode"
        echo -e "7) Toggle Performance Logging"
        echo -e "8) Configure Custom Actions"
        echo -e "9) View Current Settings"
        echo -e "\n0) Back to Main Menu"
        
        echo -e "\n${CYAN}Select an option:${NC} "
        read -r choice

        case $choice in
            1) configure_retry_strategy;;
            2) configure_selector_strategy;;
            3) configure_wait_strategy;;
            4) configure_screenshot_settings;;
            5) configure_error_handling;;
            6)
                local current_debug=$(get_automation_setting "DEBUG_MODE")
                if [ "$current_debug" = "true" ]; then
                    update_automation_setting "DEBUG_MODE" "false"
                    echo -e "\n${GREEN}Debug mode disabled${NC}"
                else
                    update_automation_setting "DEBUG_MODE" "true"
                    echo -e "\n${GREEN}Debug mode enabled${NC}"
                fi
                sleep 1
                ;;
            7)
                local current_perf=$(get_automation_setting "PERFORMANCE_LOGGING")
                if [ "$current_perf" = "true" ]; then
                    update_automation_setting "PERFORMANCE_LOGGING" "false"
                    echo -e "\n${GREEN}Performance logging disabled${NC}"
                else
                    update_automation_setting "PERFORMANCE_LOGGING" "true"
                    echo -e "\n${GREEN}Performance logging enabled${NC}"
                fi
                sleep 1
                ;;
            8)
                show_banner
                echo -e "${YELLOW}=== Custom Actions Configuration ===${NC}\n"
                echo -e "${CYAN}Enter custom action name:${NC} "
                read -r action_name
                
                echo -e "${CYAN}Enter action script/command:${NC} "
                read -r action_script
                
                update_automation_setting "CUSTOM_ACTION_${action_name}" "$action_script"
                echo -e "\n${GREEN}Custom action added successfully!${NC}"
                sleep 1
                ;;
            9)
                show_banner
                echo -e "${YELLOW}=== Current Automation Settings ===${NC}\n"
                echo -e "${CYAN}Retry Strategy:${NC}"
                echo -e "  Max Retries: $(get_automation_setting "MAX_RETRIES")"
                echo -e "  Retry Delay: $(get_automation_setting "RETRY_DELAY")ms"
                echo -e "\n${CYAN}Selector Strategy:${NC} $(get_automation_setting "SELECTOR_STRATEGY")"
                echo -e "\n${CYAN}Wait Strategy:${NC}"
                echo -e "  Timeout: $(get_automation_setting "WAIT_TIMEOUT")ms"
                echo -e "  Interval: $(get_automation_setting "WAIT_INTERVAL")ms"
                echo -e "\n${CYAN}Screenshot Settings:${NC}"
                echo -e "  Quality: $(get_automation_setting "SCREENSHOT_QUALITY")%"
                echo -e "  Type: $(get_automation_setting "SCREENSHOT_TYPE")"
                echo -e "\n${CYAN}Error Handling:${NC} $(get_automation_setting "ERROR_HANDLING")"
                echo -e "${CYAN}Debug Mode:${NC} $(get_automation_setting "DEBUG_MODE")"
                echo -e "${CYAN}Performance Logging:${NC} $(get_automation_setting "PERFORMANCE_LOGGING")"
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
