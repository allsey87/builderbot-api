package.path = package.path .. ";builderbot/?.lua"

local data
function init()
   --[[ load modules ]]--
   robot.logger = require('logger')
   robot.utils = require('utils')
   robot.api = require('api')
   robot.nodes = require('nodes')

   robot.logger.enable()
   robot.logger.set_level("INFO")
   
   --[[ initialize shared data ]]--
   data = {
      blocks = {},
      obstacles = {},
      structures = {},
   }

   -- enable the robot's camera
   robot.camera_system.enable()
end

function step()
   robot.logger("INFO", '[reset: clock = ]lalalalala')
   robot.api.process_blocks(data.blocks)
   -- figure out led color for tags
   robot.api.process_leds(data.blocks)
   robot.api.process_obstacles(data.obstacles, data.blocks)
   robot.api.process_structures(data.structures, data.blocks)
   robot.logger("INFO", data)
end

function reset()
end

function destroy()
   -- disable the robot's camera
   robot.camera_system.disable()
end
