#!/bin/bash

# Function to split logs by date and remove processed lines
split_logs_by_date() {
    local input_file="$1"
    local temp_file="${input_file}.tmp"
    local date_pattern='[0-9]{4}-[0-9]{2}-[0-9]{2}'

    # Process the file in chunks
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ $line =~ $date_pattern ]]; then
            date="${BASH_REMATCH[0]}"
            echo "$line" >> "${date}.log"
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$input_file"

    # Replace the original file with the temporary file
    mv "$temp_file" "$input_file"
}

# Function to connect to PRS instances
prs_connect() {
    local instance_id=$(aws ec2 describe-instances \
        --filters "Name=tag:Project,Values=PRS" "Name=instance-state-name,Values=running" \
        --query "Reservations[].Instances[].InstanceId" \
        --output text)
    
    if [ -n "$instance_id" ]; then
        aws ssm start-session --target "$instance_id"
    else
        echo "No running PRS instances found"
    fi
}
