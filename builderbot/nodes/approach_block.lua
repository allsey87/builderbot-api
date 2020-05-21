if robot.logger then
   robot.logger.register_module("nodes.approach_block")
end

return function(data, search_node, distance)
   return {
      type = "sequence*",
      children = {
         -- search block
         search_node,
         -- check range and blind approach and search again
         {
            type = "selector*",
            children = {
               -- check range
               function()
                  local target_block = data.blocks[data.target.reference_id]
                  local robot_to_block = vector3(-target_block.position_robot):rotate(target_block.orientation_robot:inverse())
                  local angle = math.atan(robot_to_block.y / robot_to_block.x) * 180 / math.pi
                  local blind_tolerance = 20
                  if angle < blind_tolerance and angle > -blind_tolerance and robot_to_block:length() < 0.27 then 
                     return false, true
                  else
                     return false, false
                  end
               end,
               -- not in range, blind approach and search
               {
                  type = "sequence*",
                  children = {
                     robot.nodes.create_z_approach_block_node(data, distance + 0.05),
                     function() print("in approach_node, before search") return false, true end,
                     search_node,
                     function() print("in approach_node, after search") return false, true end,
                  },
               }, 
            }, -- end of chilren
         }, -- end of check range and blind approach and search again
         -- now should be in range, curved approach
         robot.nodes.create_curved_approach_block_node(data, distance)
      }, -- end of children of the return table
   } -- end of the return table
end

