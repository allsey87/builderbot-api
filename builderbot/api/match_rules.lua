if robot.logger then
   robot.logger.register_module("api.match_rules")
end

function check_block_in_safe_zone(block)
   -- we use block in camera eye provided by blocktrackig (Probably would have to do the conversion here in the future)
   -- TODO local?
   x = block.position.x
   y = block.position.y
   z = block.position.z
   -- TODO Define camera parameters (probably this is already provided by michael or maybe ask for it)
   horizontal_fov = 0.60 -- 60 degrees
   vertical_fov = 0.55 -- 60 degrees
   maimum_visible_distance = 1
   c = 0.05
   y_limit = math.tan(vertical_fov / 2) * z - c
   x_limit = math.tan(horizontal_fov / 2) * z - c
   z_limit = maimum_visible_distance - c

   camera_position_in_end_effector = robot.camera_system.transform.position
   camera_position_in_robot =
   -- TODO api constance
      camera_position_in_end_effector + vector3(0.0980875, 0, robot.lift_system.position + 0.055)
   camera_orientation_in_robot = robot.camera_system.transform.orientation
   -- Visualize safe zone
   y_limit_for_max_z = math.tan(vertical_fov / 2) * z_limit - c
   x_limit_for_max_z = math.tan(horizontal_fov / 2) * z_limit - c

   staring_point =
      vector3(0, 0, c / math.tan(vertical_fov / 2)):rotate(camera_orientation_in_robot) +
      vector3(camera_position_in_robot)
      robot.utils.debug_arrow(
      'green',
      vector3(staring_point),
      vector3(x_limit_for_max_z, y_limit_for_max_z, z_limit):rotate(camera_orientation_in_robot) +
         vector3(camera_position_in_robot)
   )
   robot.utils.debug_arrow(
      'green',
      vector3(staring_point),
      vector3(-1 * x_limit_for_max_z, y_limit_for_max_z, z_limit):rotate(camera_orientation_in_robot) +
         vector3(camera_position_in_robot)
   )

   robot.utils.debug_arrow(
      'green',
      vector3(staring_point),
      vector3(x_limit_for_max_z, -1 * y_limit_for_max_z, z_limit):rotate(camera_orientation_in_robot) +
         vector3(camera_position_in_robot)
   )

   robot.utils.debug_arrow(
      'green',
      vector3(staring_point),
      vector3(-1 * x_limit_for_max_z, -1 * y_limit_for_max_z, z_limit):rotate(camera_orientation_in_robot) +
         vector3(camera_position_in_robot)
   )

   if block.position_robot.z > 0.12 then -- the block could not be higher
      if z < z_limit and y < y_limit and x < x_limit and x > -1 * x_limit then
         -- print('block:', block.id, 'is safe')
         return true
      else
         -- print('block:', block.id, 'is not safe')
         return false
      end
   else
      if z < z_limit and y < y_limit and y > -1 * y_limit and x < x_limit and x > -1 * x_limit then
         -- print('block:', block.id, 'is safe')
         return true
      else
         -- print('block:', block.id, 'is not safe')
         return false
      end
   end
end

local function round_by_digits(num, numDecimalPlaces)
   local mult = 10 ^ (numDecimalPlaces or 0)
   return math.floor(num * mult + 0.5) / mult
end

-- generate structure in indices frame from a visual structure or a rule
local function generate_uniform_structure(structure, view_point)
   -- view point is the position and orientation relative to structure[1]
   view_point = view_point or {}
   view_point.position = view_point.position or vector3()
   view_point.orientation = view_point.orientation or quaternion()

   -- calculate relative position, camera in viewpoint
   local block1_in_camera = {
      position = structure[1].position_robot or structure[1].index,
      orientation = structure[1].orientation_robot or quaternion(),
   }
   local viewpoint_in_camera = {
      position = block1_in_camera.position + 
                 vector3(view_point.position):rotate(block1_in_camera.orientation),
      orientation = view_point.orientation * block1_in_camera.orientation,
   }

   local camera_in_viewpoint = {
      position = vector3(-viewpoint_in_camera.position):rotate(
                    viewpoint_in_camera.orientation:inverse()
                 ),
      orientation = viewpoint_in_camera.orientation:inverse(),
   }

   local side_length = robot.api.constants.block_side_length
   if structure[1].position_robot == nil then side_length = 1 end

   -- rotate and uniform every block in the structure
   local uniform_structure = {}
   for i, block in ipairs(structure) do
      local block_in_camera = {
         position = block.position_robot or block.index,
         orientation = block.orientation_robot or quaternion(),
      }
      local uniform_block = {
         index = camera_in_viewpoint.position +
                 vector3(block_in_camera.position):rotate(camera_in_viewpoint.orientation)
      }

      uniform_block.index = uniform_block.index * (1/side_length)
      uniform_block.index.x = round_by_digits(uniform_block.index.x, 0)
      uniform_block.index.y = round_by_digits(uniform_block.index.y, 0)
      uniform_block.index.z = round_by_digits(uniform_block.index.z, 0)

      table.insert(uniform_structure, uniform_block)
   end

   -- offset indices based on the lowest x,y,z
   local lowest_x = math.huge
   local lowest_y = math.huge
   local lowest_z = math.huge
   for i, indexed_block in ipairs(uniform_structure) do
      -- Getting lowest x,y,z (should be seperated along with transform indexed blocks to unified origin)
      if indexed_block.index.x < lowest_x then
         lowest_x = indexed_block.index.x
      end
      if indexed_block.index.y < lowest_y then
         lowest_y = indexed_block.index.y
      end
      if indexed_block.index.z < lowest_z then
         lowest_z = indexed_block.index.z
      end
   end
   local origin = vector3(lowest_x, lowest_y, lowest_z)
   -- tranform indexed blocks to unified origin
   for i, block in pairs(uniform_structure) do
      block.index = block.index - origin
   end

   return uniform_structure, origin
