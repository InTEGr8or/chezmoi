#!/bin/bash

 move_git_forward() {
     local commits=$1

     # If commits is not provided or less than 1, set it to 1
     if [ -z "$commits" ] || [ "$commits" -lt 1 ]; then
         commits=1
     fi

     # Get the current HEAD commit hash
     head=$(git rev-parse --short HEAD)

     # Get all commit hashes
     all_commits=($(git log --pretty=format:'%h' --branches))

     # Find the index of the current HEAD
     current_index=-1
     for i in "${!all_commits[@]}"; do
         if [[ "${all_commits[$i]}" = "${head}" ]]; then
             current_index=$i
             break
         fi
     done

     if [ $current_index -lt 1 ]; then
         echo "No commits found" >&2
         return 1
     fi

     # Calculate the target commit index
     # Note: In bash arrays, 0 is the most recent commit, so we add to move forward
     target_index=$((current_index + commits))

     # Check if we're trying to move past the oldest commit
     if [ $target_index -ge ${#all_commits[@]} ]; then
         echo "Cannot move forward that many commits. Using the oldest commit." >&2
         target_index=$((${#all_commits[@]} - 1))
     fi

     # Get the target commit hash
     target_commit=${all_commits[$target_index]}

     # Checkout the target commit
     git checkout $target_commit
 }

 # Call the function with the first command-line argument
 # move_git_forward "$1"