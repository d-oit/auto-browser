#!/bin/bash

# Update OpenRouter setting in config file
update_openrouter_setting() {
    local key=$1
    local value=$2
    local config_file="$OPENROUTER_CONFIG"
    
    if grep -q "^$key:" "$config_file"; then
        sed -i "s|^$key:.*|$key: $value|" "$config_file"
    else
        echo "$key: $value" >> "$config_file"
    fi
}

# Get current OpenRouter setting value
get_openrouter_setting() {
    local key=$1
    local config_file="$OPENROUTER_CONFIG"
    grep "^$key:" "$config_file" | cut -d':' -f2 | tr -d ' ' || echo ""
}

# Configure OpenRouter API settings
configure_api_settings() {
    show_banner
    echo -e "${YELLOW}=== OpenRouter API Configuration ===${NC}\n"
    
    local current_key=$(get_openrouter_setting "api_key")
    local current_url=$(get_openrouter_setting "base_url")
    
    echo -e "Current settings:"
    echo -e "API Key: ${CYAN}${current_key:-Not set}${NC}"
    echo -e "Base URL: ${CYAN}${current_url:-https://openrouter.ai/api/v1}${NC}\n"
    
    echo -e "${CYAN}Enter OpenRouter API key (leave empty to keep current):${NC} "
    read -r api_key
    
    echo -e "${CYAN}Enter base URL (leave empty for default):${NC} "
    read -r base_url
    
    if [ -n "$api_key" ]; then
        update_openrouter_setting "api_key" "$api_key"
        # Also update in .env file
        sed -i "s|^OPENROUTER_API_KEY=.*|OPENROUTER_API_KEY=$api_key|" "$ENV_FILE"
    fi
    
    if [ -n "$base_url" ]; then
        update_openrouter_setting "base_url" "$base_url"
        # Also update in .env file
        sed -i "s|^OPENROUTER_BASE_URL=.*|OPENROUTER_BASE_URL=$base_url|" "$ENV_FILE"
    fi
    
    echo -e "\n${GREEN}API settings updated successfully!${NC}"
}

# Configure model settings
configure_model_settings() {
    show_banner
    echo -e "${YELLOW}=== Model Configuration ===${NC}\n"
    
    echo -e "1) Configure Automation Models"
    echo -e "2) Configure Scraping Models"
    echo -e "3) Configure Custom Models"
    
    echo -e "\n${CYAN}Select option:${NC} "
    read -r choice
    
    case $choice in
        1)
            show_banner
            echo -e "${YELLOW}=== Automation Models ===${NC}\n"
            echo -e "Available models:"
            echo -e "1) anthropic/claude-3-opus"
            echo -e "2) anthropic/claude-3-sonnet"
            echo -e "3) google/gemini-pro"
            echo -e "4) openai/gpt-4-turbo"
            echo -e "5) Custom model"
            
            echo -e "\n${CYAN}Select model:${NC} "
            read -r model_choice
            
            case $model_choice in
                1) model="anthropic/claude-3-opus";;
                2) model="anthropic/claude-3-sonnet";;
                3) model="google/gemini-pro";;
                4) model="openai/gpt-4-turbo";;
                5)
                    echo -e "\n${CYAN}Enter custom model identifier:${NC} "
                    read -r model
                    ;;
                *)
                    echo -e "${RED}Invalid choice${NC}"
                    return 1
                    ;;
            esac
            
            update_openrouter_setting "models.browser.automation[0]" "$model"
            ;;
        2)
            show_banner
            echo -e "${YELLOW}=== Scraping Models ===${NC}\n"
            echo -e "Available models:"
            echo -e "1) anthropic/claude-3-opus"
            echo -e "2) anthropic/claude-3-sonnet"
            echo -e "3) google/gemini-pro"
            echo -e "4) openai/gpt-4-turbo"
            echo -e "5) Custom model"
            
            echo -e "\n${CYAN}Select model:${NC} "
            read -r model_choice
            
            case $model_choice in
                1) model="anthropic/claude-3-opus";;
                2) model="anthropic/claude-3-sonnet";;
                3) model="google/gemini-pro";;
                4) model="openai/gpt-4-turbo";;
                5)
                    echo -e "\n${CYAN}Enter custom model identifier:${NC} "
                    read -r model
                    ;;
                *)
                    echo -e "${RED}Invalid choice${NC}"
                    return 1
                    ;;
            esac
            
            update_openrouter_setting "models.browser.scraping[0]" "$model"
            ;;
        3)
            show_banner
            echo -e "${YELLOW}=== Custom Model Configuration ===${NC}\n"
            echo -e "${CYAN}Enter model category:${NC} "
            read -r category
            
            echo -e "${CYAN}Enter model identifier:${NC} "
            read -r model
            
            update_openrouter_setting "models.browser.${category}[0]" "$model"
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            return 1
            ;;
    esac
    
    echo -e "\n${GREEN}Model settings updated successfully!${NC}"
}

