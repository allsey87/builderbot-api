if robot.logger then
   robot.logger.register_module("utils.shallow_copy")
end

function shallow_copy(item)
   if type(item) == 'table' then
      local table = {}
      for key, value in next, item, nil do
         table[shallow_copy(key)] = shallow_copy(value)
      end
      return table
   else
      return item
   end
end

return shallow_copy


