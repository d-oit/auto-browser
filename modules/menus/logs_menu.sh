#!/bin/bash

# Get log file path
get_log_file() {
    local log_type=$1
    local date_str=$(date +%Y%m%d)
    
    case $log_type in
        browser) echo "logs/browser_${date_str}.log";;
        automation) echo "logs/automation_${date_str}.log";;
        error) echo "logs/error_${date_str}.log";;
        performance) echo "logs/performance_${date_str}.log";;
        *) echo "logs/general_${date_str}.log";;
    esac
}

# View log file with paging
view_log() {
    local log_file=$1
    local lines=${2:-50}  # Default to last 50 lines
    
    if [ ! -f "$log_file" ]; then
        echo -e "${RED}Log file not found: $log_file${NC}"
        return 1
    fi
    
    show_banner
    echo -e "${YELLOW}=== Viewing Log: $(basename "$log_file") ===${NC}\n"
    echo -e "${CYAN}Last $lines lines:${NC}\n"
    
    tail -n "$lines" "$log_file" | less -R
}

# Clear log file
clear_log() {
    local log_file=$1
    
    if [ ! -f "$log_file" ]; then
        echo -e "${RED}Log file not found: $log_file${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Are you sure you want to clear: ${CYAN}$(basename "$log_file")${NC}? (y/n)"
    read -r confirm
    
    if [ "$confirm" = "y" ]; then
        > "$log_file"
        echo -e "${GREEN}Log file cleared successfully!${NC}"
    else
        echo -e "${YELLOW}Operation cancelled.${NC}"
    fi
}

# Search logs
search_logs() {
    show_banner
    echo -e "${YELLOW}=== Search Logs ===${NC}\n"
    
    echo -e "${CYAN}Enter search term:${NC} "
    read -r search_term
    
    if [ -z "$search_term" ]; then
        echo -e "${RED}Search term cannot be empty${NC}"
        return 1
    fi
    
    echo -e "\n${CYAN}Searching logs for: ${YELLOW}$search_term${NC}\n"
    
    # Search all log files
    find logs -type f -name "*.log" -exec sh -c "echo -e '${YELLOW}=== {} ===${NC}' && grep --color=always -i '$search_term' {}" \;
    
    echo -e "\n${CYAN}Search complete. Press Enter to continue...${NC}"
    read -r
}

# Export logs
export_logs() {
    show_banner
    echo -e "${YELLOW}=== Export Logs ===${NC}\n"
    
    local export_dir="exports/logs_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$export_dir"
    
    echo -e "${CYAN}Exporting logs to: $export_dir${NC}\n"
    
    # Copy all log files to export directory
    find logs -type f -name "*.log" -exec cp {} "$export_dir/" \;
    
    # Create a summary file
    {
        echo "Log Export Summary"
        echo "================="
        echo "Date: $(date)"
        echo
        echo "Files exported:"
        ls -lh "$export_dir"
    } > "$export_dir/summary.txt"
    
    # Create zip archive
    local zip_file="${export_dir}.zip"
    zip -r "$zip_file" "$export_dir" >/dev/null
    
    echo -e "${GREEN}Logs exported successfully!${NC}"
    echo -e "Archive: ${CYAN}$zip_file${NC}"
    echo -e "\n${CYAN}Press Enter to continue...${NC}"
    read -r
}

# Configure log rotation
configure_log_rotation() {
    show_banner
    echo -e "${YELLOW}=== Log Rotation Configuration ===${NC}\n"
    
    echo -e "Current settings:"
    echo -e "Max Size: ${CYAN}$(get_automation_setting "LOG_MAX_SIZE")${NC}"
    echo -e "Max Files: ${CYAN}$(get_automation_setting "LOG_MAX_FILES")${NC}\n"
    
    echo -e "${CYAN}Enter maximum log file size in MB (default: 10):${NC} "
    read -r max_size
    
    echo -e "${CYAN}Enter maximum number of log files to keep (default: 5):${NC} "
    read -r max_files
    
    max_size=${max_size:-10}
    max_files=${max_files:-5}
    
    update_automation_setting "LOG_MAX_SIZE" "$max_size"
    update_automation_setting "LOG_MAX_FILES" "$max_files"
    
    echo -e "\n${GREEN}Log rotation settings updated successfully!${NC}"
}

# View logs menu
view_logs_menu() {
    while true; do
        show_banner
        echo -e "${YELLOW}=== View Logs ===${NC}\n"
        echo -e "1) Browser Logs"
        echo -e "2) Automation Logs"
        echo -e "3) Error Logs"
        echo -e "4) Performance Logs"
        echo -e "5) General Logs"
        echo -e "\n0) Back"
        
        echo -e "\n${CYAN}Select log type:${NC} "
        read -r choice
        
        case $choice in
            1) view_log "$(get_log_file browser)";;
            2) view_log "$(get_log_file automation)";;
            3) view_log "$(get_log_file error)";;
            4) view_log "$(get_log_file performance)";;
            5) view_log "$(get_log_file general)";;
            0) return;;
            *)
                echo -e "\n${RED}Invalid option. Please try again.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Clear logs menu
clear_logs_menu() {
    while true; do
        show_banner
        echo -e "${YELLOW}=== Clear Logs ===${NC}\n"
        echo -e "1) Browser Logs"
        echo -e "2) Automation Logs"
        echo -e "3) Error Logs"
        echo -e "4) Performance Logs"
        echo -e "5) General Logs"
        echo -e "6) All Logs"
        echo -e "\n0) Back"
        
        echo -e "\n${CYAN}Select log type:${NC} "
        read -r choice
        
        case $choice in
            1) clear_log "$(get_log_file browser)";;
            2) clear_log "$(get_log_file automation)";;
            3) clear_log "$(get_log_file error)";;
            4) clear_log "$(get_log_file performance)";;
            5) clear_log "$(get_log_file general)";;
            6)
                echo -e "${YELLOW}Are you sure you want to clear ALL log files? (y/n)${NC}"
                read -r confirm
                if [ "$confirm" = "y" ]; then
                    rm -f logs/*.log
                    echo -e "${GREEN}All log files cleared successfully!${NC}"
                else
                    echo -e "${YELLOW}Operation cancelled.${NC}"
                fi
                ;;
            0) return;;
            *)
                echo -e "\n${RED}Invalid option. Please try again.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Logs menu
logs_menu() {
    while true; do
        show_banner
        echo -e "${YELLOW}=== Logs Management ===${NC}\n"
        echo -e "1) View Logs"
        echo -e "2) Clear Logs"
        echo -e "3) Search Logs"
        echo -e "4) Export Logs"
        echo -e "5) Configure Log Rotation"
        echo -e "\n0) Back to Main Menu"
        
        echo -e "\n${CYAN}Select an option:${NC} "
        read -r choice

        case $choice in
            1) view_logs_menu;;
            2) clear_logs_menu;;
            3) search_logs;;
            4) export_logs;;
            5) configure_log_rotation;;
            0) return;;
            *)
                echo -e "\n${RED}Invalid option. Please try again.${NC}"
                sleep 2
                ;;
        esac
    done
}
