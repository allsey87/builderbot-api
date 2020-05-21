function init()
   --[[ load modules ]]--
   -- TODO add verbosity control to logger
   -- TODO logger always prints "MODULE_NAME: MESSAGE"
   robot.logger = require('logger')
   robot.utils = require('utils')
   robot.api = require('api')
   robot.nodes = require('nodes')
   --[[ configure and initialize behavior tree ]]--
   local data = {
      target = {
         id = 1,
         offset = vector3(0,0,0),
         color = "green",
      },
      blocks = {}
   }
   local top_level_node = {
      type = 'sequence*',
      children = {
         robot.nodes.create_pickup_block_node(data, 0.15),
         -- update the target data
         function() 
            data.target.offset = vector3(0,0,1) 
            data.target.color = "pink"
            return false, true 
         end,
         robot.nodes.create_place_block_node(
            data,
            0.15 + robot.api.constants.end_effector_position_offset.x),
          -- stop
          function() robot.api.move.with_velocity(0,0) return true end,
       },
    }
    -- generate the behavior tree
    robot.behavior = 
      robot.utils.behavior_tree.create(top_level_node)
    -- enable the robot's camera
    robot.camera_system.enable()
end

function step()
   robot.logger('[step: clock = ]')
   robot.api.process_blocks()
   robot.api.process_obstacles()
   robot.behavior()
end

function reset()
    robot.logger('[reset: clock = ]')
    -- recreate data
    -- 
end

function destroy()
   -- disable the robot's camera
   robot.camera_system.disable()
end
