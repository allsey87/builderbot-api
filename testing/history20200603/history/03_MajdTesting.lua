package.path = package.path .. ';Tools/?.lua'
package.path = package.path .. ';luabt/?.lua'
package.path = package.path .. ';AppNode/?.lua'
require('ShowTable')
local pprint = require('pprint')

--require("Debugger")

api = require('BuilderBotAPI')
app = require('ApplicationNode') -- these need to be global
local bt = require('luabt')

-- ARGoS Loop ------------------------
function init()
   -- bt init ---
   BTDATA = {}
   behaviour =
      bt.create {
      type = 'sequence*',
      children = {
         -- search block
         app.search_block,
         -- approach_block
         app.approach_block,
         -- pickup block
         app.pickup_block
      }
   }
   -- robot init ---
   robot.camera_system.enable()
end

local STATE = 'prepare'

function step()
   print('-------- step begins ---------')
   api.process_blocks()
   behaviour()
end

function reset()
end

function destroy()
end



