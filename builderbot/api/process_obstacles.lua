if robot.logger then
   robot.logger.register_module("api.process_obstacles")
end

return {
   -- process LEDs
   process_leds = function()
      -- takes tags in camera_frame_reference
      local led_dis = 0.02 -- distance between leds to the center
      local led_loc_for_tag = {
         vector3(led_dis, 0, 0),
         vector3(0, led_dis, 0),
         vector3(-led_dis, 0, 0),
         vector3(0, -led_dis, 0)
      } -- from x+, counter-closewise

      for i, block in ipairs(blocks) do
         for j, tag in pairs(block.tags) do
            tag.type = 0
            block.type = 0
            for j, led_loc in ipairs(led_loc_for_tag) do
               local led_loc_for_camera = vector3(led_loc):rotate(tag.orientation) + tag.position
               local color_number = robot.camera_system.detect_led(led_loc_for_camera)
               if color_number ~= tag.type and color_number ~= 0 then
                  tag.type = color_number
                  block.type = tag.type
               end
            end
         end
      end
   end,

   -- process blocks
   process_blocks = function(blocks)
      if blocks == nil then
         error("block table was nil")
      end
      -- calculate the camera position
      local camera_position =
         constants.end_effector_position_offset +
         robot.camera_system.transform.position +
         vector3(0, 0, robot.lift_system.position)
      -- track blocks
      track_blocks(blocks, robot.camera_system.tags)
      -- figure out led color for tags
      process_leds()
      -- cache the block's position and orientation in the robot's coordinate system
      for i, block in pairs(blocks) do
         block.position_robot =
            vector3(block.position):rotate(robot.camera_system.transform.orientation) + camera_position
         block.orientation_robot = robot.camera_system.transform.orientation * block.orientation
      end
   end,

   -- process obstacles
   -- TODO return obstacles? 
   process_obstacles = function()
      local end_effector_position =
         constants.end_effector_position_offset + vector3(0, 0, robot.lift_system.position)

      obstacles = {}
      for i, rf in pairs(robot.rangefinders) do
         -- TODO spelling
         if rf.proximity >= parameters.proximity_maximum_distace then
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

