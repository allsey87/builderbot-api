local logger = {}
logger.mt = {}
setmetatable(logger, logger.mt)

-- call logger(...)
function logger.mt:__call(level_str, a, ...)
   -- get module name
	local info = debug.getinfo(2)
   local src = info.short_src
   local moduleName = logger.modules[src]
   if moduleName == nil then moduleName = "nil" end
   -- get level 
   local level = 0
   if level_str == "ERR" then level = 0
   elseif level_str == "WARN" then level = 1
   elseif level_str == "INFO" then level = 2
   else logger("WARN", modulename, "logger level is not specified correctly")
   end

   -- print info
   if logger.switches[moduleName] == true and
      level <= logger.verbosity_level then
      --print("logger:\t" .. moduleName .. ":" .. info.currentline .. "\t", ...)
      if type(a) == "table" then
         logger.show_table(a, ...)
      else
         print("logger:\t", a, ...)
      end
   end
end

function logger.set_level(level_str)
   logger.verbosity_level = 0
   if level_str == "ERR" then 
      logger.verbosity_level = 0
   elseif level_str == "WARN" then 
      logger.verbosity_level = 1
   elseif level_str == "INFO" then 
      logger.verbosity_level = 2
   else 
      logger("ERR", "logger level is not set correctly")
   end
end

logger.verbosity_level = 0 -- 0 is ERR
logger.modules = {}
logger.switches = {}
logger.switches["nil"] = false

function logger.register_module(moduleName)
	local info = debug.getinfo(2)
   local src = info.short_src
   logger.modules[src] = moduleName
   logger.switches[moduleName] = false
end

function logger.disable(moduleName)
   if moduleName == nil then
      for i, v in pairs(logger.switches) do
         logger.switches[i] = false
         logger.switches["nil"] = false
      end
   else
      logger.switches[moduleName] = false
   end
end

function logger.enable(moduleName)
   if moduleName == nil then
      for i, v in pairs(logger.switches) do
         logger.switches[i] = true
         logger.switches["nil"] = true
      end
   else
      logger.switches[moduleName] = true
   end
end

function logger.show_table(table, number, skipindex)
   -- number means how many indents when printing
   if number == nil then number = 0 end
   if type(table) ~= "table" then return nil end

   for i, v in pairs(table) do
      local str = "logger:\t\t"
      for j = 1, number do
         str = str .. "\t"
      end

      str = str .. tostring(i) .. "\t"

      if i == skipindex then
         print(str .. "SKIPPED")
      else
         if type(v) == "table" then
            print(str)
            logger.show_table(v, number + 1, skipindex)
         else
            str = str .. tostring(v)
            print(str)
         end
      end
   end
end

return logger
