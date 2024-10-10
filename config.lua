local sides = require("sides")

local loggerLib = require("lib.logger-lib")
local discordLoggerHandler = require("lib.logger-handler.discord-logger-handler-lib")
local fileLoggerHandler = require("lib.logger-handler.file-logger-handler-lib")

local ritualLib = require("src.ritual")
local arcaneBoreLib = require("src.arcane-bore")
local oreDrillingPlantLib = require("src.ore-drilling-plant")

local config = {
  logger = loggerLib:newFormConfig({
    name = "Meteor Ritual Control",
    timeZone = 3, -- Your time zone
    handlers = {
      discordLoggerHandler:newFormConfig({
        logLevel = "warning",
        messageFormat = "{Time:%d.%m.%Y %H:%M:%S} [{LogLevel}]: {Message}",
        discordWebhookUrl = "" -- Discord Webhook URL
      }),
      fileLoggerHandler:newFormConfig({
        logLevel = "info",
        messageFormat = "{Time:%d.%m.%Y %H:%M:%S} [{LogLevel}]: {Message}",
        filePath = "logs.log"
      })
    }
  }),

  forceMode = false, -- Enable force mode (Dig meteor only with arcane bore)

  ritual = ritualLib:newFormConfig({
    redstoneIoAddress = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", -- Address of Redstone I/O witch control dynamism table
    dynamismTableSide = sides.top, -- Side of Redstone I/O witch connected to dynamism table
    transposerAddress = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", -- Address of the transposer
    dropperSide = sides.south, -- Side of the transposer with dropper
    priorityChestSide = sides.east, -- Side of the transposer with priority chest
    randomChestSide = sides.west, -- Side of the transposer with random chest
    alchemicChemistrySetSide = sides.top, -- Side of the transposer with alchemic chemistry set
    cameraAddress = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa" -- Address of camera under meteor
  }),

  arcaneBore = arcaneBoreLib:newFormConfig({
    redstoneIoAddress = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", -- Address of Redstone I/O witch control arcane bore
    arcaneBoreSide = sides.west -- Side of Redstone I/O witch connected to redstone
  }),

  miners = {
    oreDrillingPlantLib:newFormConfig({ -- Can be copied multiple times
      oreDrillingPlantAddress = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", -- Address of ore drilling plant
      cameraAddress = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa" -- Address of camera under ore drilling plant
    }),
    oreDrillingPlantLib:newFormConfig({
      oreDrillingPlantAddress = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
      cameraAddress = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
    }),
  }
}

return config