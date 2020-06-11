if robot.logger then
   robot.logger.register_module("api.process_obstacles")
end

return {
   -- process obstacles
   -- TODO return obstacles? 
   process_obstacles = function()
      local end_effector_position =
         robot.api.constants.end_effector_position_offset + vector3(0, 0, robot.lift_system.position)

      obstacles = {}
      for i, rf in pairs(robot.rangefinders) do
         -- TODO spelling
         if rf.proximity >= robot.api.parameters.proximity_maximum_distace then
            -- TODO math.huge?
            rf.proximity = 9999
         end
         local obstacle_position_robot =
            vector3(0, 0, rf.proximity):rotate(rf.transform.orientation) + rf.transform.position
         if rf.transform.anchor == 'end_effector' then
            obstacle_position_robot = obstacle_position_robot + end_effector_position
         end
         obstacles[#obstacles + 1] = {
            position = obstacle_position_robot,
            source = tostring(i)
         }
      end
      for i, block in ipairs(api.blocks) do
         obstacles[#obstacles + 1] = {
            position = block.position_robot,
            source = 'camera'
         }
      end
   end,
}

