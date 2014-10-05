-----------------------------------------------------------------------------------------
--
-- Global variables
--
-----------------------------------------------------------------------------------------

module("C_Globals", package.seeall)

yResolutionOffset = (display.pixelHeight - display.contentHeight) / 2
xResolutionOffset = (display.pixelWidth - display.contentWidth) / 2

print(xResolutionOffset,yResolutionOffset)