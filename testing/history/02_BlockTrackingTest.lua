package.path = package.path .. ";Tools/?.lua"
package.path = package.path .. ";luabt/?.lua"
package.path = package.path .. ";AppNode/?.lua"
DebugMSG = require('DebugMessage')
--require("Debugger")

--robot.xxx is provided by argos
api = require("BuilderBotAPI")
app = require("ApplicationNode")

DebugMSG.enable()

-- ARGoS Loop ------------------------
function init()
   -- robot test ---
   api.move(0.01, 0.01)
   robot.camera_system.enable()
end

function step()
   DebugMSG("-------- step begins ---------")
   --- get time test ----
   DebugMSG("-- get time test --")
   api.process()
   DebugMSG("time period = ", api.time_period)


   --- camera test ----
   DebugMSG("-- camera test --")
   api.process_blocks()

   DebugMSG("blocks")
   DebugMSG(api.blocks, 1)


   -- test tag location
   for i, tag_for_camera in pairs(robot.camera_system.tags) do
      api.debug_arrow("red", 
                      api.camera_position, 
                      vector3(tag_for_camera.position):rotate(api.camera_orientation) + 
                           api.camera_position) 
   end

   -- test block location and orientation
   local x = vector3(1,0,0)
   local y = vector3(0,1,0)
   local z = vector3(0,0,1)
   for i, block in pairs(api.blocks) do
      api.debug_arrow("red", 
                      block.position_robot, 
                      block.position_robot + 0.1*vector3(x):rotate(block.orientation_robot)) 
      api.debug_arrow("blue", 
                      block.position_robot, 
                      block.position_robot + 0.1*vector3(y):rotate(block.orientation_robot)) 
      api.debug_arrow("green", 
                      block.position_robot, 
                      block.position_robot + 0.1*vector3(z):rotate(block.orientation_robot)) 
   end
end

function reset()
end

function destroy()
end
