#!/bin/bash

# Display quick start guide
show_quick_start() {
    show_banner
    echo -e "${YELLOW}=== Quick Start Guide ===${NC}\n"
    
    echo -e "${CYAN}1. Basic Setup${NC}"
    echo -e "   - Configure browser settings (Menu > Browser Settings)"
    echo -e "   - Set up automation preferences (Menu > Automation Settings)"
    echo -e "   - Configure OpenRouter API (Menu > OpenRouter Settings)\n"
    
    echo -e "${CYAN}2. Running Your First Automation${NC}"
    echo -e "   - Use the Demo Menu to try example scripts"
    echo -e "   - Learn from pre-built automation examples"
    echo -e "   - Understand basic browser interactions\n"
    
    echo -e "${CYAN}3. Creating Custom Scripts${NC}"
    echo -e "   - Use Script Management to create new scripts"
    echo -e "   - Follow templates and best practices"
    echo -e "   - Test and debug your automations\n"
    
    echo -e "${CYAN}4. Advanced Features${NC}"
    echo -e "   - Multi-tab operations"
    echo -e "   - Parallel processing"
    echo -e "   - Custom actions and workflows\n"
    
    echo -e "${CYAN}Press Enter to continue...${NC}"
    read -r
}

# Display troubleshooting guide
show_troubleshooting() {
    show_banner
    echo -e "${YELLOW}=== Troubleshooting Guide ===${NC}\n"
    
    echo -e "${CYAN}Common Issues:${NC}\n"
    
    echo -e "1. ${YELLOW}Browser Not Launching${NC}"
    echo -e "   - Check browser settings configuration"
    echo -e "   - Verify Chrome/Chromium installation"
    echo -e "   - Ensure no conflicting instances\n"
    
    echo -e "2. ${YELLOW}Selector Errors${NC}"
    echo -e "   - Verify element selectors"
    echo -e "   - Check page load completion"
    echo -e "   - Try alternative selector strategies\n"
    
    echo -e "3. ${YELLOW}Timeout Issues${NC}"
    echo -e "   - Adjust wait timeouts"
    echo -e "   - Check network connectivity"
    echo -e "   - Verify page response times\n"
    
    echo -e "4. ${YELLOW}Script Failures${NC}"
    echo -e "   - Check error logs"
    echo -e "   - Enable debug mode"
    echo -e "   - Verify script syntax\n"
    
    echo -e "${CYAN}Press Enter to continue...${NC}"
    read -r
}

# Display keyboard shortcuts
show_keyboard_shortcuts() {
    show_banner
    echo -e "${YELLOW}=== Keyboard Shortcuts ===${NC}\n"
    
    echo -e "${CYAN}Navigation${NC}"
    echo -e "ESC        Return to previous menu"
    echo -e "Q          Quit current view"
    echo -e "H          Show help"
    echo -e "B          Back to main menu\n"
    
    echo -e "${CYAN}Script Management${NC}"
    echo -e "Ctrl+N     New script"
    echo -e "Ctrl+E     Edit script"
    echo -e "Ctrl+S     Save script"
    echo -e "Ctrl+R     Run script\n"
    
    echo -e "${CYAN}Automation Control${NC}"
    echo -e "Ctrl+P     Pause automation"
    echo -e "Ctrl+C     Stop automation"
    echo -e "Ctrl+D     Enable debug mode"
    echo -e "Ctrl+L     View logs\n"
    
    echo -e "${CYAN}Press Enter to continue...${NC}"
    read -r
}

