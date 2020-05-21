return {
   --[[ initialize constants ]]--
   constants = {
      block_side_length = 0.055,
      -- TODO move into the SRoCS API
      lift_system_upper_limit = 0.135,
      lift_system_lower_limit = 0,
      end_effector_position_offset = vector3(0.09800875, 0, 0.055),
      -- TODO make these parameters
      lift_system_rf_cover_threshold = 0.06,
      lift_system_position_tolerance = 0.001,
   }
   --[[ initialize parameters ]]--
   parameters = {
      default_speed =
         tonumber(robot.params.default_speed or 0.005),
      search_random_range =
         tonumber(robot.params.search_random_range or 25),
      aim_block_angle_tolerance =
         tonumber(robot.params.aim_block_angle_tolerance or 0.5),
      block_position_tolerance =
         tonumber(robot.params.block_position_tolerance or 0.001),
      proximity_touch_tolerance =
         tonumber(robot.params.proximity_touch_tolerance or 0.003),
      proximity_detect_tolerance =
         tonumber(robot.params.proximity_detect_tolerance or 0.03),
      proximity_maximum_distance =
         tonumber(robot.params.proximity_maximum_distance or 0.05),
   }
   --[[ initialize submodules ]]--
   match_rules =
      require('api.match_rules'),
   move =
      require('api.move'),
   process_blocks =
      require('api.process_blocks'),
   process_leds =
      require('api.process_leds'),
   process_obstacles =
      require('api.process_obstacles'),
   track_blocks =
      require('api.track_blocks'),
}
