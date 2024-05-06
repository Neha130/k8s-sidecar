#!/bin/bash

repo_url="$GIT_REPO"
repo_name="$GIT_REPO_NAME"
local_path="$LOCAL_PATH"
discord_webhook_url="$discord_webhook"
git_branch="$GIT_BRANCH"

function clone_or_pull_repository {
        # If the directory doesn't exist, clone the repository
        echo "Cloning the repository for the first time..."
        ls             
        ls -a /app
        cd $local_path || { echo "Directory not found"; exit 1; }
        pwd
        ls
        git clone $repo_url  || { echo "Clone failed"; exit 1; }
        cd $repo_name
        ls
       
}
send_discord_alert() {                                                           
    error_message="Failed to reload Grafana dashboards. HTTP Status code: $reload_response"
    payload='{"content":"'${error_message}'"}'
    curl -H "Content-Type: application/json" -d "${payload}" "${discord_webhook_url}"
}    
clone_or_pull_repository
while true; do
    git fetch origin $git_branch
    if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/$git_branch)" ]; then
        echo "New commit detected. Pulling changes..."
        git pull origin $git_branch
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
    sleep $RELOAD_TIME
    echo "Reload complete."
done
