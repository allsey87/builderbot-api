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
            local random_angle = math.random(-robot.parameters.search_random_range, robot.parameters.search_random_range)
            --api.move(-api.parameters.default_speed, api.parameters.default_speed)
            robot.api.move.with_bearing(robot.parameters.default_speed, random_angle)
            return true
         end
      }
   }
end
