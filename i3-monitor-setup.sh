#!/bin/bash

# --- CONFIGURATION (UPDATE THESE) ---
LAPTOP="eDP-1"     # Replace with your actual laptop monitor name
EXTERNAL="HDMI-1"  # Replace with your actual external monitor name
LAPTOP_RES="1920x1080" # Replace with your laptop's preferred resolution
EXTERNAL_RES="2560x1080" # Replace with your external monitor's preferred resolution
# --- END CONFIGURATION ---

# Check if the external monitor is currently connected
if xrandr | grep "$EXTERNAL connected"; then

    # 1. External Monitor Connected: Enable it, position it, and move workspaces.
    echo "External monitor detected. Configuring dual screen setup..."

    # Configure XrandR: Enable both monitors, put external to the right (e.g., --right-of)
    xrandr --output "$LAPTOP" --primary --mode "$LAPTOP_RES" --output "$EXTERNAL" --auto --mode "$EXTERNAL_RES" --right-of "$LAPTOP"

    # Move all workspaces (except '1') to the newly enabled external monitor ($EXTERNAL).
    # This uses a loop to iterate through workspaces 2 to 10.
    # Workspace '1' is kept on the laptop monitor.
    for i in {2..10}; do
        i3-msg "workspace $i" 
        i3-msg "move workspace to output $EXTERNAL"
    done

    i3-msg "workspace 1"

else

    # 2. External Monitor Disconnected: Disable it and move all workspaces back.
    echo "External monitor disconnected. Reverting to single screen setup..."

    # Configure XrandR: Disable the external monitor and keep the laptop primary
    xrandr --output "$EXTERNAL" --off --output "$LAPTOP" --primary --auto --mode "$LAPTOP_RES"

    # Move all workspaces (including the ones that were on $EXTERNAL) back to the laptop screen ($LAPTOP).
    # Since only one monitor remains, i3 is smart enough to handle this without specifying the output.
    for i in {2..10}; do
        i3-msg "workspace $i; move workspace to output $LAPTOP"
    done
    i3-msg "workspace 1"
    
    # 3. No External Monitor (Base case) is handled automatically by the '--off' command above.

fi
