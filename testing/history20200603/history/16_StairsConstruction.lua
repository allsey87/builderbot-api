package.path = package.path .. ';Tools/?.lua'
package.path = package.path .. ';luabt/?.lua'
package.path = package.path .. ';AppNode/?.lua'
DebugMSG = require('DebugMessage')
--require("Debugger")

if api == nil then
   api = require('BuilderBotAPI')
end
if app == nil then
   app = require('ApplicationNode')
end
local bt = require('luabt')

-- DebugMSG.enable()
DebugMSG.disable()

-- pyramid rules ------------------------------------
-----------------------------------------------------

-- this is a dirty part, recommand to start reading from line 237

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
      DebugMSG('ckecking pick up rule')
      local flag = false
      local distance = 999999
      target.reference_id = nil
      target.offset = vector3(0, 0, 0)
      for i, block in pairs(api.blocks) do
         if block.tags[1].led == 4 then -- 4 means blue
            DebugMSG('found a blue block')
            if block.position_robot.x < distance then
               distance = block.position_robot.x
               target.reference_id = i
               flag = true
            end
         end
      end
      if flag == true then
         return false, true
      else
         return false, false
      end
   end
end

local function create_place_rule_node(target)
   -- returns a function/btnode choose a virtual block (a location to place a block)
   -- stores in target, if didn't find one, target.reference_id = nil
   -- first search a non-blue block, go nearer(use approach_block),
   -- move camera up and down to see what in that column,
   --    and set target reference and offset accordingly
   return {
      type = 'sequence*',
      children = {
         -- find nearest and then highest block not blue
         function()
            local flag = false
            local x_distance = 999999
            local z_distance = -999999

            target.reference_id = nil
            target.offset = nil
            for i, block in pairs(api.blocks) do
               if block.tags[1].led ~= 4 then -- 4 means blue
                  DebugMSG('found a non-blue block')
                  if block.position_robot.x + 0.02 < x_distance then
                     x_distance = block.position_robot.x
                     z_distance = block.position_robot.z
                     target.reference_id = i
                     flag = true
                  elseif block.position_robot.x < x_distance + 0.02 and block.position_robot.z > z_distance then
                     z_distance = block.position_robot.z
                     target.reference_id = i
                     flag = true
                  end
               end
            end
            if flag == true then
               return false, true
            else
               return false, false
            end
         end,
         -- approach it until 25cm
         {
            type = 'selector',
            children = {
               app.create_curved_approach_block_node(target, 0.25),
               function()
                  print('rule approach finidh')
                  return false, true
               end
            }
         },
         -- check what's in that column there
         {
            type = 'selector*',
            children = {
               -- move up to see the top
               {
                  type = 'sequence',
                  children = {
                     -- find nearest highest not blue block
                     -- see if it is already level 3, return false
                     -- see if column is full based on color, if full, return false
                     function()
                        -- nearest, highest, not blue
                        local flag = false
                        local x_distance = 999999
                        local z_distance = -999999
                        target.reference_id = nil
                        target.offset = nil
                        for i, block in pairs(api.blocks) do
                           if block.tags[1].led ~= 4 then -- 4 means blue
                              if block.position_robot.x + 0.02 < x_distance then
                                 x_distance = block.position_robot.x
                                 z_distance = block.position_robot.z
                                 target.reference_id = i
                                 flag = true
                              elseif block.position_robot.x < x_distance + 0.02 and block.position_robot.z > z_distance then
                                 z_distance = block.position_robot.z
                                 target.reference_id = i
                                 flag = true
                              end
                           end
                        end
                        local block = api.blocks[target.reference_id]

                        if block.position_robot.z < 0.055 * (block.tags[1].led - 1) then
                           DebugMSG('test1')
                           if block.tags[1].led == 1 then
                              robot.nfc.write('1')
                           elseif block.tags[1].led == 2 then
                              robot.nfc.write('2')
                           elseif block.tags[1].led == 3 then
                              robot.nfc.write('3')
                           end

                           return false, true
                        else
                           DebugMSG('test2')
                           if block.tags[1].led == 1 then
                              robot.nfc.write('1')
                           elseif block.tags[1].led == 2 then
                              robot.nfc.write('1')
                           elseif block.tags[1].led == 3 then
                              robot.nfc.write('2')
                           end

                           return false, false
                        end

                        --[[
                        if block.position_robot.z < 0.055 * 2 then
                           return false, true
                        else
                           return false, false
                        end
                        --]]
                     end,
                     -- check what's on top of it
                     {
                        type = 'selector',
                        children = {
                           -- if I can see the upper tag
                           function()
                              local block = api.blocks[target.reference_id]
                              local flag = false
                              for i, tag in ipairs(block.tags) do
                                 if
                                    (vector3(0, 0, 1):rotate(api.camera_orientation * tag.orientation) -
                                       vector3(0, 0, 1)):length() < 0.02
                                  then
                                    flag = true
                                    target.offset = vector3(0, 0, 1)
                                    break
                                 end
                              end
                              return false, flag
                           end,
                           -- otherwise, move up
                           function()
                              robot.lift_system.set_position(robot.lift_system.position + 0.05)
                              return true -- running
                           end
                        }
                     }
                  } -- end of children of move top
               }, -- end of move to top
               -- target is level 3, set offset (1, 0, -2)
               function()
                  local block = api.blocks[target.reference_id]
                  DebugMSG('AAA')
                  if block.tags[1].led == 3 then
                     target.offset = vector3(1, 0, -2)
                  elseif block.tags[1].led == 2 then
                     target.offset = vector3(1, 0, -1)
                  elseif block.tags[1].led == 1 then
                     target.offset = vector3(1, 0, 0)
                  end
                  DebugMSG('BBB')
                  return false, true
               end
               --[[
               -- move down to see bottom
               {
                  type = "selector",
                  children = {
                     -- find the nearest, lowest, not blue block
                     -- check whether it is level 1, true
                     function()
                        -- nearest, lowest, not blue
                        local flag = false
                        local distance = -999999
                        target.reference_id = nil
                        target.offset = nil
                        for i, block in pairs(api.blocks) do
                           if block.tags[1].led ~= 4 then -- 4 means blue
                              if block.position.y > distance then
                                 distance = block.position.y
                                 target.reference_id = i
                                 flag = true
                              end
                           end
                        end
                        local block = api.blocks[target.reference_id]
                        if block.position_robot.z < 0.055 then
                           target.offset = vector3(1,0,-1)
                           return false, true
                        else
                           return false, false
                        end
                     end,
                     -- move down
                     function()
                        robot.lift_system.set_position(robot.lift_system.position - 0.05)
                        return true -- running
                     end,
                  },
               },
               --]]
            } -- end of children of check column
         } -- end of check column
      }
   }
