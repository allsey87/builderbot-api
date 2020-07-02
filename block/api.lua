return {
    set_face_color = function(face, color)
        if face == "north" then
            robot.directional_leds.set_single_color(1, color)
            robot.directional_leds.set_single_color(2, color)
            robot.directional_leds.set_single_color(3, color)
            robot.directional_leds.set_single_color(4, color)
        elseif face == "east" then
            robot.directional_leds.set_single_color(5, color)
            robot.directional_leds.set_single_color(6, color)
            robot.directional_leds.set_single_color(7, color)
            robot.directional_leds.set_single_color(8, color)
        elseif face == "south" then
            robot.directional_leds.set_single_color(9, color)
            robot.directional_leds.set_single_color(10, color)
            robot.directional_leds.set_single_color(11, color)
            robot.directional_leds.set_single_color(12, color)
        elseif face == "west" then
            robot.directional_leds.set_single_color(13, color)
            robot.directional_leds.set_single_color(14, color)
            robot.directional_leds.set_single_color(15, color)
            robot.directional_leds.set_single_color(16, color)
        elseif face == "top" then
            robot.directional_leds.set_single_color(17, color)
            robot.directional_leds.set_single_color(18, color)
            robot.directional_leds.set_single_color(19, color)
            robot.directional_leds.set_single_color(20, color)
        elseif face == "bottom" then
            robot.directional_leds.set_single_color(21, color)
            robot.directional_leds.set_single_color(22, color)
            robot.directional_leds.set_single_color(23, color)
            robot.directional_leds.set_single_color(24, color)
        end
    end
}