if robot.logger then
   robot.logger.register_module("nodes.reach_block")
end

-- assuming I'm distance away of the block, 
-- shamefully forward blindly for a certain distance
-- based on target.offset, adjust the distance and 
--                         raise or lower the manipulator
--     offset could be vector3(0,0,0), means the reference block itself
--                     vector3(1,0,0), means just infront of the reference block
--                     vector3(0,0,1), top of the reference block
--                     vector3(1,0,-1)
--                     vector3(1,0,-2)
return function(target, distance)
   return {
      type = "sequence*",
      children = {
         -- assume I arrive the pre-position, reach it
         {
            type = "selector*",
            children = {
               -- reach the block itself
               {
                  type = "sequence*",
                  children = {
                     -- condition vector3(0,0,0)
                     function ()
                        if target.offset == vector3(0,0,0) then
                           return false, true
                        else
                           return false, false
                        end
                     end,
                     -- raise lift
                     function()
                        robot.lift_system.set_position(robot.llapi.blocks[target.reference_id].position_robot.z) 
                        return false, true
                     end,
                     -- wait for 1s
                     robot.nodes.create_timer_node({time = 3,}),
                     -- forward to block
                     robot.nodes.create_timer_node({
                        time = (distance - robot.api.constants.end_effector_position_offset.x) /
                           robot.api.parameters.default_speed,
                        func = function()
                           robot.api.move.with_velocity(robot.api.parameters.default_speed, 
                                                        robot.api.parameters.default_speed)
                        end,
                     })
                  },
               },
               -- reach the top of the reference block
               {
                  type = "sequence*",
                  children = {
                     -- condition vector3(0,0,1)
                     function ()
                        if target.offset == vector3(0,0,1) then
                           return false, true
                        else
                           return false, false
                        end
                     end,
                     -- raise lift
                     function()
                        robot.lift_system.set_position(llapi.blocks[target.reference_id].position_robot.z + 0.055) 
                        return false, true
                     end,
                     -- wait for 1s
                     robot.nodes.create_timer_node({
                        time = 5,
                     }),
                     -- forward to block
                     robot.nodes.create_timer_node({
                        time = (distance - robot.api.constants.end_effector_position_offset.x - 0.005) /
                               robot.api.parameters.default_speed,
                        func = function()
                           robot.api.move.with_velocity(robot.api.parameters.default_speed, 
                                                        robot.api.parameters.default_speed)
                           end,
                     })
                  },
               },
               -- reach the front of the reference block
               {
                  type = "sequence*",
                  children = {
                     -- condition vector3(1,0,0)
                     function ()
                        if target.offset == vector3(1,0,0) then
                           return false, true
                        else
                           return false, false
                        end
                     end,
                     -- raise lift
                     function()
                        robot.lift_system.set_position(robot.llapi.blocks[target.reference_id].position_robot.z) 
                        return false, true
                     end,
                     -- wait for 1s
                     robot.nodes.create_timer_node({time = 3,}),
                     -- forward in front of block
                     robot.nodes.create_timer_node({
                        time = (distance - robot.api.constants.end_effector_position_offset.x - 0.060) /
                                robot.api.parameters.default_speed,
                        func = function()
                           robot.api.move(robot.api.parameters.default_speed, 
                                          robot.api.parameters.default_speed)
                           end,
                     })
                  },
               },
               -- reach the front down of the reference block
               {
                  type = "sequence*",
                  children = {
                     -- condition vector3(1,0,-1)
                     function ()
                        if target.offset == vector3(1,0,-1) then
                           return false, true
                        else
                           return false, false
                        end
                     end,
                     -- lower lift
                     function()
                        robot.lift_system.set_position(robot.llapi.blocks[target.reference_id].position_robot.z - 0.055) 
                        return false, true
                     end,
                     -- wait for 1s
                     robot.nodes.create_timer_node({time = 3,}),
                     -- forward in front of block
                     robot.nodes.create_timer_node({
                        time = (distance - robot.api.constants.end_effector_position_offset.x - 0.060) /
                               robot.api.parameters.default_speed,
                        func = function()
                           robot.api.move.with_velocity(robot.api.parameters.default_speed, 
                                                        robot.api.parameters.default_speed)
                           end,
                     })
                  },
               },
               -- reach the front down down of the reference block
               {
                  type = "sequence*",
                  children = {
                     -- condition vector3(1,0,-2)
                     function ()
                        if target.offset == vector3(1,0,-2) then
                           return false, true
                        else
                           return false, false
                        end
                     end,
                     -- lower lift
                     function()
                        robot.lift_system.set_position(robot.llapi.blocks[target.reference_id].position_robot.z - 0.11) 
                        return false, true
                     end,
                     -- wait for 1s
                     robot.nodes.create_timer_node({time = 5,}),
                     -- forward in front of block
                     robot.nodes.create_timer_node({
                        time = (distance - robot.api.constants.end_effector_position_offset.x - 0.060) /
                               robot.api.parameters.default_speed,
                        func = function()
                           robot.api.move.with_velocity(robot.api.parameters.default_speed, 
                                                        robot.api.parameters.default_speed)
                        end
                     })
                  },
               },
            }, -- end of children of step forward
         }, -- end of step forward
         -- stop
         function() robot.api.move.with_velocity(0,0) return false, true end,
      }, -- end of the children of the return table
   } -- end of the return table
end
