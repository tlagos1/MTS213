```bash
#!/bin/bash
set -e

# The script must be executed with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo:"
    echo "sudo ./setup.sh"
    exit 1
fi

# Get the user who executed sudo
CURRENT_USER="${SUDO_USER:-$USER}"

# Get the directory where the script was launched
WORK_DIR="$PWD"

echo "Current user: $CURRENT_USER"
echo "Working directory: $WORK_DIR"

# 1. Create the data directory in the current working directory
mkdir -p "$WORK_DIR/dat"

# Give ownership to the current user
chown "$CURRENT_USER:$(id -gn "$CURRENT_USER")" "$WORK_DIR/dat"

# 2. Change ONLY the displayed name to "user"
# The actual Linux username remains unchanged
chfn -f "user" "$CURRENT_USER"

# 3. Change the user's password to pass4user
echo "$CURRENT_USER:pass4user" | chpasswd

# 4. Install add-apt-repository support
apt update
apt install -y software-properties-common

# 5. Add the Octave repository
add-apt-repository -y ppa:ubuntuhandbook1/octave

# 6. Update package information
apt update

# 7. Upgrade installed packages
apt upgrade -y

# 8. Install Octave
apt install -y octave

echo
echo "======================================"
echo "Setup completed successfully"
echo "======================================"
echo "Actual username: $CURRENT_USER"
echo "Displayed name:  user"
echo "New password:    pass4user"
echo "Data directory:  $WORK_DIR/dat"
echo "Octave installed successfully."
echo "======================================"
```