end

local function generate_aligned_visual_structures(structures)
   local structures_in_index_frame = {}
   for i, group in ipairs(structures) do
      local new_group = generate_uniform_structure(group)
      table.insert(structures_in_index_frame, new_group)
   end
   return structures_in_index_frame
end

local function generate_new_rule_by_rotating_90(rule)
   local new_rule = robot.utils.shallow_copy(rule)
   -- note that shallow_copy doesn't work for vector3 and quaternions, so generate new structure 
   -- and new target based on the old rule.
   local origin
   new_rule.structure, origin = generate_uniform_structure(rule.structure, 
                           {orientation = quaternion(-math.pi/2, vector3(0,0,1))}
                        )
   new_rule.target.reference_index = 
      vector3(rule.target.reference_index - rule.structure[1].index):rotate(quaternion(math.pi/2, vector3(0,0,1))) - origin
   new_rule.target.offset_from_reference = 
      vector3(rule.target.offset_from_reference):rotate(quaternion(math.pi/2, vector3(0,0,1)))
   return new_rule
end

local function generate_aligned_and_rotated_rules_structures(rules_list)
   local aligned_and_rotated_rules_list = {}
   for i, rule in ipairs(rules_list) do
      local new_rule = rule
      table.insert(aligned_and_rotated_rules_list, new_rule)
      new_rule = generate_new_rule_by_rotating_90(new_rule)
      table.insert(aligned_and_rotated_rules_list, new_rule)
      new_rule = generate_new_rule_by_rotating_90(new_rule)
      table.insert(aligned_and_rotated_rules_list, new_rule)
      new_rule = generate_new_rule_by_rotating_90(new_rule)
      table.insert(aligned_and_rotated_rules_list, new_rule)
   end
   return aligned_and_rotated_rules_list
end

local function match_structures(visible_structure, rule_structure)
   function tablelength(T)
      local count = 0
      for _ in pairs(T) do
         count = count + 1
      end
      return count
   end

   local structure_matching_result = true
   if tablelength(visible_structure) ~= #rule_structure then
      structure_matching_result = false
   else
      for j, rule_block in pairs(rule_structure) do
         local block_matched = false
         for k, visible_block in pairs(visible_structure) do
            if visible_block.index == rule_block.index then --found required index
               if (visible_block.type == rule_block.type) or (rule_block.type == 'X') then -- found the same required type
                  block_matched = true
                  break
               end
            end
         end
         if block_matched == false then
            structure_matching_result = false
            break
         end
      end
   end
   return structure_matching_result
end
local function get_reference_id_from_index(reference_index, visible_structure)
   for j, block in pairs(visible_structure) do
      if block.index == reference_index then
         return j
      end
   end
end

return function(blocks, rules, rule_type, final_target)
   final_target.reference_id = nil
   final_target.offset = vector3(0, 0, 0)

   local structures = {}
   robot.api.process_structures(structures, blocks)
   if #structures == 0 then
      return false
   end

   -- align visual structures
   local structures_in_index_frame = generate_aligned_visual_structures(structures)

   -- align rule structures
   if rules.aligned == nil then 
      rules.list = generate_aligned_and_rotated_rules_structures(rules.list) 
      rules.aligned = true
   end

   robot.logger("INFO","rules")
   robot.logger("INFO",rules)
end

