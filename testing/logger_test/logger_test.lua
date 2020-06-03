if robot.logger then
   robot.logger.register_module("logger_test")
end

return function()
    robot.logger("INFO", "I am a logger_test INFO")
    robot.logger("WARN", "I am a logger_test WARN")
    robot.logger("ERR", "I am a logger_test ERR")
end
