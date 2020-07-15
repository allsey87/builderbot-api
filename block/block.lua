local color = {"magenta", "orange", "green", "blue"}
color[0] = "black"

local direction = {"top", "north", "west", "east", "south", "bottom"}
local direction_number = {
   top = 1, 
   north = 2, 
   west = 3,
   east = 4, 
   south = 5, 
   bottom = 6,
}

function init()
   robot.api = require("api")
   robot.logger = require("builderbot.logger")
   robot.logger.enable()
   robot.logger.set_level("INFO")

   reset()
end

function reset()
   if robot.id == "block1" then
      robot.api.set_face_color("top", color[1])
      for i = 2, 5 do
         robot.api.set_face_color(direction[i], color[2])
      end
   end

   if robot.id == "block6" then
      robot.directional_leds.set_all_colors(color[3])
   end
end

function step()
   for face, radio in pairs(robot.radios) do
      if #radio.rx_data > 0 then        
         local received = radio.rx_data[1][1]
         if received > 48 then
            received = received - 48
            robot.directional_leds.set_all_colors(color[received])
         else
            local opposite_face = direction[7 - direction_number[face]]
            if received > 0 then
               robot.api.set_face_color(opposite_face, color[2])
               robot.radios[opposite_face].tx_data{received - 1}
            else
               robot.api.set_face_color(opposite_face, color[3])
            end
         end
      end
   end 
   
   if robot.id == "block1" then
      for i = 2, 5 do
         robot.radios[direction[i]].tx_data({1})
      end
   end
end


function destroy()
end
