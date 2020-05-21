package.path = package.path .. ';Tools/?.lua'
package.path = package.path .. ';luabt/?.lua'
package.path = package.path .. ';AppNode/?.lua'
DebugMSG = require('DebugMessage')
require("Debugger")

if api == nil then api = require('BuilderBotAPI') end
if app == nil then app = require('ApplicationNode') end
local bt = require('luabt')

DebugMSG.enable("nil")
DebugMSG.enable("move_to_location")
DebugMSG.enable("blind_approach_block")

local function create_pickup_rule_node(target)
   -- returns a function/btnode that 
   --    chooses a block from api.blocks
   -- stores in target, if didn't find one, target.reference_id = nil
   --    target = {
   --       reference_id = index of a block in api.blocks
   --       offset = vector3(0,0,0), for the block itself
   --                vector3(1,0,0), for front of this block
   --    }
   -- note that target already points to an existing table, 
   --    never do target = {}, then you lost the existing table
   
   return function()
      -- find nearest blue block
      DebugMSG("ckecking pick up rule")
      local flag = false
      local distance = 999999
      target.reference_id = nil
      target.offset = vector3(0,0,0)
      for i, block in pairs(api.blocks) do
         if block.tags[1].led == 4 then -- 4 means blue
            DebugMSG("found a blue block")
            if block.position_robot.x < distance then
               distance = block.position_robot.x
               target.reference_id = i
               flag = true
            end
         end
      end
      if flag == true then return false, true
                      else return false, false end
   end
end

-- ARGoS Loop ------------------------
function init()
   local BTDATA = {target = {},}
   -- bt init ---
   local bt_node = {
      type = 'sequence*',
      children = {
         app.create_search_block_node(create_pickup_rule_node(BTDATA.target)),
         -- the following approach both works
         --app.create_curved_approach_block_node(BTDATA.target, 0.22),
         app.create_Z_shape_approach_block_node(BTDATA.target, 0.22),

         app.create_timer_node{time = 360 / 5, func = function() api.move_with_bearing(0, 5) end,},

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
