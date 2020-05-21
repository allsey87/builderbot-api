if robot.logger then
   robot.logger.register_module("utils.deep_copy")
end

function deep_copy(item)
   if type(item) == 'table' then
      table = {}
      for key, value in next, item, nil do
         table[deep_copy(key)] = deep_copy(value)
      end
      setmetatable(table, deep_copy(getmetatable(item)))
      return table
   else
      return item
   end
end

return deep_copy


