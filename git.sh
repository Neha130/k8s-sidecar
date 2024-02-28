#!/bin/bash

repo_url="$GIT_REPO"
local_path="$LOCAL_PATH"
discord_webhook_url="$discord_webhook"

clone_or_pull_repository {
    # if [ -d "$local_path" ]; then
    #     # If the directory exists, pull changes
    #     echo "Pulling changes for existing repository..."
    #     cd "$local_path" || { echo "Directory not found"; exit 1; }
    #     git pull origin main
    # else
        # If the directory doesn't exist, clone the repository
        echo "Cloning the repository for the first time..."
        mkdir -p "$local_path" || { echo "Failed to create directory"; exit 1; }
        git clone "$repo_url" "$local_path" || { echo "Clone failed"; exit 1; }
        cd "$local_path" || { echo "Directory not found"; exit 1; }
    # fi
}
send_discord_alert() {                                                           
    error_message="Failed to reload Grafana dashboards. HTTP Status code: $reload_response"
    payload='{"content":"'${error_message}'"}'
    curl -H "Content-Type: application/json" -d "${payload}" "${discord_webhook_url}"
}    
clone_or_pull_repository
RELOAD_TIME=${RELOAD_TIME:-900}
while true; do
    git fetch origin main
    if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]; then
        echo "New commit detected. Pulling changes..."
        git pull origin main
        rsync -a --delete /app/share/grafana-dashboard/  /tmp/git/grafana-dashbaord/devtron-provider-test/
        if [ $? -eq 0 ]; then
            # If changes 
            echo "Changes pulled successfully."
             reload_response=$( curl -X POST -u $REQ_USERNAME:$REQ_PASSWORD http://localhost:3000/api/admin/provisioning/dashboards/reload)
             echo "$reload_response"
        if [ "$reload_response" -eq 200 ]; then
            echo "Grafana dashboards reloaded successfully."
        else
            echo "Failed to reload Grafana dashboards. HTTP Status: $reload_response"
            send_discord_alert "Failed to reload Grafana dashboards. HTTP Status: $reload_response"
        fi 
        else
            echo "No new commits in the repository."
        fi
    fi
    echo "Next update scheduled after $RELOAD_TIME seconds"
    sleep "$((RELOAD_TIME))"
    echo "Reload complete."
done
