if robot.logger then
   robot.logger.register_module("nodes.search_block")
end

return function(rule_node)
   -- create a search node based on rule_node
   return {
      type = "sequence*",
      children = {
         -- prepare, lift to 0.highest
         {
            type = "selector",
            children = {
               -- if lift reach position(0.07), return true, stop selector
               function()
                  if (robot.lift_system.position > robot.api.parameters.lift_system_upper_limit - 
                        robot.api.parameters.lift_system_position_tolerance) and
                     (robot.lift_system.position < robot.api.parameters.lift_system_upper_limit +
                        robot.api.parameters.lift_system_position_tolerance) then
                     robot.logger("search_in position")
                     return false, true
                  else
                     robot.logger("search_not in position")
                     return false, false
                  end
               end,
               -- set position(0.07)
               function()
                  robot.lift_system.set_position(robot.api.parameters.lift_system_upper_limit)
                  return true -- always running
               end,
            },
         },
         -- search
         {
            type = "sequence",
            children = {
               -- check obstacle and randomwalk
               {
                  type = "sequence",
                  children = {
                     -- if obstacle and avoid
                     robot.nodes.create_obstacle_avoidance_node(),
                     -- obstacle clear, random walk
                     function()
                        -- TODO use robot.random
                        local random_angle =
                           math.random(-robot.api.parameters.search_random_range,
                                        robot.api.parameters.search_random_range)
                        --robot.api.move(-robot.api.parameters.default_speed, robot.api.parameters.default_speed)
                        robot.api.move.with_bearing(robot.api.parameters.default_speed,
                                                    random_angle)
                        return false, true
                     end,
                  },
               },
               -- choose a block,
               -- if got one, return true, stop sequence
               rule_node,
            },
         },
      },
   }
end
