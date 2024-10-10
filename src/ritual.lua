local component = require("component")

local meteors = {
  ["Melon"] = 123456,
  ["Emitter (LV)"] = 300000,
  ["Sensor (LV)"] = 300000,
  ["Exquisite Diamond"] = 420000,
  ["End Stone"] = 500000,
  ["Firestone Lens"] = 500000,
  ["Sensor (HV)"] = 500000,
  ["Heavy Duty Alloy Ingot T1"] = 500000,
  ["Field Generator (LV)"] = 600000,
  ["Cheese"] = 650000,
  ["Nether Star"] = 750000,
  ["Heavy Duty Alloy Ingot T2"] = 750000,
  ["TNT"] = 775000,
  ["Sanitizing Soap"] = 800000,
  ["Heavy Duty Alloy Ingot T3"] = 1000000,
  ["Field Generator (HV)"] = 1000000,
  ["Heavy Duty Plate"] = 1000000,
  ["Advanced Replicator"] = 1200000,
  ["Field Generator (IV)"] = 1500000,
  ["Advanced Assembling Machine III"] = 2000000,
  ["Emitter (HV)"] = 2000000,
  ["Advanced Mass Fabricator IV"] = 2500000,
  ["Advanced Circuit Assembler II"] = 3250000,
  ["Soul Sand"] = 5000000,
  ["Advanced Mass Fabricator II"] = 6000000,
  ["Pufferfish"] = 6666666,
  ["Heavy Duty Plate Tier 4"] = 7500000,
  ["Boxinator"] = 10000000,
  ["Heavy Duty Plate Tier 5"] = 10000000,
  ["Advanced Scanner IV"] = 12500000,
  ["Heavy Duty Plate Tier 6"] = 15000000,
  ["Crystalprocessor Mainframe"] = 25000000,
  ["Heavy Duty Plate Tier 7"] = 30000000,
  ["Elite Recycler"] = 44000000,
  ["Wetware Supercomputer"] = 50000000,
  ["Heavy Duty Plate Tier 8"] = 50000000,
  ["Advanced Circuit Assembler VI"] = 80000000,
  ["Elite Mass Fabricator II"] = 100000000,
  ["Advanced Crop Synthesiser VII"] = 125000000,
  ["Ion Thruster Jet"] = 1000000001
}

---@class Item
---@field chestSide number
---@field slotIndex number
---@field label string
local item = {}

---@class RitualConfig
---@field redstoneIoAddress string
---@field dynamismTableSide number
---@field transposerAddress string
---@field dropperSide number
---@field priorityChestSide number
---@field randomChestSide number
---@field alchemicChemistrySetSide number
---@field cameraAddress string
local configParams = {}

local ritual = {}

---Crate new Ritual object from config
---@param config RitualConfig
---@return Ritual
function ritual:newFormConfig(config)
  return self:new(
    config.redstoneIoAddress, 
    config.dynamismTableSide,
    config.transposerAddress,
    config.dropperSide,
    config.priorityChestSide,
    config.randomChestSide,
    config.alchemicChemistrySetSide,
    config.cameraAddress
  )
end

---Crate new Ritual object
---@param redstoneIoAddress string
---@param dynamismTableSide number
---@param transposerAddress string
---@param dropperSide number
---@param priorityChestSide number
---@param randomChestSide number
---@param alchemicChemistrySetSide number
---@param cameraAddress string
---@return Ritual
function ritual:new(
  redstoneIoAddress,
  dynamismTableSide,
  transposerAddress,
  dropperSide,
  priorityChestSide,
  randomChestSide,
  alchemicChemistrySetSide,
  cameraAddress
)

  ---@class Ritual
  local obj = {}

  obj.redstoneIoProxy = component.proxy(redstoneIoAddress)
  obj.dynamismTableSide = dynamismTableSide

  obj.transposerProxy = component.proxy(transposerAddress)
  obj.dropperSide = dropperSide
  obj.priorityChestSide = priorityChestSide
  obj.randomChestSide = randomChestSide
  obj.alchemicChemistrySetSide = alchemicChemistrySetSide

  obj.cameraProxy = component.proxy(cameraAddress)

  ---Check if meteor is excavated
  ---@return boolean
  function obj:isMeteorExcavated()
    for i = -0.36, 0.36, 0.04 do
      if self.cameraProxy.distance(i, 0) ~= -1 then
        return false
      end
    end

    return true
  end

  ---Check if chest is empty
  ---@param side number
  ---@return boolean
  function obj:isChestEmpty(side)
    local slots = self.transposerProxy.getAllStacks(side).getAll()

    for _, value in pairs(slots) do
      if next(value) ~= nil then
        return false
      end
    end

    return true
  end

  ---Get item from chest
  ---@param side any
  ---@param random any
  ---@return nil|Item
  function obj:getItemFromChest(side, random)
    if self:isChestEmpty(side) then
      return nil
    end

    local slots = self.transposerProxy.getAllStacks(side).getAll()
    local slotIndex = 0

    while true do
      if random then
        slotIndex = math.random(0, #slots)
      end

      if next(slots[slotIndex]) ~= nil then
        return {
          slotIndex = slotIndex,
          chestSide = side,
          label = slots[slotIndex].label
        }
      end

      slotIndex = slotIndex + 1
    end
  end

  ---Get item
  ---@return nil|Item
  function obj:getItem()
    local item = self:getItemFromChest(self.priorityChestSide, false)

    if item then
      return item
    end

    return self:getItemFromChest(self.randomChestSide, true)
  end

  ---Get LP
  ---@return number
  function obj:getLp()
    return self.transposerProxy.getStackInSlot(self.alchemicChemistrySetSide, 1).networkEssence
  end

  ---Check is enough LP
  ---@param item Item
  ---@return boolean
  function obj:isEnoughLp(item)
    return self:getLp() >= meteors[item.label] + 200000
  end

  ---Spawn meteor
  ---@param item Item
  function obj:spawn(item)
    self.redstoneIoProxy.setOutput(self.dynamismTableSide, 15)
    os.sleep(1)
    self.redstoneIoProxy.setOutput(self.dynamismTableSide, 0)

    self.transposerProxy.transferItem(item.chestSide, self.dropperSide, 1, item.slotIndex + 1)
  end

  setmetatable(obj, self)
  self.__index = self
  return obj
end

return ritual