#!/bin/bash

# File and Log Paths
CACHE_DIR="/tmp/ip_lookup_cache"
LOGFILE="$HOME/ip_lookup.log"   
VERBOSE=false
CACHE_EXPIRATION=86400  # Set cache expiration time in seconds (e.g., 86400 seconds = 24 hours)

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Function to log verbose messages
log() {
    if [ "$VERBOSE" = true ]; then
        echo "$1"
    fi
}

# Check if curl is installed
if ! command -v curl &> /dev/null
then
    echo "Error: curl is not installed. Please install it and try again."
    exit 1
fi

# Check if an argument (IP, domain, or file) is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <IP_ADDRESS or DOMAIN_NAME or FILE> [--basic] [--verbose] [--clear-cache]"
  exit 1
fi

# Handle verbosity flag
if [ "$2" == "--verbose" ] || [ "$3" == "--verbose" ]; then
    VERBOSE=true
fi

# Handle bulk file input
if [ -f "$1" ]; then
    while IFS= read -r line; do
        $0 "$line" "$2"
    done < "$1"
    exit 0
fi

# Handle the --clear-cache flag to delete the cache
if [ "$2" == "--clear-cache" ] || [ "$3" == "--clear-cache" ]; then
    log "Clearing cache for $1"
    rm -f "$CACHE_DIR/$1.json"
    echo "Cache cleared for $1"
    exit 0
fi

# Set the IP or domain from the first argument
QUERY=$1

# Define a cache file for this query
CACHE_FILE="$CACHE_DIR/${QUERY}.json"

# Check if the input is a valid IP address (supports both IPv4 and IPv6)
if [[ $QUERY =~ ^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4})$ ]]; then
    TYPE="IP"
else
    TYPE="DOMAIN"
fi

# Check if the response is cached and if it is expired
if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
    if [ "$CACHE_AGE" -le "$CACHE_EXPIRATION" ]; then
        log "Fetching cached result for $QUERY (Cache Age: $CACHE_AGE seconds)"
        JSON_RESPONSE=$(cat "$CACHE_FILE")
    else
        log "Cache expired for $QUERY. Fetching new data."
        rm -f "$CACHE_FILE"
    fi
fi

# Fetch the data if it wasn't found in the cache or if the cache was expired
if [ ! -f "$CACHE_FILE" ]; then
    RESPONSE=$(curl -s -w "\n%{http_code}" "http://ip-api.com/json/$QUERY")
    HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
    JSON_RESPONSE=$(echo "$RESPONSE" | sed '$d')  # Get everything except the last line (HTTP status)

    if [ "$HTTP_STATUS" -eq 429 ]; then
        echo "Rate limit exceeded. Retrying in 60 seconds..."
        sleep 60
        RESPONSE=$(curl -s "http://ip-api.com/json/$QUERY")
        JSON_RESPONSE=$(echo "$RESPONSE" | sed '$d')  # Get the response without status
    fi

    # Save the response in cache
    echo "$JSON_RESPONSE" > "$CACHE_FILE"
fi

# Log the lookup
log "Logging lookup for $QUERY"
echo "$(date) - Lookup: $QUERY" >> "$LOGFILE"

# Check if the response contains "fail" status (in case of an invalid IP, domain, or API issue)
if echo "$JSON_RESPONSE" | grep -q '"status":"fail"'; then
    echo "Error: Unable to retrieve data for $QUERY"
    exit 1
fi

# Handle optional --basic flag for selective field output
if [ "$2" == "--basic" ] || [ "$3" == "--basic" ]; then
    COUNTRY=$(echo "$JSON_RESPONSE" | jq -r '.country // "Not Available"')
    CITY=$(echo "$JSON_RESPONSE" | jq -r '.city // "Not Available"')
    ISP=$(echo "$JSON_RESPONSE" | jq -r '.isp // "Not Available"')

    echo "Country: $COUNTRY"
    echo "City: $CITY"
    echo "ISP: $ISP"
else
    # Display the full JSON response with proper formatting
    if command -v jq &> /dev/null; then
        echo "$JSON_RESPONSE" | jq .
    else
        echo "$JSON_RESPONSE"
    fi
fi

# Open location in Google Maps if verbose flag is set
LAT=$(echo "$JSON_RESPONSE" | jq -r '.lat // empty')
LON=$(echo "$JSON_RESPONSE" | jq -r '.lon // empty')

if [ "$VERBOSE" = true ]; then
    if [ -n "$LAT" ] && [ -n "$LON" ]; then
        if command -v xdg-open &> /dev/null; then
            log "Opening location in Google Maps: $LAT, $LON"
            xdg-open "https://maps.google.com/?q=$LAT,$LON"
        else
            log "Google Maps link: https://maps.google.com/?q=$LAT,$LON"
        fi
    else
        log "Google Maps link: Location data unavailable."
    fi
fi
