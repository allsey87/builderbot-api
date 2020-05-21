if robot.logger then
   robot.logger.register_module("api.process_leds")
end

-- distance between leds to the center
local led_offset = 0.02
-- from x+, counter-closewise
local led_locations_on_tag = {
   vector3(led_offset, 0, 0),
   vector3(0, led_offset, 0),
   vector3(-led_offset, 0, 0),
   vector3(0, -led_offset, 0)
} 

-- TODO call this function with a single block
return function(block)
   -- takes tags in camera_frame_reference
   -- TODO resolve this global reference to blocks
   for i, block in ipairs(blocks) do
      for j, tag in pairs(block.tags) do
         tag.type = 0
         block.type = 0
         for j, led_location_on_tag in ipairs(led_locations_on_tag) do
            local led_location_on_camera = vector3(led_location_on_tag):rotate(tag.orientation) + tag.position
            local color_number = robot.camera_system.detect_led(led_location_on_camera)
            if color_number ~= tag.type and color_number ~= 0 then
               tag.type = color_number
               block.type = tag.type
            end
         end
      end
   end
end


