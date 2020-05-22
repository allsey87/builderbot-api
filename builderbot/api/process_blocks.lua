if robot.logger then
   robot.logger.register_module("api.process_blocks")
end

return function(blocks)
   if blocks == nil then
      error("block table was nil")
   end
   -- calculate the camera position
   local camera_position =
      robot.api.constants.end_effector_position_offset +
      robot.camera_system.transform.position +
      vector3(0, 0, robot.lift_system.position)
   -- track blocks
   robot.hlapi.track_blocks(blocks, robot.camera_system.tags)
   -- figure out led color for tags
   robot.hlapi.process_leds()
   -- cache the block's position and orientation in the robot's coordinate system
   for i, block in pairs(blocks) do
      block.position_robot =
         vector3(block.position):rotate(robot.camera_system.transform.orientation) + camera_position
      block.orientation_robot = robot.camera_system.transform.orientation * block.orientation
   end
end


