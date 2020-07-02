if robot.logger then
   robot.logger.register_module("nodes.obstacle_avoidance")
end

-- if there are obstacles avoid it and return running
-- if there no obstacles, return true
return function(data)
   return {
      type = 'selector*',
      children = {
         function()
            local flag = false
            for i, v in ipairs(data.obstacles) do
               if v.position.x < 0.19 and v.position.x > 0.06 then
                  if v.source == 'camera' then
                     flag = true
                     break
                  elseif v.source == 'left' or v.source == 'right' then
                     if robot.rangefinders['underneath'].proximity > robot.api.parameters.proximity_touch_tolerance then
                        if robot.lift_system.position < robot.api.parameters.lift_system_rf_cover_threshold then
                           flag = true
                           break
                        end
                     end
                  elseif v.source == '1' or v.source == '12' then
                     if robot.lift_system.position >= robot.api.parameters.lift_system_rf_cover_threshold then
                        flag = true
                        break
                     end
                  elseif v.source == '2' or v.source == '11' then
                     flag = true
                     break
    
                  end
               end
            end
            if flag == true then
               return false, false
            else
               return false, true
            end
         end,
         -- avoid
         {
            type = 'sequence*',
            children = {
               function()
                  robot.logger("INFO", "obstacle_avoidance: encountered an obstacle, avoiding")
                  return false, true
               end,
               -- backup 8 cm
               -- TODO: remove these hard coded values, use robot.api.parameters.constants
               robot.nodes.create_timer_node(
                  0.08 / robot.api.parameters.default_speed,
                  function()
                     robot.api.move.with_velocity(-robot.api.parameters.default_speed, 
                                                  -robot.api.parameters.default_speed)
                  end
               ),
               -- turn 90
               -- TODO: remove these hard coded values, use robot.api.parameters.constants
               function()
                  local random = robot.random.uniform()
                  local degree = 5
                  if random < 0.5 then degree = -5 end
                  robot.api.move.with_bearing(0, degree)
                  return false, true
               end,
               robot.nodes.create_timer_node(60 / 5),
            }
         }
      }
   }
end
