package.path = package.path .. ";builderbot/?.lua"

function init()
   --[[ load modules ]]--
   robot.logger = require('logger')
   robot.utils = require('utils')
   robot.api = require('api')
   robot.nodes = require('nodes')

   robot.logger.enable()
   robot.logger.set_level("INFO")
   
   --[[ initialize shared data ]]--
   data = {
      blocks = {}
   }
end

function step()
   robot.logger("INFO", '[reset: clock = ]')
   -- TODO: there seems to be a flaw in hungarian
   local hungarian = robot.utils.hungarian.create(
      {
         {0.206, 0.151, 0.1},
         {0.103, 0.158, 0.1},
         {0.151, 0.103, 0.1},
      },
      false
   )

   hungarian:aug()
   robot.logger("INFO", "hungarian1")
   robot.logger("INFO", hungarian)
end

function reset()
end

function destroy()
   -- disable the robot's camera
end