end
-- end of pyramid rules -----------------------------
-----------------------------------------------------

-- ARGoS Loop ------------------------
function init()
   local BTDATA = {target = {}}
   -- bt init ---
   local bt_node = {
      type = 'sequence*',
      children = {
         -- pickup
         -- search block
         app.create_search_block_node(app.create_process_rules_node('pickup', BTDATA.target)),
         -- approach_block
         app.create_curved_approach_block_node(BTDATA.target, 0.18),
         -- pickup block
         app.create_pickup_block_node(BTDATA.target, 0.03),
         -- place
         -- search block
         app.create_search_block_node(app.create_process_rules_node('place', BTDATA.target)),
         -- approach_block
         app.create_curved_approach_block_node(BTDATA.target, 0.18),
         -- drop
         app.create_place_block_node(BTDATA.target, 0.03),
         -- backup
         -- backup 8 cm
         app.create_timer_node(
            {
               time = 0.08 / 0.005,
               func = function()
                  api.move(-0.005, -0.005)
               end
            }
         )
         -- stop
         --function() api.move(0,0) return true end,
      }
   }
   behaviour = bt.create(bt_node)
   -- robot init ---
   robot.camera_system.enable()
end

local STATE = 'prepare'
function visualize_target()
   function draw_block_axes(block_position, block_orientation, color)
      local z = vector3(0, 0, 1)
      api.debug_arrow(color, block_position, block_position + 0.1 * vector3(z):rotate(block_orientation))
   end
   if BTDATA.target ~= nil then
      target_block = nil
      for i, block in pairs(api.blocks) do
         if block.id == BTDATA.target.reference_id then
            print('Visualizing target')

            target_block = block
            offsetted_block_in_reference_block_pos = 0.05 * BTDATA.target.offset
            offsetted_block_in_robot_pos =
               offsetted_block_in_reference_block_pos:rotate(target_block.orientation_robot) +
               target_block.position_robot
            offsetted_block_in_robot_ori = target_block.orientation_robot
            draw_block_axes(offsetted_block_in_robot_pos, offsetted_block_in_robot_ori, 'blue')
            draw_block_axes(target_block.position_robot, target_block.orientation_robot, 'red')
            break
         end
      end
   end
end

function step()
   DebugMSG('-------- step begins ---------')
   api.process_time()
   api.process()
   behaviour()
   -- visualize_target()
end

function reset()
end

function destroy()
end
