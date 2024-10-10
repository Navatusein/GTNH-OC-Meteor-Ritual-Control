local component = require("component")

---@class OreDrillingPlantConfig
---@field oreDrillingPlantAddress string
---@field cameraAddress string
local configParams = {}

local oreDrillingPlant = {}

---Crate new ArcaneBore object from config
---@param config OreDrillingPlantConfig
---@return OreDrillingPlant
function oreDrillingPlant:newFormConfig(config)
  return self:new(config.oreDrillingPlantAddress, config.cameraAddress)
end

---Crate new OreDrillingPlant object
---@param oreDrillingPlantAddress string
---@param cameraAddress string
---@return OreDrillingPlant
function oreDrillingPlant:new(oreDrillingPlantAddress, cameraAddress)

  ---@class OreDrillingPlant
  local obj = {}

  obj.oreDrillingPlantProxy = component.proxy(oreDrillingPlantAddress)
  obj.cameraProxy = component.proxy(cameraAddress)

  function obj:isWork()
    return self.oreDrillingPlantProxy.isMachineActive()
  end

  function obj:setWork(state)
    self.oreDrillingPlantProxy.setWorkAllowed(state)
  end

  function obj:isPipeRaised()
    return self.cameraProxy.distance(0, 0) ~= 0
  end

  function obj:isEnd()
    if not obj:isPipeRaised() then
      return false
    end

    if obj:isWork() then
      return false
    end

    return true
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return oreDrillingPlant