# Configure model parameters
configure_model_parameters() {
    show_banner
    echo -e "${YELLOW}=== Model Parameters ===${NC}\n"
    
    local current_temp=$(get_openrouter_setting "parameters.temperature")
    local current_tokens=$(get_openrouter_setting "parameters.max_tokens")
    
    echo -e "Current settings:"
    echo -e "Temperature: ${CYAN}${current_temp:-0.7}${NC}"
    echo -e "Max Tokens: ${CYAN}${current_tokens:-2000}${NC}\n"
    
    echo -e "${CYAN}Enter temperature (0.0-1.0, default: 0.7):${NC} "
    read -r temp
    
    echo -e "${CYAN}Enter max tokens (default: 2000):${NC} "
    read -r tokens
    
    temp=${temp:-0.7}
    tokens=${tokens:-2000}
    
    update_openrouter_setting "parameters.temperature" "$temp"
    update_openrouter_setting "parameters.max_tokens" "$tokens"
    
    echo -e "\n${GREEN}Model parameters updated successfully!${NC}"
}

# OpenRouter settings menu
openrouter_settings_menu() {
    while true; do
        show_banner
        echo -e "${YELLOW}=== OpenRouter Settings ===${NC}\n"
        echo -e "1) Configure API Settings"
        echo -e "2) Configure Model Settings"
        echo -e "3) Configure Model Parameters"
        echo -e "4) Test Connection"
        echo -e "5) View Current Settings"
        echo -e "\n0) Back to Main Menu"
        
        echo -e "\n${CYAN}Select an option:${NC} "
        read -r choice

        case $choice in
            1) configure_api_settings;;
            2) configure_model_settings;;
            3) configure_model_parameters;;
            4)
                show_banner
                echo -e "${YELLOW}=== Testing OpenRouter Connection ===${NC}\n"
                
                if [ -z "$(get_openrouter_setting "api_key")" ]; then
                    echo -e "${RED}Error: API key not configured${NC}"
                    sleep 2
                    continue
                fi
                
                echo -e "${CYAN}Testing connection...${NC}\n"
                
                # Test connection using curl
                response=$(curl -s -H "Authorization: Bearer $(get_openrouter_setting "api_key")" \
                    "$(get_openrouter_setting "base_url")/models")
                
                if echo "$response" | grep -q "error"; then
                    echo -e "${RED}Connection failed:${NC}"
                    echo "$response" | jq -r '.error.message' 2>/dev/null || echo "$response"
                else
                    echo -e "${GREEN}Connection successful!${NC}"
                    echo -e "\nAvailable models:"
                    echo "$response" | jq -r '.data[].id' 2>/dev/null || echo "$response"
                fi
                
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read -r
                ;;
            5)
                show_banner
                echo -e "${YELLOW}=== Current OpenRouter Settings ===${NC}\n"
                echo -e "${CYAN}API Settings:${NC}"
                echo -e "  API Key: $(get_openrouter_setting "api_key")"
                echo -e "  Base URL: $(get_openrouter_setting "base_url")"
                echo -e "\n${CYAN}Model Settings:${NC}"
                echo -e "  Automation: $(get_openrouter_setting "models.browser.automation[0]")"
                echo -e "  Scraping: $(get_openrouter_setting "models.browser.scraping[0]")"
                echo -e "\n${CYAN}Parameters:${NC}"
                echo -e "  Temperature: $(get_openrouter_setting "parameters.temperature")"
                echo -e "  Max Tokens: $(get_openrouter_setting "parameters.max_tokens")"
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
