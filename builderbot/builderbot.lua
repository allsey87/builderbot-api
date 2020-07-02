local bt
--local data
local rules = require("rules")

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
      target = {},
      blocks = {},
      obstacles = {},
      structures = {},
   }

   bt = robot.utils.behavior_tree.create{
      type = "sequence*", children = {
         function() robot.logger("INFO", "----- bt restart ------") return false, true end,
         robot.nodes.create_pick_up_behavior_node(data, rules),

         function() 
            robot.nfc.write("4")
            return false, true
         end,

         robot.nodes.create_place_behavior_node(data, rules),

         function ()
            robot.logger("INFO", "pick up and place finish")
            return false, true
         end,
      }
   }

   -- enable the robot's camera
   robot.camera_system.enable()
end

local function custom_block_type(block)
   if block.tags.up ~= nil and block.tags.up.type == 1 and 
      block.tags.front ~= nil and block.tags.front.type == 2 then
      return 5
   end
end

function step()
   --robot.logger("INFO", '----- step -----', robot.system.time)
   robot.api.process_blocks(data.blocks)
   robot.api.process_leds(data.blocks, custom_block_type)
   robot.api.process_obstacles(data.obstacles, data.blocks)
   --robot.api.process_structures(data.structures, data.blocks)
   bt()

   --robot.logger("INFO", data)

   --[[
   robot.logger("INFO", "data = ")
   robot.logger("INFO", data)
   ]]
end

function reset()
end

function destroy()
   -- disable the robot's camera
   robot.camera_system.disable()
end
