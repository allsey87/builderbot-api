package.path = package.path .. ";builderbot/?.lua"

local bt

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
      blocks = {}
   }

   bt = robot.utils.behavior_tree.create{
      type = "sequence*", children = {
         robot.nodes.create_random_walk_node()
      }
   }

   -- enable the robot's camera
   robot.camera_system.enable()
end

function step()
   robot.logger("INFO", '[reset: clock = ]')
   bt()
end

function reset()
end

function destroy()
   -- disable the robot's camera
   robot.camera_system.disable()
end