# Display command reference
show_command_reference() {
    show_banner
    echo -e "${YELLOW}=== Command Reference ===${NC}\n"
    
    echo -e "${CYAN}Basic Commands${NC}"
    echo -e "start         Start the application"
    echo -e "stop          Stop running automations"
    echo -e "status        Check automation status"
    echo -e "version       Display version info\n"
    
    echo -e "${CYAN}Script Commands${NC}"
    echo -e "new           Create new script"
    echo -e "edit          Edit existing script"
    echo -e "run           Execute script"
    echo -e "list          List available scripts\n"
    
    echo -e "${CYAN}Configuration Commands${NC}"
    echo -e "config        Edit configuration"
    echo -e "reset         Reset to defaults"
    echo -e "import        Import settings"
    echo -e "export        Export settings\n"
    
    echo -e "${CYAN}Utility Commands${NC}"
    echo -e "logs          View log files"
    echo -e "clean         Clean temporary files"
    echo -e "update        Update application"
    echo -e "help          Show this help\n"
    
    echo -e "${CYAN}Press Enter to continue...${NC}"
    read -r
}

# Display FAQ
show_faq() {
    show_banner
    echo -e "${YELLOW}=== Frequently Asked Questions ===${NC}\n"
    
    echo -e "${CYAN}Q: How do I get started?${NC}"
    echo -e "A: Begin with the Quick Start guide and try the demo scripts to understand basic functionality.\n"
    
    echo -e "${CYAN}Q: Can I automate multiple browsers?${NC}"
    echo -e "A: Yes, you can run parallel automations using the --parallel flag or configure multi-browser settings.\n"
    
    echo -e "${CYAN}Q: How do I handle dynamic content?${NC}"
    echo -e "A: Use wait strategies and configure appropriate timeouts in automation settings.\n"
    
    echo -e "${CYAN}Q: Where are logs stored?${NC}"
    echo -e "A: Logs are stored in the logs/ directory, organized by date and type.\n"
    
    echo -e "${CYAN}Q: How do I create custom actions?${NC}"
    echo -e "A: Use the Automation Settings menu to configure and manage custom actions.\n"
    
    echo -e "${CYAN}Q: Can I schedule automations?${NC}"
    echo -e "A: Yes, use the built-in scheduler or system cron jobs to schedule script execution.\n"
    
    echo -e "${CYAN}Press Enter to continue...${NC}"
    read -r
}

# Display about information
show_about() {
    show_banner
    echo -e "${YELLOW}=== About Auto-Browser ===${NC}\n"
    
    echo -e "${CYAN}Version:${NC} $(get_version)"
    echo -e "${CYAN}Author:${NC} Your Name"
    echo -e "${CYAN}License:${NC} MIT\n"
    
    echo -e "${CYAN}Description:${NC}"
    echo -e "Auto-Browser is a powerful browser automation tool that combines"
    echo -e "Puppeteer with AI capabilities through OpenRouter integration.\n"
    
    echo -e "${CYAN}Features:${NC}"
    echo -e "- Browser automation and control"
    echo -e "- AI-powered interactions"
    echo -e "- Parallel processing support"
    echo -e "- Extensive customization options"
    echo -e "- Comprehensive logging system\n"
    
    echo -e "${CYAN}Resources:${NC}"
    echo -e "Documentation: https://github.com/yourusername/auto-browser/docs"
    echo -e "Issues: https://github.com/yourusername/auto-browser/issues"
    echo -e "Wiki: https://github.com/yourusername/auto-browser/wiki\n"
    
    echo -e "${CYAN}Press Enter to continue...${NC}"
    read -r
}

# Help menu
help_menu() {
    while true; do
        show_banner
        echo -e "${YELLOW}=== Help & Documentation ===${NC}\n"
        echo -e "1) Quick Start Guide"
        echo -e "2) Troubleshooting"
        echo -e "3) Keyboard Shortcuts"
        echo -e "4) Command Reference"
        echo -e "5) FAQ"
        echo -e "6) About"
        echo -e "\n0) Back to Main Menu"
        
        echo -e "\n${CYAN}Select an option:${NC} "
        read -r choice

        case $choice in
            1) show_quick_start;;
            2) show_troubleshooting;;
            3) show_keyboard_shortcuts;;
            4) show_command_reference;;
            5) show_faq;;
            6) show_about;;
            0) return;;
            *)
                echo -e "\n${RED}Invalid option. Please try again.${NC}"
                sleep 2
                ;;
        esac
    done
}
