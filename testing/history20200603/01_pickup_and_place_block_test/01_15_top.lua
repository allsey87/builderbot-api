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
         app.create_pickup_block_node(BTDATA.target, 0.15),

         function() 
            BTDATA.target.offset = vector3(0,0,1) 
            BTDATA.target.color = "pink"
            return false, true 
         end,

         app.create_place_block_node(BTDATA.target, 0.15 + api.consts.end_effector_position_offset.x),
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
