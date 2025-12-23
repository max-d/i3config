#!/bin/bash

# Define the command for your existing i3status configuration
I3STATUS_CMD="i3status"
I3STATUS_CONFIG="~/.config/i3status/config"

# Check if a custom config file exists and update the command if necessary
if [ -f "$I3STATUS_CONFIG" ]; then
    I3STATUS_CMD="i3status -c $I3STATUS_CONFIG"
fi

# Start i3status and pipe its output to the loop
exec $I3STATUS_CMD | while read -r line; do

    # 1. Capture the current layout
    # setxkbmap -query outputs: layout, variant, options. We only need the layout code.
    LAYOUT=$(setxkbmap -query | awk '/layout/{print $2}' | tr '[:lower:]' '[:upper:]')

    # 2. Create the JSON block for the layout
    # Note: 'full_text' shows the value, 'name' is for internal identification
    LAYOUT_BLOCK='{"name":"KB_Layout","full_text":"⌨️ '$LAYOUT'"}'

    # 3. Process the output line
    # The i3status output has two parts: 
    # a) The first line is the JSON header: {"version":1}
    # b) Subsequent lines are the status array, starting with '[' or ','

    if [[ "$line" =~ ^\[.* ]]; then
        # If the line starts with '[', it's the beginning of the status data.
        # We use jq to parse the array, prepend our layout block, and output.

        # Remove the leading '[' and append ']' for valid JSON array processing
        # then use jq to prepend our new block to the array.

        echo $line | sed -e 's/^\[//' -e 's/,$//' | \
        jq --arg block "$LAYOUT_BLOCK" '
            # Convert the LAYOUT_BLOCK string back into a JSON object
            ($block | fromjson) as $kb | 

            # Check if the input is an array (it should be)
            if type == "array" then 
                # Prepend our keyboard block to the beginning of the array
                [$kb] + . 
            else 
                . 
            end
        ' | \

        # Format the output back for i3bar: prepend '[', append ','
        sed -e 's/^[[:space:]]*//' -e 's/,$//' | awk '{print ","$0}'

    else
        # Print the JSON header line and other control characters as is
        echo "$line"
    fi

done
