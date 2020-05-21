if robot.logger then
   robot.logger.register_module("nodes.pick_up_block")
end

-- assume I am forward_distance away from the block
-- shameful move blindly for that far (use reach_block node)
-- move down manipulator to pickup
return function(data, forward_distance)
   return {
      type = 'sequence*',
      children = {
         -- recharge
         function()
            robot.electromagnet_system.set_discharge_mode('disable')
         end,
         -- reach the block
         robot.nodes.create_reach_block_node(data, forward_distance),
         -- touch down
         {
            type = 'selector',
            children = {
               -- hand full ?
               function()
                  robot.logger('check full')
                  if robot.rangefinders['underneath'].proximity < api.parameters.proximity_touch_tolerance then
                     return false, true -- not running, true
                  else
                     return false, false -- not running, false
                  end
               end,
               -- low lift
               function()
                  robot.logger('set down')
                  robot.lift_system.set_position(0)
                  return true
               end
            }
         },
         -- count and raise
         {
            type = 'sequence*',
            children = {
               -- attrack magnet
               function()
                  robot.electromagnet_system.set_discharge_mode('constructive')
               end,
               -- wait for 2 sec
               robot.nodes.create_timer_node({time = 2}),
               -- raise
               function()
                  robot.logger('raising')
                  robot.lift_system.set_position(robot.lift_system.position + 0.05)
                  return false, true -- not running, true
               end,
               -- recharge magnet
               function()
                  robot.electromagnet_system.set_discharge_mode('disable')
               end
            }
         },
         -- check success
         -- wait
         robot.nodes.create_timer_node({time = 2}),
         function()
            if robot.rangefinders['underneath'].proximity < api.parameters.proximity_touch_tolerance then
               return false, true -- not running, true
            else
               return false, false -- not running, false
            end
         end,
         -- change color
         function()
            if target.type ~= nil then
               api.set_type(target.type)
               return false, true
            end
         end
      }
   }
end
