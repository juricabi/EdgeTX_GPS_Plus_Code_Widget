# EdgeTX GPS Plus Code Widget

This widget displays GPS coordinates as Google Plus Codes on EdgeTX radios with color screens.

## Installation Instructions

1. **Copy the widget folder to your SD card:**
   - Copy the entire `GPlusCd` folder to the `/WIDGETS/` directory on your EdgeTX SD card
   - The file structure should be: `/WIDGETS/GPlusCd/main.lua`

2. **Add the widget to your screen:**
   - On your EdgeTX radio, go to **Screen Settings** → **Widgets**
   - Select a widget slot and choose "GPlusCd" from the list
   - The widget will automatically detect GPS telemetry when available

## Requirements

- EdgeTX 2.8 or later
- Color screen radio (TX16S, Horus, etc.)
- GPS telemetry source (requires a GPS sensor sending telemetry data)

## Features

- Automatically detects GPS telemetry sources
- Displays GPS coordinates and Google Plus Code
- Responsive display based on widget size
- Shows GPS status (No GPS, Old data indicators)
- Works in different widget sizes (large, medium, small)

## Troubleshooting

**Widget shows "No GPS Signal":**
- Ensure you have a GPS sensor connected and configured
- Check that GPS telemetry is being received in EdgeTX
- Verify the GPS sensor is properly bound and sending data

**Widget not appearing in widget list:**
- Ensure the file is placed in `/WIDGETS/GPlusCd/main.lua` on the SD card
- Check that the SD card is properly inserted
- Restart EdgeTX after copying the files

**"No run function" error:**
- This usually means the file is not in the correct location
- EdgeTX widgets must be in `/WIDGETS/<widgetname>/main.lua` format
- Make sure you're copying the `GPlusCd` folder, not just the `main.lua` file

## About Google Plus Codes

Google Plus Codes (also known as Open Location Codes) provide a way to encode locations into a short alphanumeric code. This is useful for sharing precise locations without requiring full GPS coordinates. 