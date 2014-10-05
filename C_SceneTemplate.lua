-----------------------------------------------------------------------------------------
--
-- SCENE TEMPLATE
--
-----------------------------------------------------------------------------------------

local storyboard = require("storyboard")
local scene = storyboard.newScene()
local widget = require( "widget" )
require("C_Helper")
require("C_Globals")

storyboard.removeAll()

function scene:createScene(event)

end
scene:addEventListener( "createScene", scene )

return scene