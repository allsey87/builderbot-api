package.path = package.path .. ';Tools/?.lua'
package.path = package.path .. ';luabt/?.lua'
package.path = package.path .. ';AppNode/?.lua'
DebugMSG = require('DebugMessage')
--require("Debugger")

if api == nil then api = require('BuilderBotAPI') end
if app == nil then app = require('ApplicationNode') end
local bt = require('luabt')

DebugMSG.enable("nil")

-- ARGoS Loop ------------------------
function init()
   math.randomseed(os.time())
   -- robot init ---
   api.move_with_bearing(0.01, 0)
   robot.lift_system.set_position(0.02)
end

local STATE = 'prepare'

function step()
   DebugMSG('-------- step begins ---------')
   api.process()
   for i, ob in ipairs(api.obstacles) do
      api.debug_arrow("red", 
                      vector3(0,0,0),
                      ob.position)
   end
end

function reset()
end

function destroy()
end
