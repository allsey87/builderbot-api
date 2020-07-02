package.path = package.path .. ";builderbot/?.lua"

local bt
local data
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
         robot.nodes.create_search_block_node(data, 
            robot.nodes.create_process_rules_node(data, rules, "pickup")
         ),
         robot.nodes.create_curved_approach_block_node(data, 0.20),
         robot.nodes.create_pick_up_block_node(data, 0.20),

         robot.nodes.create_search_block_node(data, 
            robot.nodes.create_process_rules_node(data, rules, "place")
         ),
         robot.nodes.create_curved_approach_block_node(data, 0.20),
         robot.nodes.create_place_block_node(data, 0.20),
         function ()
            robot.logger("INFO", "pick up and place finish")
            return false, true
         end,
      }
   }

   -- enable the robot's camera
   robot.camera_system.enable()
end

function step()
   --robot.logger("INFO", '----- step -----', robot.system.time)
   robot.api.process_blocks(data.blocks)
   robot.api.process_leds(data.blocks)
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
