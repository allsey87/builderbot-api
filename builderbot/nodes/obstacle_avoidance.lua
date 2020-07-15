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
                  robot.camera_system.disable()
                  return false, true
               end,
               -- backup for obstacle_avoidance_backup
               robot.nodes.create_timer_node(
                  function()
                     robot.api.move.with_velocity(-robot.api.parameters.default_speed, 
                                                  -robot.api.parameters.default_speed)
                     return robot.api.parameters.obstacle_avoidance_backup / robot.api.parameters.default_speed
                  end
               ),
               robot.nodes.create_timer_node(
                  function()
                     local degree = robot.random.uniform(robot.api.parameters.obstacle_avoidance_turn, 180)
                     local turn_left = robot.random.bernoulli()
                     if turn_left then
                        robot.api.move.with_bearing(0, robot.api.parameters.default_turn_speed)
                     else
                        robot.api.move.with_bearing(0, -robot.api.parameters.default_turn_speed)
                     end
                     return degree / robot.api.parameters.default_turn_speed
                  end
               ),
               function()
                  robot.camera_system.enable()
                  return false, true
               end,
            }
         }
      }
   }
end
