#!/usr/bin/env bash

# Function to execute the AMD GPU Python script and use its output
execute_amd_script() {
  local amd_output
  amd_output=$(python3 ${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/amdgpu.py)
  echo "$amd_output"
}

# Function to get Intel GPU temperature from 'sensors'
get_intel_gpu_temperature() {
  local temperature
  temperature=$(sensors | grep "Package id 0" | awk '{print $4}' | sed 's/+//;s/°C//;s/\.0//')
  echo "$temperature"
}

# Function to define emoji based on temperature
get_temperature_emoji() {
  local temperature="$1"
  if [ "$temperature" -lt 60 ]; then
    echo "❄️"  # Ice emoji for less than 60°C
  else
    echo "🔥"  # Fire emoji for 60°C or higher
  fi
}

# Execute the AMD GPU Python script and use its output
amd_output=$(execute_amd_script)
# Extract GPU Temperature, GPU Load, GPU Core Clock, and GPU Power Usage from amd_output
temperature=$(echo "$amd_output" | jq -r '.["GPU Temperature"]' | sed 's/°C//')
gpu_load=$(echo "$amd_output" | jq -r '.["GPU Load"]' | sed 's/%//')
core_clock=$(echo "$amd_output" | jq -r '.["GPU Core Clock"]' | sed 's/ GHz//;s/ MHz//')
power_usage=$(echo "$amd_output" | jq -r '.["GPU Power Usage"]' | sed 's/ Watts//')

# Get emoji based on temperature
emoji=$(get_temperature_emoji "$temperature")

# Print the formatted information in JSON
if [ -n "$temperature" ]; then
  primary_gpu="AMD GPU"
  echo "{\"text\":\"$temperature°C\", \"tooltip\":\"Primary GPU: $primary_gpu\n$emoji Temperature: $temperature°C\n󰾆 Utilization: $gpu_load%\n Clock Speed: $core_clock MHz\n Power Usage: $power_usage W\"}"
else
  # Check for Intel GPU
  primary_gpu="Intel GPU"
  intel_gpu=$(lspci -nn | grep -i "VGA compatible controller" | grep -i "Intel Corporation" | awk -F' ' '{print $1}')
  if [ -n "$intel_gpu" ]; then
    temperature=$(get_intel_gpu_temperature)
    emoji=$(get_temperature_emoji "$temperature")
    # Print the formatted information in JSON
    echo "{\"text\":\"$temperature°C\", \"tooltip\":\"Primary GPU: $primary_gpu\n$emoji Temperature: $temperature°C\"}"
  else
    primary_gpu="Not found"
    # Print the formatted information in JSON
    echo "{\"text\":\"N/A\", \"tooltip\":\"Primary GPU: $primary_gpu\"}"
  fi
fi
