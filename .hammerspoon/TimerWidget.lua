local TimerWidget = { }

function TimerWidget:new (obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self

  obj.state = "idle"
  obj.runDuration  = 25 * 60
  obj.restDuration = 5 * 60

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

function TimerWidget:startPomodoro ()
  self.state = "running"


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
  self.doneAt = hs.timer.secondsSinceEpoch() + self.restDuration
  self.timer = hs.timer.doEvery(1, function () self:tick() end)
  self:redraw()
end

function TimerWidget:cancelTimer ()
  if self.timer then
    self.timer:stop()
    self.timer = nil
  end

  self:blink("ff00ff", 3)

  self.blinkSlice = nil
  self.doneAt = nil
  self.state = "idle"
  self:redraw()
end

function TimerWidget:blink (rgb, count)
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
    if self.state == "running" then
      self.timer:stop()
      self:startRest()
      self:blink("ff0000", 5)
    else
      self:cancelTimer()
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
      { title = "Start Pomodoro", fn = function () self:startPomodoro() end }
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
