#!/system/bin/sh

# Wait for the system to boot completely
sleep 60

# --- CONFIGURATION ---
# The package name of our Flutter configuration app.
# NOTE: This must match the package name in android/app/build.gradle
APP_PACKAGE_NAME="com.example.monet2_configuration"

# Path to the SharedPreferences file where settings are stored.
SETTINGS_FILE="/data/data/$APP_PACKAGE_NAME/shared_prefs/FlutterSharedPreferences.xml"

# Path to the current wallpaper information.
WALLPAPER_INFO="/data/system/users/0/wallpaper_info.xml"

# --- FUNCTIONS ---

# Reads a specific setting value from the SharedPreferences XML file.
get_setting() {
    local key=$1
    local default_value=$2

    if [ ! -f "$SETTINGS_FILE" ]; then
        echo "$default_value"
        return
    fi

    # This is a simple parser. It looks for a line containing the key, then extracts the value.
    # Example line for a boolean: <boolean name="engine_enabled" value="true" />
    # Example line for a double: <string name="vibrancy" value="0.5" /> (Note: SharedPreferences saves doubles as strings)
    local value=$(grep "name=\"$key\"" "$SETTINGS_FILE" | sed -n 's/.*value="\([^"]*\)".*/\1/p')

    if [ -z "$value" ]; then
        echo "$default_value"
    else
        echo "$value"
    fi
}

# Placeholder function for extracting colors from the wallpaper.
extract_wallpaper_colors() {
    log "Monet2: Pretending to extract colors from the wallpaper..."
    # In the future, this will call a binary to get colors.
    # For now, it returns a placeholder color.
    echo "#C0FFEE"
}

# Placeholder function for applying the new theme to the system.
apply_system_theme() {
    local primary_color=$1
    local vibrancy=$2
    local brightness=$3
    log "Monet2: Applying theme. Color: $primary_color, Vibrancy: $vibrancy, Brightness: $brightness"
    # In the future, this will use 'setprop' or 'cmd overlay' to set system colors.
}

# --- MAIN LOOP ---

# Initialize a variable to store the last-seen timestamp of the wallpaper file.
last_wallpaper_timestamp=""

log "Monet2: Service started."

while true; do
    # 1. Check if the engine is enabled in the app's settings.
    engine_enabled=$(get_setting 'flutter.engine_enabled' 'true')
    if [ "$engine_enabled" != "true" ]; then
        log "Monet2: Engine is disabled in settings. Sleeping."
        sleep 30
        continue
    fi

    # 2. Check if the wallpaper file has been modified.
    current_wallpaper_timestamp=$(stat -c %Y "$WALLPAPER_INFO")
    if [ "$current_wallpaper_timestamp" = "$last_wallpaper_timestamp" ]; then
        # Wallpaper has not changed, sleep for a bit.
        sleep 10
        continue
    fi

    log "Monet2: Wallpaper change detected!"
    last_wallpaper_timestamp=$current_wallpaper_timestamp

    # 3. Read the theme settings from the app.
    vibrancy=$(get_setting 'flutter.vibrancy' '0.5')
    brightness=$(get_setting 'flutter.brightness' '0.5')

    # 4. Extract colors from the current wallpaper.
    main_color=$(extract_wallpaper_colors)

    # 5. Handle the special case for black wallpapers.
    if [ "$main_color" = "#000000" ]; then
        log "Monet2: Black wallpaper detected. Applying special gray theme."
        main_color="#808080" # Use a default gray color
    fi

    # 6. Apply the new theme.
    apply_system_theme "$main_color" "$vibrancy" "$brightness"

    log "Monet2: Theme applied. Waiting for next change."
    sleep 10
done
