if robot.logger then
   robot.logger.register_module("nodes.pick_up_behavior")
end

return function(data, rules)
   return 
   { type = "selector*", children = {
      -- Am I holding a block, if yes, return true for the whole node and move on
      --                       if not, do search-approach-pickup
      function()
         if robot.rangefinders['underneath'].proximity < robot.api.parameters.proximity_touch_tolerance then
            return false, true
         else
            return false, false
         end
      end,
      -- pickup
      { type = "sequence*", children = {
         robot.nodes.create_search_block_node(data, 
            robot.nodes.create_process_rules_node(data, rules, "pickup")
         ),
         robot.nodes.create_curved_approach_block_node(data, 0.20),
         robot.nodes.create_pick_up_block_node(data, 0.20),
         function() robot.logger("INFO", "pickup_behavior finish") return false, true end
      }}
   }}
end