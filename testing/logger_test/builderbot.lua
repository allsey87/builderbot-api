package.path = package.path .. ";builderbot/?.lua"

function init()
   --[[ load modules ]]--
   robot.logger = require('logger')
   robot.utils = require('utils')
   robot.api = require('api')
   robot.nodes = require('nodes')

   logger_test = require("logger_test")

   robot.logger.enable()
   robot.logger.enable("logger_test")
   --robot.logger.disable("nil")
   
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

   robot.logger("INFO", {a = 2, b = "test", c = {aa = 22, bb = "testtest"}})
   robot.logger("INFO", {a = 2, b = "test", c = {aa = 22, bb = "testtest"}}, 2, "c")
   --robot.api.process_blocks(data.blocks)

   logger_test()
end

function reset()
    robot.logger('[reset: clock = ]')
end

function destroy()
   -- disable the robot's camera
end
