-- Google+Code Widget
-- version 2.0 - EdgeTX Widget
-- EdgeTX 2.8+ compatible
-- This widget displays GPS coordinates as Google Plus Code
-- Based on original code by Miami Mike, modified by ChrisOhara,
-- Converted to EdgeTX widget format By Jurica Bilicic

local name = "GPlusCd"
local options = {
  { "TitleCol", COLOR, WHITE },  -- Color for titles
  { "DataCol",  COLOR, WHITE },  -- Color for data values
  { "StatusCol",COLOR, YELLOW }, -- Color for status messages
  { "ShadowOn", BOOL, 0 }       -- Toggle for text shadows (0=off, 1=on)
}

local map = {[0] =
	"2", "3", "4", "5", "6", "7", "8", "9", "C", "F",
	"G", "H", "J", "M", "P", "Q", "R", "V", "W", "X"}

local function create(zone, options)
  local widget = {
    zone = zone,
    options = options,
    gpsId = nil,
    latitude = 0.0,
    longitude = 0.0,
    pluscode = "No Fix", -- Initial value
    lastUpdate = 0,
    lastRefreshedLat = nil, -- Store last lat for which pluscode was calculated
    lastRefreshedLon = nil  -- Store last lon for which pluscode was calculated
  }
  
  -- Try to find GPS telemetry source - try multiple common GPS source names
  local gpsFields = {"GPS", "Lat", "Lon", "GPS1", "GPS2"}
  for _, field in ipairs(gpsFields) do
    local fieldInfo = getFieldInfo(field)
    if fieldInfo then
      widget.gpsId = fieldInfo.id
      break
    end
  end

  -- Attempt to populate with current telemetry data immediately on creation
  if widget.gpsId then
    local gpsValue = getValue(widget.gpsId)
    if gpsValue and type(gpsValue) == "table" and gpsValue.lat and gpsValue.lon then
      widget.latitude = gpsValue.lat
      widget.longitude = gpsValue.lon
      widget.lastUpdate = getTime() -- Set lastUpdate time if data is good
      widget.pluscode = calculatePlusCode(widget.latitude, widget.longitude)
      widget.lastRefreshedLat = widget.latitude   -- Prime refresh optimization
      widget.lastRefreshedLon = widget.longitude  -- Prime refresh optimization
    elseif gpsValue and gpsValue ~= 0 then 
      widget.lastUpdate = getTime() -- It's a signal, but not lat/lon, still update time
      -- widget.pluscode remains "No Fix" as we don't have coordinates
    end
    -- If gpsValue is 0 or nil, initial defaults (0.0, "No Fix") remain
  end
  
  return widget
end

local function getcode(lat, lon)
	local int = math.floor(lat)
	local codepair = map[int]
	lat = 20 * (lat - int)
	int = math.floor(lon)
	codepair = codepair .. map[int]
	lon = 20 * (lon - int)
	return lat, lon, codepair
end

local function calculatePlusCode(latitude, longitude)
  if latitude == 0 and longitude == 0 then
    return "No Fix"
  end
  
  local lat = (latitude + 90) / 20
  local lon = (longitude + 180) / 20
  local pluscode = ""
  
  for i = 1, 4 do
    lat, lon, codepair = getcode(lat, lon)
    pluscode = pluscode .. codepair
  end
  pluscode = pluscode .. "+"
  lat, lon, codepair = getcode(lat, lon)
  pluscode = pluscode .. codepair
  pluscode = pluscode .. map[4 * math.floor(lat / 5) + math.floor(lon / 4)]
  
  return pluscode
end

local function update(widget, options)
  widget.options = options
end

-- The background function has been removed as per user request for optimization.
-- Data fetching is handled by create() on initialization/re-creation and by refresh() when visible.

