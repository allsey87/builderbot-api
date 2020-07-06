return {
   --[[ initialize constants ]]--
   constants = {
      time_period = 0.2, --TODO : measure
      block_side_length = 0.055,
      -- from x+, counter-closewise
      block_led_offset_from_tag = {
         vector3(0.02,  0,    0),
         vector3(0,     0.02, 0),
         vector3(-0.02, 0,    0),
         vector3(0,    -0.02, 0)
      },
      -- TODO move into the SRoCS API
      lift_system_upper_limit = 0.135,
      lift_system_lower_limit = 0,
      end_effector_position_offset = vector3(0.09800875, 0, 0.055),
      end_effector_nose_length = 0.005,
   },
   --[[ initialize parameters ]]--
   parameters = {
      default_speed =
         tonumber(robot.params.default_speed or 0.005),
      default_turn_speed = -- in degree
         tonumber(robot.params.default_turn_speed or 5),
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
      lift_system_rf_cover_threshold =
         tonumber(robot.params.lift_system_rf_cover_threshold or 0.06),
      lift_system_position_tolerance =
         tonumber(robot.params.lift_system_position_tolerance or 0.001),
      obstacle_avoidance_backup=
         tonumber(robot.params.obstacle_avoidance_backup or 0.08),
      obstacle_avoidance_turn =
         tonumber(robot.params.obstacle_avoidance_turn or 60),
   },
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
   process_structures =
      require('api.process_structures'),
   track_blocks =
      require('api.track_blocks'),
}
