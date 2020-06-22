if robot.logger then
   robot.logger.register_module("nodes.random_walk")
end

-- if there are obstacles avoid it and return running
-- if there no obstacles, return true
return function()
   return {
      type = 'sequence',
      children = {
         function()
            -- TODO use robot.random!
            --local random_angle = math.random(-robot.api.parameters.search_random_range, robot.api.parameters.search_random_range)
            local random_angle = robot.random.uniform(-robot.api.parameters.search_random_range, robot.api.parameters.search_random_range)
            --robot.api.move(-robot.api.parameters.default_speed, robot.api.parameters.default_speed)
            robot.api.move.with_bearing(robot.api.parameters.default_speed, random_angle)
            return true
         end
      }
   }
end
