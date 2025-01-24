#!/bin/bash

# Run demo script
run_demo() {
    local script_path=$1
    
    if [ ! -f "$script_path" ]; then
        echo -e "${RED}Error: Demo script not found: $script_path${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Running demo: $(basename "$script_path")${NC}\n"
    
    chmod +x "$script_path"
    "$script_path"
}

# Demo menu
demo_menu() {
    while true; do
        show_banner
        echo -e "${YELLOW}=== Demo Scripts ===${NC}\n"
        echo -e "1) Basic Setup"
        echo -e "2) Simple Search"
        echo -e "3) Multi-tab Operations"
        echo -e "4) Form Interaction"
        echo -e "5) Parallel Tasks"
        echo -e "6) Clinical Trials"
        echo -e "7) Movie Reviews"
        echo -e "8) Advanced Automation"
        echo -e "9) Timesheet Automation"
        echo -e "10) Social Media Campaign"
        echo -e "11) Research Workflow"
        echo -e "12) Project Management"
        echo -e "\n0) Back to Main Menu"
        
        echo -e "\n${CYAN}Select a demo:${NC} "
        read -r choice

        case $choice in
            1) run_demo "demos/01_basic_setup.sh";;
            2) run_demo "demos/02_simple_search.sh";;
            3) run_demo "demos/03_multi_tab.sh";;
            4) run_demo "demos/04_form_interaction.sh";;
            5) run_demo "demos/05_parallel_tasks.sh";;
            6) run_demo "demos/06_clinical_trials.sh";;
            7) run_demo "demos/06_movie_reviews.sh";;
            8) run_demo "demos/07_advanced_automation.sh";;
            9) run_demo "demos/07_timesheet_automation.sh";;
            10) run_demo "demos/08_social_media_campaign.sh";;
            11) run_demo "demos/09_research_workflow.sh";;
            12) run_demo "demos/10_project_management.sh";;
            0) return;;
            *)
                echo -e "\n${RED}Invalid option. Please try again.${NC}"
                sleep 2
                ;;
        esac
        
        if [ $? -eq 0 ]; then
            echo -e "\n${GREEN}Demo completed successfully!${NC}"
        else
            echo -e "\n${RED}Demo failed. Check logs for details.${NC}"
        fi
        
        echo -e "\n${CYAN}Press Enter to continue...${NC}"
        read -r
    done
}
