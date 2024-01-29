require "debug"

rehomeDEBUG = false
rehomeDEBUGVERBOSE = false

primaryScreenName = "Built%-in Retina Display"
secondaryScreenName = "DELL S2722QC"

windowFilter = hs.window.filter.new()
windowFilter:setDefaultFilter{}
windowFilter:setSortOrder(hs.window.filter.sortByFocusedLast)

if rehomeDEBUGVERBOSE then
  for _, sc in pairs(hs.screen.allScreens()) do
    print("loading screen", sc:name())
    -- https://www.hammerspoon.org/docs/hs.spaces.html
    local spids = hs.spaces.allSpaces()[sc:getUUID()]
    for _, spid in pairs(spids) do
      print("loading space", hs.spaces.missionControlSpaceNames()[sc:getUUID()][spid])
    end
  end
end

-- Keep a local copy of all windows
allWindows = {}
for _, window in pairs(windowFilter:getWindows()) do 
  if rehomeDEBUGVERBOSE then
    print("loading window", window:application():name() .. "::" .. window:title())
  end
  allWindows[window:id()] = window
end

windowFilter:subscribe("windowCreated", function(window, name, event)
  if rehomeDEBUG then
    print("window created", window)
  end
  allWindows[window:id()] = window
end)

windowFilter:subscribe("windowDestroyed", function(window, name, event)
  if rehomeDEBUG then
    print("window destroyed", window)
  end
  allWindows[window:id()] = nil
end)

function rehome(windowQuery, screenQuery, spaceIndex, pushArgs)
  for id, w in pairs(allWindows) do
    local name = w:application():name() .. " - " .. w:title()
    if name ~= nil and name:find(windowQuery) then 
      window = w
    end
  end

  if window == nil then
    if rehomeDEBUG then
      print("[ERROR in rehome] Window now found", windowQuery)
    end
    return
  end

  local screen = hs.screen.find(screenQuery)
  if screen == nil then
    if rehomeDEBUG then
      print("[ERROR in rehome] Screen now found", screenQuery)
    end
    return
  end

  local spaceIDs = hs.spaces.allSpaces()[screen:getUUID()]
  if spaceIndex > #spaceIDs then
    if rehomeDEBUG then
      print("[ERROR in rehome] spaceIndex too large", spaceIndex, ">", #spaceIDs)
    end
    return
  end
  local spaceID = spaceIDs[spaceIndex]
  local spaceName = hs.spaces.missionControlSpaceNames()[screen:getUUID()][spaceID]

  if rehomeDEBUG then
    print("Moving", window, "to", spaceID, "=", spaceName, "on", screen)
  end
  hs.spaces.moveWindowToSpace(window, spaceID)
  
  if pushArgs ~= nil then
    pushArgs["window"] = window
    push(pushArgs)
  end
end

