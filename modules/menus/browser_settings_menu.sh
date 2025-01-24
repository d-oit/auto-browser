#!/bin/bash

# Update browser setting in config file
update_browser_setting() {
    local key=$1
    local value=$2
    local config_file="$CONFIG_FILE"
    
    if grep -q "^$key=" "$config_file"; then
        sed -i "s|^$key=.*|$key=$value|" "$config_file"
    else
        echo "$key=$value" >> "$config_file"
    fi
}

# Get current browser setting value
get_browser_setting() {
    local key=$1
    local config_file="$CONFIG_FILE"
    grep "^$key=" "$config_file" | cut -d'=' -f2 || echo ""
}

# Toggle boolean browser setting
toggle_browser_setting() {
    local key=$1
    local current=$(get_browser_setting "$key")
    
    if [ "$current" = "true" ]; then
        update_browser_setting "$key" "false"
    else
        update_browser_setting "$key" "true"
    fi
}

# Configure browser dimensions
configure_dimensions() {
    show_banner
    echo -e "${YELLOW}=== Browser Dimensions ===${NC}\n"
    
    local current_width=$(get_browser_setting "BROWSER_WIDTH")
    local current_height=$(get_browser_setting "BROWSER_HEIGHT")
    
    echo -e "Current dimensions: ${CYAN}${current_width}x${current_height}${NC}\n"
    
    echo -e "${CYAN}Enter browser width (default: 900):${NC} "
    read -r width
    
    echo -e "${CYAN}Enter browser height (default: 600):${NC} "
    read -r height
    
    width=${width:-900}
    height=${height:-600}
    
    update_browser_setting "BROWSER_WIDTH" "$width"
    update_browser_setting "BROWSER_HEIGHT" "$height"
    
    echo -e "\n${GREEN}Browser dimensions updated to: ${width}x${height}${NC}"
}

# Configure browser timeout settings
configure_timeouts() {
    show_banner
    echo -e "${YELLOW}=== Browser Timeouts ===${NC}\n"
    
    local current_nav_timeout=$(get_browser_setting "NAVIGATION_TIMEOUT")
    local current_script_timeout=$(get_browser_setting "SCRIPT_TIMEOUT")
    
    echo -e "Current timeouts:"
    echo -e "Navigation: ${CYAN}${current_nav_timeout:-30000}ms${NC}"
    echo -e "Script: ${CYAN}${current_script_timeout:-30000}ms${NC}\n"
    
    echo -e "${CYAN}Enter navigation timeout in milliseconds (default: 30000):${NC} "
    read -r nav_timeout
    
    echo -e "${CYAN}Enter script timeout in milliseconds (default: 30000):${NC} "
    read -r script_timeout
    
    nav_timeout=${nav_timeout:-30000}
    script_timeout=${script_timeout:-30000}
    
    update_browser_setting "NAVIGATION_TIMEOUT" "$nav_timeout"
    update_browser_setting "SCRIPT_TIMEOUT" "$script_timeout"
    
    echo -e "\n${GREEN}Browser timeouts updated successfully!${NC}"
}

# Configure browser user agent
configure_user_agent() {
    show_banner
    echo -e "${YELLOW}=== Browser User Agent ===${NC}\n"
    
    local current_ua=$(get_browser_setting "USER_AGENT")
    
    echo -e "Current user agent: ${CYAN}${current_ua:-Default}${NC}\n"
    
    echo -e "1) Use default"
    echo -e "2) Chrome Desktop"
    echo -e "3) Firefox Desktop"
    echo -e "4) Safari Desktop"
    echo -e "5) Mobile Chrome"
    echo -e "6) Mobile Safari"
    echo -e "7) Custom"
    
    echo -e "\n${CYAN}Select user agent:${NC} "
    read -r choice
    
    case $choice in
        1) update_browser_setting "USER_AGENT" "";;
        2) update_browser_setting "USER_AGENT" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36";;
        3) update_browser_setting "USER_AGENT" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0";;
        4) update_browser_setting "USER_AGENT" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15";;
        5) update_browser_setting "USER_AGENT" "Mozilla/5.0 (Linux; Android 10; SM-G981B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.162 Mobile Safari/537.36";;
        6) update_browser_setting "USER_AGENT" "Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Mobile/15E148 Safari/604.1";;
        7)
            echo -e "\n${CYAN}Enter custom user agent:${NC} "
            read -r custom_ua
            update_browser_setting "USER_AGENT" "$custom_ua"
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            return 1
            ;;
    esac
    
    echo -e "\n${GREEN}User agent updated successfully!${NC}"
}

