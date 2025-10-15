
# Archive aider chat files based on first date in .aider.input.history
archive_aider_chats() {
	local base_dir="/home/mstouffer/repos/handterm-proj/handterm-wiki/chats/aider/handterm-cdk"
	local history_file="$base_dir/.aider.input.history"

	# Check if history file exists
	if [[ ! -f "$history_file" ]]; then
		echo "Error: History file not found at $history_file"
		return 1
	fi

	# Extract the first timestamp line from history file
	local timestamp_line=$(grep -m 1 "^# [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}" "$history_file")

	if [[ -z "$timestamp_line" ]]; then
		echo "Error: No timestamp found in history file"
		return 1
	fi

	# Extract date and time components
	local date_str=$(echo "$timestamp_line" | cut -d' ' -f2)
	local time_str=$(echo "$timestamp_line" | cut -d' ' -f3)

	# Parse the components
	local year=${date_str:0:4}
	local month=${date_str:5:2}
	local day=${date_str:8:2}
	local hour=${time_str:0:2}
	local minute=${time_str:3:2}
	local second=${time_str:6:2}

	# Create target directory with timestamp
	local target_dir="$base_dir/$year/$month/${day}_${hour}-${minute}-${second}"
	mkdir -p "$target_dir"

	# Move all files (not directories) to target directory
	find "$base_dir" -maxdepth 1 -type f -exec mv {} "$target_dir/" \;

	echo "Files archived to $target_dir"
}
. "$HOME/.cargo/env"