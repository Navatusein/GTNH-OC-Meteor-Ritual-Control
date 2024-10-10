local keyboard = require("keyboard")

local programLib = require("lib.program-lib")
local guiLib = require("lib.gui-lib")
local listLib = require("list-lib")
local stateMachineLib = require("lib.state-machine-lib")

local scrollList = require("lib.gui-widgets.scroll-list")

package.loaded.config = nil
local config = require("config")

local program = programLib:new(config.logger)
local gui = guiLib:new(program)
local stateMachine = stateMachineLib:new()

local logo = {
  " __  __      _                    ____  _ _               _    ____            _             _ ",
  "|  \\/  | ___| |_ ___  ___  _ __  |  _ \\(_) |_ _   _  __ _| |  / ___|___  _ __ | |_ _ __ ___ | |",
  "| |\\/| |/ _ \\ __/ _ \\/ _ \\| '__| | |_) | | __| | | |/ _` | | | |   / _ \\| '_ \\| __| '__/ _ \\| |",
  "| |  | |  __/ ||  __/ (_) | |    |  _ <| | |_| |_| | (_| | | | |__| (_) | | | | |_| | | (_) | |",
  "|_|  |_|\\___|\\__\\___|\\___/|_|    |_| \\_\\_|\\__|\\__,_|\\__,_|_|  \\____\\___/|_| |_|\\__|_|  \\___/|_|"
}

local logs = listLib:new(32)

local mainTemplate = {
  width = 60,
  background = gui.palette.black,
  foreground = gui.palette.white,
  widgets = {
    logsScrollList = scrollList:new("logs", keyboard.keys.up, keyboard.keys.down)
  },
  lines = {
    "Status: $state$",
    "Meteor: $meteor$",
    "LP: $lp:n$",
    "",
    "#logsScrollList#",
    "#logsScrollList#",
    "#logsScrollList#",
    "#logsScrollList#",
    "#logsScrollList#",
    "#logsScrollList#",
    "#logsScrollList#",
    "#logsScrollList#",
    "#logsScrollList#",
    "#logsScrollList#",
    "#logsScrollList#",
    "#logsScrollList#",
    "#logsScrollList#",
    "#logsScrollList#",
    "#logsScrollList#"
  }
}

local function init()
  gui:setTemplate(mainTemplate)

  stateMachine.states.init = stateMachine:createState("Init")
  stateMachine.states.init.update = function()
    for _, miner in pairs(config.miners) do
      if not miner:isEnd() then
        stateMachine:setState(stateMachine.states.mine)
        return
      end
    end

    stateMachine:setState(stateMachine.states.clear)
  end

  stateMachine.states.idle = stateMachine:createState("Idle")
  stateMachine.states.idle.update = function()
    os.sleep(3);
    stateMachine:setState(stateMachine.states.start)
  end

  stateMachine.states.start = stateMachine:createState("Start")
  stateMachine.states.start.init = function()
    local item = config.ritual:getItem()

    if not item then
      stateMachine:setState(stateMachine.states.idle)
      return
    end

    stateMachine.data.item = item

    if not config.ritual:isEnoughLp(item) then
      stateMachine:setState(stateMachine.states.waitLp)
      return
    end

    stateMachine:setState(stateMachine.states.spawn)
  end

  stateMachine.states.waitLp = stateMachine:createState("Wait LP")
  stateMachine.states.waitLp.init = function()
    logs:pushFront("&red;Not enough LP for summon&white;")
  end
  stateMachine.states.waitLp.update = function()
    if config.ritual:isEnoughLp(stateMachine.data.item) then
      stateMachine:setState(stateMachine.states.spawn)
    end

    os.sleep(3);
  end

  stateMachine.states.spawn = stateMachine:createState("Spawn")
  stateMachine.states.spawn.init = function()
    if stateMachine.data.item.chestSide == config.ritual.priorityChestSide then
      logs:pushFront("From &yellow;priority chest&white;:"..stateMachine.data.item.label)
    else
      logs:pushFront("From &pink;random chest&white;:"..stateMachine.data.item.label)
    end

    config.ritual:spawn(stateMachine.data.item)
  end
  stateMachine.states.spawn.update = function()
    if not config.ritual:isMeteorExcavated() then
      stateMachine:setState(config.forceMode and stateMachine.states.clear or stateMachine.states.mine)
    end
  end

  stateMachine.states.mine = stateMachine:createState("Mine")
  stateMachine.states.mine.init = function()
    for _, miner in pairs(config.miners) do
      miner:setWork(true)
    end
  end
  stateMachine.states.mine.update = function()
    local flag = true

    for _, miner in pairs(config.miners) do
      if not miner:isEnd() then
        flag = false

        if not miner:isWork() then
          miner:setWork(true)
        end
      end
    end

    if flag then
      stateMachine:setState(stateMachine.states.clear)
    end
  end

  stateMachine.states.clear = stateMachine:createState("Clear")
  stateMachine.states.clear.init = function()
    config.arcaneBore:setWork(true)
  end
  stateMachine.states.clear.update = function()
    if config.ritual:isMeteorExcavated() then
      config.arcaneBore:setWork(false)
      stateMachine.data.item = nil
      os.sleep(8)
      stateMachine:setState(stateMachine.states.start)
    end
  end

  stateMachine:setState(stateMachine.states.init)
end

local function loop()
  while true do
    stateMachine:update()
    stateMachine.data.lp = config.ritual:getLp()
    os.sleep(5)
  end
end

local function guiLoop()
  gui:render({
    state = (stateMachine.currentState and stateMachine.currentState.name) or "nil",
    lp = stateMachine.data.lp or 0,
    meteor = (stateMachine.data.item and stateMachine.data.item.label) or "nil",
    logs = logs.list
  })
end

program:registerLogo(logo)
program:registerInit(init)
program:registerThread(loop)
program:registerTimer(guiLoop, math.huge)
program:start()