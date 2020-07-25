local TimerWidget = { }

function TimerWidget:new (obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self

  obj.state = "idle"

  return obj
end

function TimerWidget:timeLeft ()
  local remaining = math.floor(self.doneAt - hs.timer.secondsSinceEpoch())
  return string.format(
    "%.0f:%02.0f",
    (remaining - (remaining % 60)) / 60,
    remaining % 60
  )
end

function TimerWidget:redraw ()
  if self.state == "running" then
    local remaining = self.doneAt - hs.timer.secondsSinceEpoch()
    self.timerMenu:setTitle(self:timeLeft() .. " ⏳")
    return
  end

  if self.state == "resting" then
    local remaining = self.doneAt - hs.timer.secondsSinceEpoch()
    self.timerMenu:setTitle(self:timeLeft() .. " 💤")
    return
  end

  self.timerMenu:setTitle("🍅")
end

function TimerWidget:startPomodoro (runMinutes, restMinutes)
  self.state = "running"

  self.runDuration  = runMinutes  * 60
  self.restDuration = restMinutes * 60

  hs.sound.getByFile("/Users/rjbs/Dropbox/music/3-2-1-lets-jam.mp3"):play()
  self:blink("00ff00", 5)
  self.doneAt  = hs.timer.secondsSinceEpoch() + self.runDuration
  self.timer = hs.timer.doEvery(1, function () self:tick() end)
  self.blinkSlice = { numerator = 4, denomenator = 5, total = self.runDuration }
  self:redraw()
end

function TimerWidget:startRest ()
  self.state = "resting"
  hs.speech.new():speak("Time to take a break.")
  hs.notify.new(nil, {
    autoWithdraw  = true,
    title         = "It's over.",
    setIdImage    = "/Users/rjbs/Dropbox/images/tomato-icon.png"
  }):send()
  self.doneAt = hs.timer.secondsSinceEpoch() + self.restDuration
  self.timer = hs.timer.doEvery(1, function () self:tick() end)
  self:redraw()
end

function TimerWidget:clearTimer ()
  if self.timer then
    self.timer:stop()
    self.timer = nil
  end

  self.blinkSlice = nil
  self.doneAt = nil
  self.state = "idle"
  self.runDuration = nil
  self.restDuration = nil

  self:redraw()
end

function TimerWidget:cancelTimer ()
  self:clearTimer()

  self:blink("ff00ff", 3)
end

function TimerWidget:blink (rgb, count)
  rgb = rgb:gsub("^#","")
  local url = string.format(
    "http://raspberrypi.local:8000/blink1/blink?rgb=%s&count=%s",
    rgb,
    count
  )

  hs.http.doAsyncRequest(url, 'GET', nil, nil, function () end, 'ignoreLocalCache')
end

function TimerWidget:tick ()
  local remaining = self.doneAt - hs.timer.secondsSinceEpoch()

  if remaining <= 0 then
    if (self.state == "running") and (self.restDuration > 0) then
      self.timer:stop()
      self:blink("ff0000", 5)
      self:startRest()
    else
      self:blink("ff00ff", 3)
      self:clearTimer()
    end
  else
    if self.state == "running" then
      local bs = self.blinkSlice
      local nextBlink = bs.total / bs.denomenator * bs.numerator

      if remaining < nextBlink then
        self:blink("ff8800", bs.numerator)
        bs.numerator = bs.numerator - 1
      end
    end
  end

  self:redraw()
end

function TimerWidget:provideMenu ()
  if self.state == "running" then
    return {
      { title = "Cancel Pomodoro", fn = function () self:cancelTimer() end }
    }
  end

  if self.state == "resting" then
    return {
      { title = "Cancel Rest", fn = function () self:cancelTimer() end }
    }
  end

  if self.state == "idle" then
    return {
      {
        title = "Start Pomodoro (25/5)",
        fn    = function () self:startPomodoro(25, 5) end
      },
      {
        title = "Start Pomodoro (30/0)",
        fn    = function () self:startPomodoro(30, 0) end
      }
    }
  end

  return {
    { title = "Something is Broken!", disabled = true }
  }
end

function TimerWidget:install ()
  self.timerMenu = hs.menubar.new()

  self.timerMenu:setMenu(function ()
    return self:provideMenu()
  end)

  self:redraw()
end

return TimerWidget
