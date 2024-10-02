# ip-lookup

This script provides a robust and versatile solution for performing IP and domain lookups using the ip-api service. The script is designed to handle caching, rate limits, and provide both basic and verbose outputs, making it a flexible tool for administrators or developers. The script also integrates with Google Maps for geolocation visualization and supports bulk lookups from files.

## Features

- **IP Address and Domain Lookup**: Perform lookups on both IP addresses and domain names seamlessly.
- **Caching Mechanism**: Results are cached to minimize redundant API calls, enhancing performance and reducing the risk of hitting rate limits.
- **Cache Expiration**: Automatically refreshes cached data after a configurable expiration period (default is 24 hours).
- **Basic and Verbose Modes**: 
  - **Basic Mode**: Displays essential fields such as Country, City, and ISP for quick insights.
  - **Verbose Mode**: Provides the full JSON response and integrates with Google Maps to visualize geolocation data.
- **Manual Cache Clearing**: You can manually clear the cache for specific IPs or domains using a command-line flag.
- **Bulk Lookups**: Supports performing lookups on multiple IPs or domains by reading from a file.
- **Google Maps Integration**: Opens the location in Google Maps based on the latitude and longitude from the lookup data.
- **Detailed Logging**: Logs all lookups with timestamps to a log file for tracking and debugging purposes.
- **Rate Limit Handling**: Automatically handles API rate limits by implementing retry mechanisms with delays.

## Recent Changes

### Latest Version

- **Automatic Cache Expiration**: The cache expiration mechanism ensures data freshness without manual intervention.
- **Manual Cache Clearing Option**: Added a `--clear-cache` flag to allow users to clear cache entries manually.
- **Improved Error Handling**: Enhanced error messages and handling for failure scenarios, including API rate limits and invalid inputs.
- **Selective Output Enhancement**: The `--basic` mode has been improved to handle missing fields gracefully by displaying "Not Available" when data is missing.
- **Bulk Lookup Support**: Added the ability to perform lookups on multiple IPs or domains from a file.
- **Verbose Logging**: The `--verbose` flag now provides detailed logs and optionally opens Google Maps links.

### Previous Updates

- **Caching Implementation**: Introduced caching to store lookup results and reduce redundant API calls.
- **Basic and Verbose Modes**: Added the ability to switch between basic and verbose output formats.
- **Rate Limit Handling**: Implemented basic rate limit handling to wait and retry when API limits are exceeded.
- **Logging**: Added functionality to log all lookups with timestamps for monitoring purposes.

## Prerequisites

- **Bash**: The script is written for the Bash shell (available by default on Linux and macOS).
- **curl**: Required for making API requests.
  - **Installation**:
    - **Debian/Ubuntu**:
      ```bash
      sudo apt-get install curl
      ```
    - **macOS** (using Homebrew):
      ```bash
      brew install curl
      ```
    - **Windows**: Install via [Git for Windows](https://gitforwindows.org/) which includes Git Bash and `curl`.

- **jq**: Required for parsing and formatting JSON responses.
  - **Installation**:
    - **Debian/Ubuntu**:
      ```bash
      sudo apt-get install jq
      ```
    - **macOS** (using Homebrew):
      ```bash
      brew install jq
      ```
    - **Windows**: Install via [Chocolatey](https://chocolatey.org/) or download binaries from the [official jq website](https://stedolan.github.io/jq/download/).

## Installation

1. **Clone the Repository**:

    ```bash
    git clone https://github.com/Matt-THG/ip-lookup.git
    cd ip-lookup
    ```

2. **Make the Script Executable**:

    ```bash
    chmod +x ipapi.sh
    ```

3. **Set Up Logging Permissions** (Optional):
   
   Ensure that the log file is writable. By default, the script logs to `$HOME/ip_lookup.log`, which should be writable by the user.

## Usage

### Basic IP/Domain Lookup

To perform a basic lookup on an IP address or domain name:

```bash
./ipapi.sh <IP_ADDRESS_or_DOMAIN>
```

**Example**

```bash
./ipapi.sh 8.8.8.8
```
or

```bash
./ipapi.sh google.com
```

### Basic Mode

Use the --basic flag to display only essential fields (Country, City, ISP):

```bash
./ipapi.sh <IP_ADDRESS_or_DOMAIN> --basic
```

**Example**

```bash
./ipapi.sh google.com --basic
```

**Output**

```bash
Country: United States
City: Washington
ISP: Google LLC
```

### Verbose Mode with Google Maps Integration

Use the --verbose flag to display the full JSON response and automatically open the location in Google Maps:

```bash
./ipapi.sh <IP_ADDRESS_or_DOMAIN> --verbose
```

**Example**

```bash
./ipapi.sh google.com --verbose
```

**Output**

```bash
{
  "status": "success",
  "country": "United States",
  "countryCode": "US",
  "region": "DC",
  "regionName": "Washington, D.C.",
  "city": "Washington",
  "lat": 38.89511,
  "lon": -77.03637,
  "timezone": "America/New_York",
  "isp": "Google LLC",
  "org": "Google Public DNS (iad)",
  "as": "AS15169 Google LLC",
  "query": "google.com"
}
Google Maps link: https://maps.google.com/?q=38.89511,-77.03637
```

### Clear the Cache

To manually clear the cache for a specific IP or domain, use the --clear-cache flag:

```bash
./ipapi.sh <IP_ADDRESS_or_DOMAIN> --clear-cache
```

**Example**

```bash
./ipapi.sh google.com --clear-cache
```

**Output**

```rust
Cache cleared for google.com
```

### Bulk Lookup from a File 

To perform lookups on multiple IPs or domains listed in a file (one per line):

```bash
./ipapi.sh <file_with_list_of_ips_or_domains>
```

**Example**

Given a file ips.txt containing:

```bash
8.8.8.8
google.com
1.1.1.1
```

Run:

```bash
./ipapi.sh ips.txt
```

**Output**

```json
{
  "status": "success",
  "country": "United States",
  "countryCode": "US",
  "region": "VA",
  "regionName": "Virginia",
  "city": "Ashburn",
  "zip": "20149",
  "lat": 39.03,
  "lon": -77.5,
  "timezone": "America/New_York",
  "isp": "Google LLC",
  "org": "Google Public DNS",
  "as": "AS15169 Google LLC",
  "query": "8.8.8.8"
}
```

### Google Maps Integration

In verbose mode, the script will also output a Google Maps link that you can open directly in a browser to visualize the geolocation:

```bash
Google Maps link: https://maps.google.com/?q=<lat>,<lon>
```

## Troubleshooting
**Rate Limit Reached:** If you hit the rate limit, the script will retry after a delay. You can check the log for details.

**Missing Fields:** In --basic mode, missing fields will display "Not Available" to ensure smooth output even when some information is unavailable.

**Cache Issues:** If outdated information is returned, try using the --clear-cache flag to refresh the cache.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
