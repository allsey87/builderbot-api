package.path = package.path .. ";builderbot/?.lua"

function init()
   --[[ load modules ]]--
   -- TODO add verbosity control to logger
   -- TODO logger always prints "MODULE_NAME: MESSAGE"
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
   local hungarian = robot.utils.hungarian.create{
      costMat = {
         {1, 1, 2},
         {1, 2, 2},
         {2, 2, 1},
      },
      MAXorMIN = "MIN",
   }

   hungarian:aug()
   robot.logger("INFO", hungarian)
end

function reset()
end

function destroy()
   -- disable the robot's camera
end
