
function resizeChromes ()
  local chrome = hs.application.find("Chrome")
  if (chrome) then
    local windows = chrome:visibleWindows()

    -- So, we're going to move windows to near the top left of their screens,
    -- staggering them by +(10,10) per window.  But the staggering needs to be
    -- on a per-desktop basis or it's weird.  (You end up with gaps in the
    -- stagging of desktop A while windows on desktop B are positioned to fill
    -- those gaps in relative positioning.  Weird, right?)  I don't think
    -- there's a simple desktop id, so instead I'm going to use the string
    -- "x,y" of the frame of the window's screen as the key for storing the
    -- offset coefficient incrementor. -- rjbs, 2020-08-08
    local offset = {}

    for i, window in ipairs(windows) do
      local frame = window:screen():frame()
      if (string.len(window:title()) > 0) then
        -- Woah, what's up with that string.len() call?  Well, some UI elements
        -- like "Find" boxes are actually windows.  Trying to move them or
        -- stagger based on them would be a fool's errand. -- rjbs, 2020-08-08
        local key = frame.x .. "," .. frame.y
        offset[key] = (offset[key] or 0) + 1

        window:move({
          x = frame.x + 10 * offset[key],
          y = frame.y + 10 * offset[key],
          w = 1200,
          h = 800
        })
      end
    end
  end
end

function resizeSlack ()
  local slack = hs.application.find("Slack")
  if (slack) then
    local windows = slack:visibleWindows()
    for i, window in ipairs(windows) do
      local frame = window:screen():fullFrame()
      window:move({
        x = frame.x + frame.w - 960,
        y = frame.h - 710,
        w = 950,
        h = 700
      })
      break -- one window is enough, in case of madness
    end
  end
end

function resizeLiquidPlanner ()
  local lp = hs.application.find("LiquidPlanner")
  if (lp) then
    local windows = lp:visibleWindows()
    for i, window in ipairs(windows) do
      local frame = window:screen():frame()
      window:move({
        x = frame.x + frame.w - 1250,
        y = 30,
        w = 1200,
        h = 800
      })
      break -- one window is enough, in case of madness
    end
  end
end

hs.hotkey.bind({"cmd","alt"}, "space", function()
  hs.spotify.playpause()
end)

hs.hotkey.bind({"cmd","alt"}, "left", function()
  hs.spotify.previous()
end)

hs.hotkey.bind({"cmd","alt"}, "right", function()
  hs.spotify.next()
end)

hs.hotkey.bind({}, "f6", function()
  local url  = "http://wabe.local:9999/"
  hs.http.doAsyncRequest(url, 'GET', nil, nil, function () end, 'ignoreLocalCache')
  hs.sound.getByFile("/Users/rjbs/Dropbox/sounds/tng-red-alert-1.mp3"):play()
end)

hs.hotkey.bind({}, "f9", function()
  local zoom = hs.application.find("Zoom")
  if (zoom) then
    local path = zoom:path()
    zoom:kill9()

    hs.task.new("/usr/bin/open", nil, function() return true end, { path }):start()
  end
end)

resizeMenu = hs.menubar.new()
resizeMenu:setTitle("⌧")
resizeMenu:setClickCallback(function ()
  resizeChromes()
  resizeLiquidPlanner()
  resizeSlack()
end)

TimerWidget = require('TimerWidget')
timer = TimerWidget:new()
timer:install()

Microphonist = require('Microphonist')
mic = Microphonist:new()
mic:install()

tabulator = hs.httpserver.new()
tabulator:setPort(9876)
tabulator:setCallback(function (method, path, headers, body)
  if (method == "GET") and (path == "/metrics") then
    bool, tabcounts, descriptor = hs.osascript.javascript([[
      const Chrome  = new Application("/Applications/Google Chrome.app");

      let tabCounts = [];

      if (Chrome.running()) {
        for (i in Chrome.windows) {
          const window = Chrome.windows[i];
          const tabs   = window.tabs;
          tabCounts.push(tabs.length);
        }

        tabCounts.sort((a,b) => b - a);

        // console.log(JSON.stringify(tabCounts));
      } else {
        // console.log(JSON.stringify([]));
      }

      tabCounts;
    ]])

    if not bool then
      return "Error\n", 500, {}
    end

    local sum = 0
    for i, tabs in ipairs(tabcounts) do
      sum = sum + tabs
    end

    return "chrome_open_tabs " .. sum .. "\n", 200, {}
  else
    return "No good.\n", 404, {}
  end
end)
tabulator:start()