# Browser settings menu
browser_settings_menu() {
    while true; do
        show_banner
        echo -e "${YELLOW}=== Browser Settings ===${NC}\n"
        echo -e "1) Toggle Headless Mode"
        echo -e "2) Configure Browser Dimensions"
        echo -e "3) Configure Timeouts"
        echo -e "4) Configure User Agent"
        echo -e "5) Toggle JavaScript"
        echo -e "6) Toggle Images"
        echo -e "7) Toggle CSS"
        echo -e "8) Configure Proxy"
        echo -e "9) View Current Settings"
        echo -e "\n0) Back to Main Menu"
        
        echo -e "\n${CYAN}Select an option:${NC} "
        read -r choice

        case $choice in
            1) 
                toggle_browser_setting "BROWSER_HEADLESS"
                echo -e "\n${GREEN}Headless mode toggled!${NC}"
                sleep 1
                ;;
            2) configure_dimensions;;
            3) configure_timeouts;;
            4) configure_user_agent;;
            5)
                toggle_browser_setting "BROWSER_JAVASCRIPT"
                echo -e "\n${GREEN}JavaScript toggled!${NC}"
                sleep 1
                ;;
            6)
                toggle_browser_setting "BROWSER_IMAGES"
                echo -e "\n${GREEN}Images toggled!${NC}"
                sleep 1
                ;;
            7)
                toggle_browser_setting "BROWSER_CSS"
                echo -e "\n${GREEN}CSS toggled!${NC}"
                sleep 1
                ;;
            8)
                show_banner
                echo -e "${YELLOW}=== Proxy Configuration ===${NC}\n"
                echo -e "${CYAN}Enter proxy URL (e.g., http://proxy:8080) or empty to disable:${NC} "
                read -r proxy_url
                update_browser_setting "BROWSER_PROXY" "$proxy_url"
                echo -e "\n${GREEN}Proxy settings updated!${NC}"
                sleep 1
                ;;
            9)
                show_banner
                echo -e "${YELLOW}=== Current Browser Settings ===${NC}\n"
                echo -e "${CYAN}Headless Mode:${NC} $(get_browser_setting "BROWSER_HEADLESS")"
                echo -e "${CYAN}Dimensions:${NC} $(get_browser_setting "BROWSER_WIDTH")x$(get_browser_setting "BROWSER_HEIGHT")"
                echo -e "${CYAN}Navigation Timeout:${NC} $(get_browser_setting "NAVIGATION_TIMEOUT")ms"
                echo -e "${CYAN}Script Timeout:${NC} $(get_browser_setting "SCRIPT_TIMEOUT")ms"
                echo -e "${CYAN}User Agent:${NC} $(get_browser_setting "USER_AGENT")"
                echo -e "${CYAN}JavaScript:${NC} $(get_browser_setting "BROWSER_JAVASCRIPT")"
                echo -e "${CYAN}Images:${NC} $(get_browser_setting "BROWSER_IMAGES")"
                echo -e "${CYAN}CSS:${NC} $(get_browser_setting "BROWSER_CSS")"
                echo -e "${CYAN}Proxy:${NC} $(get_browser_setting "BROWSER_PROXY")"
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
