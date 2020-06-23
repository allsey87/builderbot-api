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

   local create_rule_node = function(pickup_or_place)
      -- consider the first block in the array as target
      return function()
         for i = 1, 10 do
            if data.blocks[i] ~= nil then
               robot.logger("INFO", "rule_node: got a block, id = ", i)
               data.target = {
                  id = i,
                  offset = vector3(),
               }
               if pickup_or_place == "place" then
                  data.target.offset = vector3(0,0,1)
               end
               return false, true
            end
         end
         return false, false
      end
   end

   bt = robot.utils.behavior_tree.create{
      type = "sequence*", children = {
         robot.nodes.create_search_block_node(data, 
            create_rule_node("pickup")
         ),
         robot.nodes.create_curved_approach_block_node(data, 0.20),
         robot.nodes.create_pick_up_block_node(data, 0.20),

         robot.nodes.create_search_block_node(data, 
            create_rule_node("place")
         ),
         robot.nodes.create_curved_approach_block_node(data, 0.20),
         robot.nodes.create_place_block_node(data, 0.20),
         function ()
            robot.logger("INFO", "pick up and place finish")
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
