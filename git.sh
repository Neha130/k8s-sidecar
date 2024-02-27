#!/bin/bash

# Set repository details
repo_url="$GIT_REPO"
local_path="$LOCAL_PATH"
discord_webhook_url="$discord_webhook"

# Create or update local repository
function clone_or_pull_repository {
    if [ -d "$local_path" ]; then
        # If the directory exists, pull changes
        echo "Pulling changes for existing repository..."
        cd "$local_path" || { echo "Directory not found"; exit 1; }
        git pull origin main
    else
        # If the directory doesn't exist, clone the repository
        echo "Cloning the repository for the first time..."
        mkdir -p "$local_path" || { echo "Failed to create directory"; exit 1; }
        git clone "$repo_url" "$local_path" || { echo "Clone failed"; exit 1; }
        cd "$local_path" || { echo "Directory not found"; exit 1; }
    fi
}
send_discord_alert() {                                                           
    message="this is an grafana alert"                                                         
    payload='{"content":"'${message}'"}'                     
                                              
    # Use curl to send a POST request to Discord webhook
    curl -H "Content-Type: application/json" -d "${payload}" "${discord_webhook_url}"
}    

# Initial clone or pull
clone_or_pull_repository

# Watch for changes and pull on new commits
while true; do
    # Fetch updates from the remote repository
    git fetch origin main

    # Compare local and remote commit hashes
    if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]; then
        echo "New commit detected. Pulling changes..."
        git pull origin main
       # cp -r ./* ../../git/grafana-dashbaord/devtron-provider-test
#       cp -r /share/grafana-dashboard/* ./git/grafana-dashbaord/devtron-provider-test 
    rsync -a --delete /tmp/share/grafana-dashboard/  /tmp/git/grafana-dashbaord/devtron-provider-test/
   

        # Check if changes were pulled
        if [ $? -eq 0 ]; then
            # If changes were pulled, perform additional actions
            echo "Changes pulled. Add your actions here."

            # Reload Grafana dashboards (example)
#            curl -X POST -u $REQ_USERNAME:$REQ_PASSWORD http://localhost:3000/api/admin/provisioning/dashboards/reload
             reload_response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -u $REQ_USERNAME:$REQ_PASSWORD $REQ_URL)
             echo "$reload_response"
        if [ "$reload_response" -eq 200 ]; then
            echo "Grafana dashboards reloaded successfully."
        else
            echo "Failed to reload Grafana dashboards. HTTP Status: $reload_response"

            # Send alert to Discord
            send_discord_alert "Failed to reload Grafana dashboards. HTTP Status: $reload_response"
        fi 
        else
            echo "No new commits in the repository."
        fi
    fi

    # Sleep for a specified interval (e.g., 1 minute)
    sleep $RELOAD_TIME
done
