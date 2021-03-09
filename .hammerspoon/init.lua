
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