--[[
local create_process_rules_node = function(blocks, rules, rule_type, final_target)

   return function()
      -- TODO; this should happen only once in each step
     

      -- pprint.pprint(structure_list)
      ---------------------------------------------------------------------------------------
      --Match current structures against rules
      final_target.reference_id = nil
      final_target.offset = nil
      targets_list = {}

      function one_block_safe(indexed_structure)
         result = false
         structure = {}
         for bi, indexed_block in pairs(indexed_structure) do
            for b, block in pairs(api.blocks) do
               if tonumber(get_reference_id_from_index(indexed_block.index, indexed_structure)) == tonumber(block.id) then
                  table.insert(structure, block)
               end
            end
         end
         for bi, block in pairs(structure) do
            if check_block_in_safe_zone(block) == true then
               result = true
               break
            end
         end
         return result
      end
      function target_block_safe(indexed_structure, rule_reference_index)
         result = false
         target_block = nil
         target_block_reference_id = get_reference_id_from_index(rule_reference_index, indexed_structure)
         for b, block in pairs(api.blocks) do
            if tonumber(target_block_reference_id) == tonumber(block.id) then
               target_block = block
            end
         end
         if target_block == nil then
            result = false -- target block is not in the structure
            return result
         end
         if check_block_in_safe_zone(target_block) == true then
            result = true
         end

         return result
      end

      ----------------------------------------------------------------------------
      ------------------ matching rules and getting safe targets ------------------
      -- pprint.pprint(structure_list)
      for i, rule in pairs(rules.list) do
         if rule.rule_type == rule_type then
            match_result = false
            for j, visible_structure in pairs(structure_list) do
               if target_block_safe(visible_structure, rule.target.reference_index) == true then
                  res = match_structures(visible_structure, rule.structure)
                  if res == true then
                     match_result = true
                     possible_target = {}
                     possible_target.reference_id =
                        get_reference_id_from_index(rule.target.reference_index, visible_structure)
                     possible_target.offset = rule.target.offset_from_reference
                     possible_target.type = rule.target.type
                     possible_target.safe = true
                     table.insert(targets_list, possible_target)
                  end
               end
            end
         end
      end

      -- TODO if unused this code should be removed
      -----------------------------------------------------------------------------
      ------------------- match rules and getting unsafe targets ------------------
      -- we get unsafe targets only if we could not find safe targets
      -- if #targets_list == 0 then
      --    for i, rule in pairs(rules.list) do
      --       if rule.rule_type == rule_type then
      --          match_result = false
      --          for j, visible_structure in pairs(structure_list) do
      --             if one_block_safe(visible_structure) == false then
      --                res = match_structures(visible_structure, rule.structure)
      --                if res == true then
      --                   match_result = true
      --                   possible_target = {}
      --                   possible_target.reference_id =
      --                      get_reference_id_from_index(rule.target.reference_index, visible_structure)
      --                   possible_target.offset = rule.target.offset_from_reference
      --                   possible_target.type = rule.target.type
      --                   possible_target.safe = false
      --                   table.insert(targets_list, possible_target)
      --                end
      --             end
      --          end
      --       end
      --    end
      -- end
      --------------------------------------------------------------
      --------------------- Target selection methods ---------------
      if rules.selection_method == 'nearest_win' then
         -----choose the nearest target from the list -------
         -- see math.huge
         minimum_distance = 9999999
         for i, possible_target in pairs(targets_list) do
            for j, block in pairs(api.blocks) do
               if tostring(block.id) == possible_target.reference_id then
                  distance_from_target = math.sqrt((block.position_robot.x) ^ 2 + (block.position_robot.y) ^ 2)
                  if distance_from_target < minimum_distance then
                     minimum_distance = distance_from_target
                     final_target.reference_id = tonumber(possible_target.reference_id)
                     final_target.offset = possible_target.offset
                     final_target.type = possible_target.type
                     final_target.safe = possible_target.safe
                  end
               end
            end
         end
      elseif rules.selection_method == 'furthest_win' then
         -----choose the furthest target from the list -------
         maximum_distance = 0
         for i, possible_target in pairs(targets_list) do
            for j, block in pairs(api.blocks) do
               if tostring(block.id) == possible_target.reference_id then
                  distance_from_target = math.sqrt((block.position_robot.x) ^ 2 + (block.position_robot.y) ^ 2)
                  if distance_from_target > maximum_distance then
                     maximum_distance = distance_from_target
                     final_target.reference_id = tonumber(possible_target.reference_id)
                     final_target.offset = possible_target.offset
                     final_target.type = possible_target.type
                     final_target.safe = possible_target.safe
                  end
               end
            end
         end
      else
         -- TODO this should be an error that ends the program
         print('no selection method')
      end
      ------- Visualizing the results ----------
      target_block = nil
      for i, block in pairs(api.blocks) do
         if block.id == final_target.reference_id then
            target_block = block
            offsetted_block_in_reference_block_pos = 0.05 * final_target.offset
            offsetted_block_in_robot_pos =
               offsetted_block_in_reference_block_pos:rotate(target_block.orientation_robot) +
               target_block.position_robot
            offsetted_block_in_robot_ori = target_block.orientation_robot
            robot.utils.draw.block_axes(offsetted_block_in_robot_pos, offsetted_block_in_robot_ori, 'blue')
            robot.utils.draw.block_axes(target_block.position_robot, target_block.orientation_robot, 'red')
            break
         end
      end
      robot.logger('final target:', final_target)
      if #targets_list > 0 then
         return false, true
      else
         return false, false
      end
   end
end
return create_process_rules_node
--]]