package.path = package.path .. ';Tools/?.lua'
package.path = package.path .. ';luabt/?.lua'
package.path = package.path .. ';AppNode/?.lua'
DebugMSG = require('DebugMessage')
--require("Debugger")

if api == nil then api = require('BuilderBotAPI') end
if app == nil then app = require('ApplicationNode') end
local bt = require('luabt')

DebugMSG.enable()

-- ARGoS Loop ------------------------
function init()
   local BTDATA = {target = {reference_id = 1, offset = vector3(0,0,0), color = "green"},}
   -- bt init ---
   local bt_node = {
      type = 'sequence*',
      children = {
         function()
            robot.lift_system.set_position(0.07)
            if robot.lift_system.position > 0.07 - api.parameters.lift_system_position_tolerance and
               robot.lift_system.position < 0.07 + api.parameters.lift_system_position_tolerance
               then
               return false, true
            else
               return false, false
            end
         end,

         app.create_Z_shape_approach_block_node(BTDATA.target, 0.22),
         app.create_timer_node{time = 0.3,}, -- wait for the next tick for the camera to see
         app.create_curved_approach_block_node(BTDATA.target, 0.18),
         app.create_pickup_block_node(BTDATA.target, 0.18),

         -- stop
         function() api.move(0,0) return true end,
      },
   }
   behaviour = bt.create(bt_node)
   -- robot init ---
   robot.camera_system.enable()
end

local STATE = 'prepare'

function step()
   DebugMSG('-------- step begins ---------')
   api.process()
   behaviour()
end

function reset()
end

function destroy()
end
