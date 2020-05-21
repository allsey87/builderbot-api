package.path = package.path .. ';Tools/?.lua'
package.path = package.path .. ';luabt/?.lua'
package.path = package.path .. ';AppNode/?.lua'
DebugMSG = require('DebugMessage')
-- require('Debugger')

if api == nil then
   api = require('BuilderBotAPI')
end
if app == nil then
   app = require('ApplicationNode')
end
local bt = require('luabt')

DebugMSG.enable()

-- ARGoS Loop ------------------------
function init()
   local BTDATA = {target = {}}
   -- bt init ---
   local bt_node = {
      type = 'sequence*',
      children = {
         {
            type = 'sequence*',
            children = {
               -- prepare, lift to 0.13
               {
                  type = 'selector',
                  children = {
                     -- if lift reach position(0.13), return true, stop selector
                     function()
                        if
                           robot.lift_system.position > 0.13 - api.parameters.lift_system_position_tolerance and
                              robot.lift_system.position < 0.13 + api.parameters.lift_system_position_tolerance
                         then
                           DebugMSG('lift_in position')
                           return false, true
                        else
                           DebugMSG('lift_not in position')
                           return false, false
                        end
                     end,
                     -- set position(0.13)
                     function()
                        robot.lift_system.set_position(0.13)
                        return true -- always running
                     end
                  }
               }
            }
         },
         {
            type = 'sequence',
            children = {
               -- if obstacle and avoid
               app.create_obstacle_avoidance_node(),
               -- obstacle clear, random walk
               app.create_random_walk_node()
            }
         }
      }
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
