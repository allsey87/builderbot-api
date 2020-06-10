package.path = package.path .. ";builderbot/?.lua"

function init()
   --[[ load modules ]]--
   -- TODO add verbosity control to logger
   -- TODO logger always prints "MODULE_NAME: MESSAGE"
   robot.logger = require('logger')
   robot.utils = require('utils')
   robot.api = require('api')
   robot.nodes = require('nodes')

   robot.logger.enable()
   robot.logger.set_level("INFO")
   
   --[[ initialize shared data ]]--
   data = {
      blocks = {}
   }

   -- enable the robot's camera
   robot.camera_system.enable()
end

function step()
   robot.logger("INFO", '[reset: clock = ]lalalalala')
   robot.api.process_blocks(data.blocks)
end

function reset()
end

function destroy()
   -- disable the robot's camera
   robot.camera_system.disable()
end
