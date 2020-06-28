if robot.logger then
   robot.logger.register_module("nodes.move_to_location")
end

-- TODO check if we can remove first node of the tree below since it effectively just a function
-- please come up with better names for th, dis, th2: these names are almost cryptic
-- private functions for calculating th, dis, th2
local function calculate_th(location)
   local time = 0
   local run = function()
   return time, run
end

local function calculate_dis(location)
   local time = 0
   local run = function()
   return time, run
end

local function calculate_th2(location)
   local time = 0
   local run = function()
   return time, run
end

-- move to the location (position and orientation) blindly
--
--       \       x
--     th2\     |
--    <----P    |         forward
--          \   |
--       dis \th|
--            \ |
--             \|
--   y ---------------------
--              |\
--              | \       backup
--              |  \   |
--              |   \th|
--              | th2\ |
--              | <---\
return function(data, location)
   -- TODO does this data need to be persistent between runs? If so, how and when should it be reset?
   local th, dis, th2
   local turn_th_timer_parameter = {}
   local move_dis_timer_parameter = {}
   local turn_th2_timer_parameter = {}

   return {
      type = "sequence*",
      children = {
         -- calculate th, dis, th2
         function()
            -- th
            local backup_mode = false
            if location.position.x == 0 then
               if location.position.y < 0 then th = -90
               elseif location.position.y > 0 then th = 90 end
            else
               th = math.atan(location.position.y / location.position.x) * 180 / math.pi
               if location.position.x < 0 then
                  backup_mode = true
               end  
            end
            -- TODO make this message more descriptive
            robot.logger("th = ", th)
            local turnspeed = 3
            if th >= 0 then
               turn_th_timer_parameter.time = th / turnspeed
               turn_th_timer_parameter.func = function() robot.api.move.with_bearing(0, turnspeed) end
            else
               turn_th_timer_parameter.time = -th / turnspeed
               turn_th_timer_parameter.func = function() robot.api.move.with_bearing(0, -turnspeed) end
            end

            -- dis
            dis = math.sqrt(location.position.x ^ 2 + location.position.y ^ 2)
            move_dis_timer_parameter.time = dis / robot.api.parameters.default_speed
            if backup_mode == false then
               move_dis_timer_parameter.func = function() robot.api.move.with_bearing(robot.api.parameters.default_speed, 0) end
            else
               move_dis_timer_parameter.func = function() robot.api.move.with_bearing(-robot.api.parameters.default_speed, 0) end
            end
            --move_dis_timer_parameter.func = function() robot.api.move.with_velocity(robot.api.parameters.default_speed, robot.api.parameters.default_speed) end
            robot.logger("dis = ", dis)

            -- th2   -- assume orientation is always around z axis
            local angle, axis = location.orientation:toangleaxis()
            -- reverse orientation if axis is pointing down
            if (axis - vector3(0,0,-1)):length() < 0.1 then
               axis = -axis
               angle = 2 * math.pi - angle
            end
            robot.logger("angle = ", angle)
            angle = angle * 180 / math.pi  -- angle from 0 to 360
            robot.logger("angle = ", angle)
            th2 = angle - th               -- th2 from -90 to 360 + 90
            if th2 > 180 then th2 = th2 - 360 end
            local turnspeed = 3
            if th2 >= 0 then
               turn_th2_timer_parameter.time = th2 / turnspeed
               turn_th2_timer_parameter.func = function() robot.api.move.with_bearing(0, turnspeed) end
            else
               turn_th2_timer_parameter.time = -th2 / turnspeed
               turn_th2_timer_parameter.func = function() robot.api.move.with_bearing(0, -turnspeed) end
            end
            robot.logger("th2 = ", th2)

            robot.camera_system.disable()
            return false, true
         end,
         -- TODO is it necessary to repeatedly call xxx_timer_parameter.func via the timer node? Is once not sufficient?
         -- turn th
         function() robot.logger("turn th") return false, true end,
         robot.nodes.create_timer_node(turn_th_timer_parameter.time, turn_th_timer_parameter.func),
         --TODO: see above: robot.nodes.create_timer_node(calculate_th(distance)),
         -- move dis
         function() robot.logger("move dis") return false, true end,
         robot.nodes.create_timer_node(move_dis_timer_parameter.time, move_dis_timer_parameter.func),
         --TODO: see above: robot.nodes.create_timer_node(calculate_dis(distance)),
         -- turn th2
         function() robot.logger("turn th2") return false, true end,
         robot.nodes.create_timer_node(turn_th2_timer_parameter.time, turn_th2_timer_parameter.func),
         --TODO: see above: robot.nodes.create_timer_node(calculate_th2(distance)),
         -- stop moving
         function() 
            robot.api.move.with_velocity(0,0)
            -- TODO I am not convinced this is the right place to be enabling/disabling the camera...
            robot.camera_system.enable()
            return false, true 
         end,
      }, -- end of the children of go to pre-position
   } -- end of go to pre-position
end

