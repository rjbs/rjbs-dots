

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
        x = frame.w - 960,
        y = frame.h - 710,
        w = 950,
        h = 700
      })
      break -- one window is enough, in case of madness
    end
  end
end

resizeMenu = hs.menubar.new()
resizeMenu:setTitle("⌧")
resizeMenu:setClickCallback(function ()
  resizeChromes()
  resizeSlack()
end)
