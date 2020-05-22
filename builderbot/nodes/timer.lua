if robot.logger then
   robot.logger.register_module("nodes.timer")
end

return function(data, time, method)
   -- para = {time, func}
   -- count from 0, to para.time, with increment of api.time_period
   -- each step do para.func()
   -- need to do api.process_time everytime
   local current
   return {
      type = "sequence*",
      children = {
         function()
            current = 0
            return false, true
         end,
         function()
            -- TODO can we not use robot.system.clock to do this more reliably??
            current = current + robot.api.constants.time_period
            if current > time then
               return false, true
            else
               if type(method) == "function" then
                  method()
               end
               return true
            end
         end,
      },
   }
end