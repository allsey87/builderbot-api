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
      blocks = {},
      obstacles = {},
   }

   bt = robot.utils.behavior_tree.create{
      type = "sequence*", children = {
         robot.nodes.create_search_block_node(data, 
            -- consider the first block as target
            function ()
               if data.blocks[1] ~= nil then
                  robot.logger("INFO", "rule_node: got blocks[1]")
                  data.target = {
                     id = 1,
                     offset = vector3(),
                  }
                  return false, true
               else
                  return false, false
               end
            end
         ),
         robot.nodes.create_curved_approach_block_node(data, 0.20),
         robot.nodes.create_pick_up_block_node(data, 0.20),
         function ()
            robot.logger("INFO", "pick up ended")
            return false, true
         end,
         function ()
            return true
         end,
      }
   }

   -- enable the robot's camera
   robot.camera_system.enable()
end

function step()
   --robot.logger("INFO", '----- step -----')
   robot.api.process_blocks(data.blocks)
   robot.api.process_leds(data.blocks)
   robot.api.process_obstacles(data.obstacles, data.blocks)
   bt()
   --robot.logger("INFO", "data = ")
   --robot.logger("INFO", data)
end

function reset()
end

function destroy()
   -- disable the robot's camera
   robot.camera_system.disable()
end
