local component = require("component")

---@class ArcaneBoreConfig
---@field redstoneIoAddress string
---@field arcaneBoreSide number
local configParams = {}

local arcaneBore = {}

---Crate new ArcaneBore object from config
---@param config ArcaneBoreConfig
---@return ArcaneBore
function arcaneBore:newFormConfig(config)
  return self:new(config.redstoneIoAddress, config.arcaneBoreSide)
end

---Crate new ArcaneBore object
---@param redstoneIoAddress string
---@param arcaneBoreSide number
---@return ArcaneBore
function arcaneBore:new(redstoneIoAddress, arcaneBoreSide)

  ---@class ArcaneBore
  local obj = {}

  obj.redstoneIoProxy = component.proxy(redstoneIoAddress)

  obj.arcaneBoreSide = arcaneBoreSide

  ---Set work status
  ---@param state boolean
  function obj:setWork(state)
    local signal = (state and 255 or 0)
    self.redstoneIoProxy.setOutput(self.arcaneBoreSide, signal)
  end

  ---Return work status
  ---@return boolean
  function obj:isWork()
    return self.redstoneIoProxy.getOutput(self.arcaneBoreSide) == 255
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return arcaneBore