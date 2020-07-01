function init()
   if robot.id == "block1" or robot.id == "block2" then
      robot.directional_leds.set_all_colors("magenta")
   end
end

function step()
   for identifer, radio in pairs(robot.radios) do
      if #radio.rx_data > 0 then        
         configuration = string.char(radio.rx_data[1][1])
         -- debug
         print("received " .. configuration .. " on " .. identifer)
         -- debug
         if configuration == "0" then
            robot.directional_leds.set_all_colors("black")
         elseif configuration == "1" then
            robot.directional_leds.set_all_colors("magenta")
         elseif configuration == "2" then
            robot.directional_leds.set_all_colors("orange")
         elseif configuration == "3" then
            robot.directional_leds.set_all_colors("green")
         elseif configuration == "4" then
            robot.directional_leds.set_all_colors("blue")
         end
      end
   end 
end

function reset()
end

function destroy()
end
