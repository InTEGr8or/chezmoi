if ! mountpoint -q /mnt/d/; then
	sudo mkdir -p /mnt/d
	sudo mount -t drvfs D: /mnt/d
	echo "D: has been mounted at /mnt/d/"
fi