local function refresh(widget, event, touchState)
  -- Don't use lcd.clear() in widgets - it clears the entire screen
  
  -- Fetch latest GPS data when the widget is visible and refreshing
  if widget.gpsId then
    local gpsValue = getValue(widget.gpsId)
    if gpsValue and type(gpsValue) == "table" and gpsValue.lat and gpsValue.lon then
      widget.latitude = gpsValue.lat
      widget.longitude = gpsValue.lon
      widget.lastUpdate = getTime()
    elseif gpsValue and gpsValue ~= 0 then
      widget.lastUpdate = getTime()
      -- If we only get a status and not full coords, latitude/longitude remain from previous good fix
      -- or from create(). pluscode calculation logic below will handle it.
    end
    -- If gpsValue is 0 or nil, we don't update anything here, rely on previous state.
  end
  
  local zone = widget.zone
  local w = zone.w
  local h = zone.h
  local x = zone.x
  local y = zone.y
  
  local titleFontFlags = widget.options.TitleCol + SMLSIZE
  local dataFontFlagsSML = widget.options.DataCol + SMLSIZE
  local dataFontFlagsMID = widget.options.DataCol + MIDSIZE
  local statusFontFlags = widget.options.StatusCol + SMLSIZE         -- For general status like "NO GPS"
  local statusFontFlagsCritical = widget.options.StatusCol + SMLSIZE -- Specifically for non-shadowed "OLD"/"*"

  if widget.options.ShadowOn == 1 then
    titleFontFlags = titleFontFlags + SHADOWED
    dataFontFlagsSML = dataFontFlagsSML + SHADOWED
    dataFontFlagsMID = dataFontFlagsMID + SHADOWED
    statusFontFlags = statusFontFlags + SHADOWED  -- "NO GPS" / "!" can be shadowed
    -- statusFontFlagsCritical remains unshadowed
  end
  
  -- Calculate plus code only if coordinates have changed or it's the first run
  if widget.latitude ~= widget.lastRefreshedLat or widget.longitude ~= widget.lastRefreshedLon or widget.lastRefreshedLat == nil then
    widget.pluscode = calculatePlusCode(widget.latitude, widget.longitude)
    widget.lastRefreshedLat = widget.latitude
    widget.lastRefreshedLon = widget.longitude
  end
  
  -- Draw based on widget size
  if w >= 200 and h >= 60 then
    -- Large widget - full display
    lcd.drawText(x + 5, y + 1, "GPS Coordinates:", titleFontFlags)
    lcd.drawText(x + 5, y + 13, string.format("%.6f, %.6f", widget.latitude, widget.longitude), dataFontFlagsMID)
    lcd.drawText(x + 5, y + 34, "Google Plus Code:", titleFontFlags)
    lcd.drawText(x + 5, y + 46, widget.pluscode, dataFontFlagsMID)
  elseif w >= 150 and h >= 40 then
    -- Medium widget - compact display
    lcd.drawText(x + 2, y + 2, "GPS:", titleFontFlags)
    lcd.drawText(x + 2, y + 14, string.format("%.4f,%.4f", widget.latitude, widget.longitude), dataFontFlagsMID)
    lcd.drawText(x + 2, y + 30, widget.pluscode, dataFontFlagsSML)
  else
    -- Small widget - minimal display
    lcd.drawText(x + 1, y + 1, "Plus:", titleFontFlags)
    if string.len(widget.pluscode) > 8 then
      lcd.drawText(x + 1, y + 11, string.sub(widget.pluscode, 5, 12), dataFontFlagsSML)
    else
      lcd.drawText(x + 1, y + 11, widget.pluscode, dataFontFlagsSML)
    end
  end
  
  -- Show GPS status indicator - adjusted for different widget sizes
  if widget.gpsId == nil then
    if w >= 150 then
      lcd.drawText(x + w - 35, y + 2, "NO GPS", statusFontFlags + BLINK)
    else
      lcd.drawText(x + w - 8, y + 2, "!", statusFontFlags + BLINK)
    end
  elseif getTime() - widget.lastUpdate > 500 then -- 5 seconds timeout
    if w >= 150 then
      lcd.drawText(x + w - 25, y + 2, "OLD", statusFontFlagsCritical)
    else
      lcd.drawText(x + w - 8, y + 2, "*", statusFontFlagsCritical)
    end
  end
end

return {
  name = name,
  options = options,
  create = create,
  update = update,
  refresh = refresh
  -- background function has been removed
} 