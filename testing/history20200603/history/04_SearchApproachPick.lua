package.path = package.path .. ';Tools/?.lua'
package.path = package.path .. ';luabt/?.lua'
package.path = package.path .. ';AppNode/?.lua'
require('ShowTable')
local pprint = require('pprint')

--require("Debugger")

api = require('BuilderBotAPI')
app = require('ApplicationNode') -- these need to be global
local bt = require('luabt')

-- rules
local function create_pickup_rule_node(target)
   -- returns a function/btnode that 
   --    chooses a block to pick up
   --    from api.blocks
   -- stores in target, if didn't find one, target = nil
   --    target = {
   --       reference_id = index of a block in api.blocks
   --       offset = vector3(0,0,0), not 0 for virtual block
   --    }
   return function()
      print("I am here")
      local flag = false
      target.reference_id = nil
      for i, block in pairs(api.blocks) do
         if block.tags[1].led == 4 then -- 4 means blue
            print("I am also here")
            target.reference_id = i
            target.offset = vector3(0,0,0)
            flag = true
            break
         end
      end
      if flag == true then return false, true
                      else return false, false end
   end
end

local function create_place_rule_node(target)
   -- returns a function/btnode choose a place virtual block
   -- stores in target, if didn't find one, target = nil
   return function()
      local flag = false
      target.reference_id = nil
      for i, block in pairs(api.blocks) do
         if block.tags[1].led ~= 4 then -- 4 means blue
            target.reference_id = i
            target.offset = vector3(0,0,1)
            flag = true
            break
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
       -- pickup
         -- search block
         app.create_search_block_node(create_pickup_rule_node(BTDATA.target)),
         -- approach_block
         app.create_approach_block_node(BTDATA.target),
         -- pickup block
         app.pickup_block,
       -- place
         -- search block
         app.create_search_block_node(create_place_rule_node(BTDATA.target)),
         -- approach_block
         app.create_approach_block_node(BTDATA.target),
         -- drop
         function()
            robot.electromagnet_system.set_discharge_mode("destructive")
         end,
         -- backup 2 cm
         app.create_timer_node({time = 0.02 / 0.005, func = function() api.move(-0.005, -0.005) end}),
         -- stop
         function() api.move(0,0) return true end,
      },
   }

   ShowTable(bt_node)
   behaviour = bt.create(bt_node)
   -- robot init ---
   robot.camera_system.enable()
end

local STATE = 'prepare'

function step()
   print('-------- step begins ---------')
   api.process_time()
   api.process_blocks()
   behaviour()
end

function reset()
end

function destroy()
end
