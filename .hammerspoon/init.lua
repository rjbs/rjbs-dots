
function resizeChromes ()
  local chrome = hs.application.find("Chrome")
  if (chrome) then
    local windows = chrome:visibleWindows()
    for i, window in ipairs(windows) do
      local frame = window:screen():frame()
      if (string.len(window:title()) > 0) then
        window:move({
          x = frame.x + 10 * i,
          y = frame.y + 10 * i,
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
        x = frame.x + frame.w - 1300,
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
