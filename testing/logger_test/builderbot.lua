package.path = package.path .. ";builderbot/?.lua"

function init()
   --[[ load modules ]]--
   -- TODO add verbosity control to logger
   -- TODO logger always prints "MODULE_NAME: MESSAGE"
   robot.logger = require('logger')
   robot.utils = require('utils')
   robot.api = require('api')
   robot.nodes = require('nodes')

   logger_test = require("logger_test")

   robot.logger.enable()
   robot.logger.enable("logger_test")
   robot.logger.disable("nil")
   
   --robot.logger.set_level("ERR")
   --robot.logger.set_level("WARN")
   robot.logger.set_level("INFO")
   --robot.logger.set_level("non_sense")

   --[[ initialize shared data ]]--
   data = {
      blocks = {}
   }
end

function step()
   robot.logger("INFO", '[step: clock = ]')
   robot.logger("ERR", 'something is wrong')
   robot.logger("WARN", 'something is suspicious')
   robot.logger("NON_SENSE", 'nonsense')
   --robot.api.process_blocks(data.blocks)

   logger_test()
end

function reset()
    robot.logger('[reset: clock = ]')
    -- TODO: recreate init shared data
    -- TODO: recreate behavior tree
end

function destroy()
   -- disable the robot's camera
end
