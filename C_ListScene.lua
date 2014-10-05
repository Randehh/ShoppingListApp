-----------------------------------------------------------------------------------------
--
-- Display lists
--
-----------------------------------------------------------------------------------------

local storyboard = require("storyboard")
local scene = storyboard.newScene()
local widget = require( "widget" )
require("C_Helper")
require("C_Globals")

storyboard.removeAll()

function scene:createScene(event)
	print("Loaded scene Main Menu")
	storyboard.removeAll()

	local fontSize = 30
	local objectSpacing = 100

	local group = self.view

	--Create black bars and background
	local background = display.newRect(display.pixelWidth / 2 - C_Globals.xResolutionOffset, display.pixelHeight / 2, display.pixelWidth, display.pixelHeight)
	background:setFillColor(0.63, 0.77, 0.49, 1)
	group:insert(background)

	local lockedOn = false
	local function scrollListener( event )
	    if lockedOn == false then return true
	    else return false
	    end
	end

	-----------------------------------------------------
	-- CREATE SCROLLVIEW
	-----------------------------------------------------

	local scrollBarOptions = {
	    width = 20,
	    height = 20,
	    numFrames = 3,
	    sheetContentWidth = 20,
	    sheetContentHeight = 60
	}
	local scrollBarSheet = graphics.newImageSheet( "Graphics/Scrollbar.png", scrollBarOptions )
	local scrollView = widget.newScrollView
	{
	    top = 150  - (C_Globals.yResolutionOffset / 2),
	    left = -C_Globals.xResolutionOffset,
	    width = display.pixelWidth,
	    height = display.pixelHeight - 150 - (C_Globals.yResolutionOffset / 2),
	    listener = scrollListener,
	    hideBackground = true,
	    horizontalScrollDisabled = true,
	    friction = 0.95,
	    scrollBarOptions = {
	        sheet = scrollBarSheet,
	        topFrame = 1,
	        middleFrame = 2,
	        bottomFrame = 3
	    }
	}
	group:insert(scrollView)

	--------------------------------------------------
	--BLOCK FUNCTIONS
	--------------------------------------------------
	local content = {listName = "Test List", blocks = {}, lines = {}, text = {} }

	--Create title
	local titleText
	local function createTitle()
		local titleTextOptions = 
		{
		    --parent = textGroup,
		    text = content.listName,     
		    x = 320,
		    y = 75 - (C_Globals.yResolutionOffset / 2),
		    width = display.pixelWidth,
		    font = native.systemFontBold,   
		    fontSize = fontSize * 2,
		    align = "center"
		}
		titleText = display.newText(titleTextOptions)
		titleText:setTextColor(0.13,0.20,0.09,1)
	end

	local titleImage = display.newImage("Graphics/List_Top.png")
	titleImage.x = display.pixelWidth / 2 - C_Globals.xResolutionOffset
	titleImage.y = titleImage.height / 2 - (C_Globals.yResolutionOffset / 2)
	titleImage.xScale = display.pixelWidth

	local titleRect = display.newRect(display.pixelWidth / 2, 150 / 2 - C_Globals.yResolutionOffset, display.pixelWidth, 150)
	titleRect.alpha = 0
	titleRect.isHitTestable = true

	local function titleTapListener(tapEvent)
		local titleField = native.newTextField(display.pixelWidth / 2, 150 / 2 - C_Globals.yResolutionOffset, display.pixelWidth, 150)
		titleField.placeholder = "List name"
		titleField.size = fontSize
		titleField.hasBackground = false
		titleField.isHitTestable = true
		titleField.isEditable = true
		titleField:setTextColor(0.9,0.9,0.9,1)
		titleField.align = "center"
		titleField:setReturnKey("done")
		native.setKeyboardFocus(titleField)

		local function typeListener(typeEvent)
			if typeEvent.phase == "began" then
				titleField.text = content.listName
				titleText:removeSelf()
				titleText = nil
			elseif typeEvent.phase == "ended" or event.phase == "submitted" then
				content.listName = titleField.text
				titleField:removeSelf()
				titleField = nil
				native.setKeyboardFocus(nil)
				createTitle()
		    end
		    return true
		end
		titleField:addEventListener("userInput", typeListener)
	end
	titleRect:addEventListener("tap", titleTapListener)

	--[[local titleGradient = {
    type = "gradient",
    	color1 = { 0, 0, 0, 0.3 },
    	color2 = { 0, 0, 0, 0 },
    	direction = "down"
	}
	local titleShadowRect = display.newRect(display.pixelWidth / 2, objectSpacing * 1.2 + (objectSpacing * 0.3 / 2), display.pixelWidth, objectSpacing * 0.3)
	titleShadowRect.fill = titleGradient --]]

	createTitle()

	function editBlock(block)
		local blackBackground = display.newRect(display.pixelWidth / 2, display.pixelHeight / 2 - C_Globals.yResolutionOffset, display.pixelWidth, display.pixelHeight)
		blackBackground:setFillColor(0,0,0,0.75)

		local editScreen = display.newGroup()
		local originalY = editScreen.y
		editScreen.y = -800
		--transition.to(editScreen, { time=300, y=editScreen, transition=easing.outExpo } )

		local scrollViewX, scrollViewY = scrollView:getContentPosition()
		scrollView:setIsLocked(true)
		transition.to(editScreen, { time=400, y=originalY, transition=easing.outExpo } )

		local textBackground = display.newRoundedRect(display.pixelWidth / 2, 300 - C_Globals.yResolutionOffset, display.pixelWidth / 1.2, 480, 10)
		textBackground:setFillColor(0.85,0.85,0.85,1)
		editScreen:insert(textBackground)

		local textLine = display.newLine(100, 140 - C_Globals.yResolutionOffset, display.pixelWidth - 100, 140)
		textLine:setStrokeColor(0.6,0.6,0.6,1)
		editScreen:insert(textLine)

		local function textBoxTapEvent(boxTapEvent)
			return true
		end

		local function stopTyping(blackBackground, nameField, descriptionField)
			native.setKeyboardFocus(nil)

			transition.to( editScreen, { time=400, y= -800, transition=easing.outExpo } )
			scrollView:setIsLocked(false)

			local function listener( event )
				nameField:removeSelf()
				nameField = nil
				descriptionField:removeSelf()
				descriptionField = nil
				blackBackground:removeSelf()
				blackBackground = nil
				textBackground:removeSelf()
				textBackground = nil
				textLine:removeSelf()
				textLine = nil
				editScreen:removeSelf()
				editScreen = nil
			end

			timer.performWithDelay( 300, listener )
		end

		--Create the text
		local itemNameField = native.newTextField( display.pixelWidth / 2, 100 - C_Globals.yResolutionOffset, display.pixelWidth / 1.2, 80)
		itemNameField.placeholder = "Item name"
		itemNameField.size = fontSize
		itemNameField.hasBackground = false
		itemNameField.isHitTestable = true
		itemNameField.isEditable = true
		itemNameField["Block"] = block
		editScreen:insert(itemNameField)

		local descriptionField = native.newTextBox( display.pixelWidth / 2, 100 + (80 / 2) + (400 / 2) - C_Globals.yResolutionOffset, display.pixelWidth / 1.2, 400)
		descriptionField.placeholder = "Description"
		descriptionField.text = block["Description"]
		descriptionField.size = fontSize
		descriptionField.hasBackground = false
		descriptionField.isHitTestable = true
		descriptionField.isEditable = true
		editScreen:insert(descriptionField)

		native.setKeyboardFocus( itemNameField )

		local function itemNameListener(typeEvent)
			local originalY = scrollView.y
			if typeEvent.phase == "began" then
				itemNameField.text = block["TextObj"].text
			elseif typeEvent.phase == "ended" then
				block["TextObj"].text = itemNameField.text
		    	--stopTyping(blackBackground, itemNameField, descriptionField)
		    end
		    return true
		end
		itemNameField:addEventListener("userInput", itemNameListener)

		local function descriptionListener(typeEvent)
			local originalY = scrollView.y
			if typeEvent.phase == "began" then
				descriptionField.text = block["Description"]
			elseif typeEvent.phase == "ended" then
				block["Description"] = descriptionField.text
		    	--stopTyping(blackBackground, itemNameField, descriptionField)
		    end
		    return true
		end
		descriptionField:addEventListener("userInput", descriptionListener)

		--Background for the textbox
		local function backgroundTapEvent(boxTapEvent)
			stopTyping(blackBackground, itemNameField, descriptionField)
			return true
		end

		itemNameField:addEventListener("tap", textBoxTapEvent)
		descriptionField:addEventListener("tap", textBoxTapEvent)
		blackBackground:addEventListener("tap", backgroundTapEvent)
	end

	function addTouchListener(rect)
		local function tapEvent(tapEvent)
			editBlock(tapEvent.target["Block"])			
			return true
		end
		rect:addEventListener("tap", tapEvent)
	end

	--The add new block block
	local function addBlockTapEvent(tapEvent)
		editBlock(addBlock("", "", false, nil))
		return true
	end

	local addBlockGroup = display.newGroup()
	local addBlockTextOptions = 
		{
		    --parent = textGroup,
		    text = "Add new item...",     
		    x = display.contentWidth / 2 + C_Globals.xResolutionOffset,
		    y = (table.getn(content.blocks) + 1) * objectSpacing + (objectSpacing / 2) - C_Globals.yResolutionOffset,
		    width = display.pixelWidth - (display.pixelWidth / 9),
		    font = native.systemFontBold,   
		    fontSize = fontSize,
		    align = "center"
		}
	local addBlockText = display.newText(addBlockTextOptions)
	addBlockText:setTextColor(0.5,0.5,0.5,1)

	--Create touch rectangle
	local addBlockRect = display.newRect(display.contentWidth / 2 + C_Globals.xResolutionOffset, table.getn(content.blocks) * objectSpacing + (objectSpacing / 2) - C_Globals.yResolutionOffset, display.pixelWidth, objectSpacing)
	addBlockRect.isHitTestable = true
	addBlockRect:setFillColor(0.9,0.9,0.9,1)

	--Create the shadow
	local addBlockShadow = display.newImage("Graphics/Shadow.png")
	addBlockShadow.x = display.contentWidth / 2 + C_Globals.xResolutionOffset
	addBlockShadow.y = addBlockRect.y + (objectSpacing / 2) - C_Globals.yResolutionOffset
	addBlockShadow.xScale = display.pixelWidth

	addBlockGroup:insert(addBlockRect)
	addBlockGroup:insert(addBlockText)
	addBlockGroup:insert(addBlockShadow)
	scrollView:insert(addBlockGroup)

	addBlockRect:addEventListener("tap", addBlockTapEvent)

	function repositionAddBlock()
		transition.to(addBlockRect, { time=500, y=table.getn(content.blocks) * objectSpacing + (objectSpacing / 2), transition=easing.outExpo } )
		transition.to(addBlockText, { time=500, y=table.getn(content.blocks) * objectSpacing + (objectSpacing / 2), transition=easing.outExpo } )
		transition.to(addBlockShadow, { time=500, y=(table.getn(content.blocks) + 1) * objectSpacing + (33 / 2), transition=easing.outExpo } )
	end

	local originalScrollViewSize = (table.getn(content.blocks)) * objectSpacing
	local subMenuGroup = { blocks = {}, lowerBlockGroup = display.newGroup()}
	local lowerBlockGroup = nil
	local bottomShadow = nil
	local openSubMenu = nil
	function setCheckMode(block)
		print("Checking block...")
		local checkMode = block["CheckMode"]
		if checkMode == 0 then
			block.checkboxComplete.alpha = 0
			block.checkboxHalf.alpha = 0
		elseif checkMode == 1 then
			block.checkboxComplete.alpha = 1
			block.checkboxHalf.alpha = 0
		else
			block.checkboxComplete.alpha = 0
			block.checkboxHalf.alpha = 1
		end

		--Check if checkboxes are correct
		if block.headBlock ~= nil then
			print("Sub menu found...")
			local zeroFound = false
			local oneFound = false
			for i=1,#subMenuGroup.blocks do
				local tempBlock = subMenuGroup.blocks[i]
				if tempBlock["CheckMode"] == 0 then
					zeroFound = true
				else
					oneFound = true
				end
			end

			if zeroFound and oneFound then
				subMenuGroup.blocks[1].headBlock["CheckMode"] = 2
			elseif zeroFound then
				subMenuGroup.blocks[1].headBlock["CheckMode"] = 0
			else
				subMenuGroup.blocks[1].headBlock["CheckMode"] = 1
			end
			setCheckMode(subMenuGroup.blocks[1].headBlock)
		end
	end

	function checkSubmenu(block)
		if tablelength(block["SubBlocks"]) ~= 0 then
			block["Arrow"].alpha = 1
			block["ArrowHitbox"].isHitTestable = true
		else
			block["Arrow"].alpha = 0
			block["ArrowHitbox"].isHitTestable = true
		end
	end

	function toggleSubMenu(block, forceClose)
		local arrow = block["Arrow"]
		if arrow["CheckMode"] == 0 then --Close Menu

			--Rotate arrow
			transition.to(arrow, { time=500, rotation=-90, transition=easing.outExpo } )
			arrow["CheckMode"] = 1

			--Move blocks back
			transition.to(lowerBlockGroup, { time=500, y=0, transition=easing.outExpo } )

			for i=1,#subMenuGroup.blocks do
				local tempBlock = subMenuGroup.blocks[i]
				local subBlock = tempBlock.headBlock["SubBlocks"][i-1]
				subBlock["Title"] = tempBlock["TextObj"].text
				subBlock["Description"] = tempBlock["Description"]
				subBlock["CheckMode"] = tempBlock["CheckMode"]
				table.remove(content.blocks, getIndexFromList(content.blocks,subMenuGroup.blocks[i]))
			end

			local toBeRemoved = display.newGroup()
			local oldLowerBlockGroup = lowerBlockGroup
			toBeRemoved:insert(subMenuGroup.DisplayGroup)
			toBeRemoved:insert(bottomShadow)

			local function removeDelay( event )
				scrollView:remove(oldLowerBlockGroup)
				scrollView:remove(toBeRemoved)
				toBeRemoved:removeSelf()
				toBeRemoved = display.newGroup()
				toBeRemoved = nil
			end
			timer.performWithDelay(500, removeDelay )
			subMenuGroup = { blocks = {}, DisplayGroup = display.newGroup()}

			--Set scroll height if closing normally
			if forceClose == false then
				scrollView:setScrollHeight((table.getn(content.blocks)) * objectSpacing + objectSpacing - (C_Globals.yResolutionOffset))
			end

			openSubMenu = nil
		
		else --Open menu

			--Force close the other subblock if there is one
			if openSubMenu ~= nil and openSubMenu ~= block and openSubMenu["Arrow"]["CheckMode"] == 0 then
				toggleSubMenu(openSubMenu, true)
			end

			--Rotate arrow
			transition.to(arrow, { time=500, rotation=0, transition=easing.outExpo } )
			arrow["CheckMode"] = 0

			--Move stuff down
			lowerBlockGroup = display.newGroup()
			local block = arrow["Block"]
			for i=block["BlockNumber"] + 1,table.getn(content.blocks) do
				lowerBlockGroup:insert(content.blocks[i]["DisplayGroup"])
			end
			bottomShadow = display.newImage("Graphics/Shadow.png")
			bottomShadow.x = display.pixelWidth / 2
			bottomShadow.y = block["DisplayGroup"].y + (objectSpacing * (tablelength(block["SubBlocks"]) + 1)) - (33 / 2)
			bottomShadow.rotation = 180
			bottomShadow.xScale = display.pixelWidth
			lowerBlockGroup:insert(bottomShadow)
			transition.to(lowerBlockGroup, { time=500, y=(tablelength(block["SubBlocks"])) * objectSpacing, transition=easing.outExpo } )
			scrollView:insert(lowerBlockGroup)

			--Spawn the new sub blocks
			subMenuGroup.DisplayGroup = display.newGroup()
			for i=0,tablelength(block["SubBlocks"]) - 1 do
				local subBlock = block["SubBlocks"][i]
				local tempBlock = addBlock(subBlock["Title"],subBlock["Description"],subBlock["CheckMode"],block)
				subMenuGroup.DisplayGroup:insert(tempBlock["DisplayGroup"])
			end
			local topShadow = display.newImage("Graphics/Shadow.png")
			topShadow.x = display.pixelWidth / 2
			topShadow.y = block["DisplayGroup"].y + (objectSpacing * (tablelength(block["SubBlocks"]) + 1)) + (33 / 2)
			topShadow:toFront()
			subMenuGroup.DisplayGroup:insert(topShadow)
			scrollView:insert(subMenuGroup.DisplayGroup)
			block.currentBlock = 0
			subMenuGroup.DisplayGroup:toBack()

			scrollView:setScrollHeight((table.getn(content.blocks)) * objectSpacing + objectSpacing - (C_Globals.yResolutionOffset))
			openSubMenu = block
		end

		repositionAddBlock()
	end

	function addBlock(title, description, checkMode, headBlock)
		local newBlock = { ["Description"] = description, ["CheckMode"] = checkMode, ["SubBlocks"] = {}}
		local blockDisplayGroup = display.newGroup()
		blockDisplayGroup.Block = newBlock
		newBlock["DisplayGroup"] = blockDisplayGroup
		newBlock.currentBlock = 0

		local yCenter = 0
		local textColor = {}
		local rectColor = {}
		local lineColor = {}
		if headBlock == nil then
			yCenter = table.getn(content.blocks) * objectSpacing + (objectSpacing / 2)
			textColor.r = 0.2
			textColor.b = 0.2
			textColor.g = 0.2
			rectColor.r = 0.82
			rectColor.b = 0.82
			rectColor.g = 0.82
			lineColor.r = 0.65
			lineColor.b = 0.65
			lineColor.g = 0.65
		else
			yCenter = headBlock["Rect"].y + (headBlock.currentBlock * objectSpacing) + objectSpacing
			headBlock.currentBlock = headBlock.currentBlock + 1
			textColor.r = 0.25
			textColor.b = 0.25
			textColor.g = 0.25
			rectColor.r = 0.73
			rectColor.b = 0.73
			rectColor.g = 0.73
			lineColor.r = 0.35
			lineColor.b = 0.35
			lineColor.g = 0.35
		end

		--Create touch rectangle
		local rect = display.newRect(display.pixelWidth / 2, yCenter, display.pixelWidth, objectSpacing)
		rect:setFillColor(rectColor.r,rectColor.b,rectColor.g,1)
		rect.isHitTestable = true
		rect["Block"] = newBlock
		newBlock["Rect"] = rect

		--Create text
		local textOptions = 
		{
		    text = title,     
		    x = display.contentWidth / 2 + C_Globals.xResolutionOffset,
		    y = yCenter,
		    width = display.pixelWidth - (display.pixelWidth / 9),
		    font = native.systemFontBold,   
		    fontSize = fontSize,
		    align = "center"
		}
		local text = display.newText(textOptions)
		text:setTextColor(textColor.r,textColor.b,textColor.g,1)
		newBlock["TextObj"] = text

		--Create arrow
		local arrow = display.newImage("Graphics/Arrow.png")
		arrow.x = 55 + (C_Globals.xResolutionOffset / 2)
		arrow.y = rect.y
		arrow.rotation = -90
		arrow["CheckMode"] = 1
		arrow["Block"] = newBlock
		newBlock["Arrow"] = arrow

		local arrowHitbox = display.newRect(55 + (C_Globals.xResolutionOffset / 2), arrow.y, 100,100)
		arrowHitbox.alpha = 0
		arrowHitbox.isHitTestable = true
		newBlock["ArrowHitbox"] = arrowHitbox

		if headBlock == nil then
			local length = table.getn(content.blocks)
			if length ~= 0 then
				for i=0,length - 1 do
					newBlock["SubBlocks"][i]= { ["Title"] = "Hello", ["Description"] = "DERP", ["CheckMode"] = 0}
				end
			end
		end
		checkSubmenu(newBlock)

		local function arrowTapEvent(tapEvent)
			toggleSubMenu(arrow["Block"], false)
			return true
		end
		arrowHitbox:addEventListener("tap",arrowTapEvent)

		--Create checkbox
		local checkbox = display.newImage("Graphics/Checkbox.png")
		checkbox.x = 590 + C_Globals.xResolutionOffset
		checkbox.y = rect.y

		local checkboxHitbox = display.newRect(590 + C_Globals.xResolutionOffset,rect.y,100,100)
		checkboxHitbox.alpha = 0
		checkboxHitbox.isHitTestable = true

		local checkboxComplete = display.newImage("Graphics/Checkbox_Complete.png")
		checkboxComplete.x = 590 + C_Globals.xResolutionOffset
		checkboxComplete.y = rect.y
		checkboxComplete.alpha = 0

		local checkboxHalf = display.newImage("Graphics/Checkbox_Half.png")
		checkboxHalf.x = 590 + C_Globals.xResolutionOffset
		checkboxHalf.y = rect.y
		checkboxHalf.alpha = 0

		newBlock.checkboxComplete = checkboxComplete
		newBlock.checkboxHalf = checkboxHalf

		setCheckMode(newBlock)

		--Add the touch block
		addTouchListener(rect)

		--Add listener for checkbox
		local function checkboxTapEvent(tapEvent)
			if newBlock["CheckMode"] == 0 then
				newBlock["CheckMode"] = 1
			else
				newBlock["CheckMode"] = 0
			end
			setCheckMode(newBlock)
			return true
		end
		checkboxHitbox:addEventListener("tap",checkboxTapEvent)

		--Add the block to the block list
		newBlock["BlockNumber"] = table.getn(content.blocks) + 1
		table.insert(content.blocks, newBlock)
		if headBlock ~= nil then
			newBlock.headBlock = headBlock
			table.insert(subMenuGroup.blocks, newBlock)
		end

		--Add the objects to the view
		blockDisplayGroup:insert(rect)
		blockDisplayGroup:insert(text)
		blockDisplayGroup:insert(arrow)
		blockDisplayGroup:insert(arrowHitbox)
		blockDisplayGroup:insert(checkbox)
		blockDisplayGroup:insert(checkboxHitbox)
		blockDisplayGroup:insert(checkboxComplete)
		blockDisplayGroup:insert(checkboxHalf)
		scrollView:insert(blockDisplayGroup)

		--Add another line if the text is not the first one
		if table.getn(content.blocks) ~= 1 then
			local x1 = 50
			local x2 = display.pixelWidth - 50
			local y = yCenter - (objectSpacing / 2)
			local newLine = display.newLine(x1, y, x2, y)
			newLine.strokeWidth = 2
			newLine:setStrokeColor(lineColor.r,lineColor.b,lineColor.g,1)
			content.lines[tablelength(content.lines)] = newLine
			blockDisplayGroup:insert(newLine)
			newLine:toFront()
		end

		if headBlock ~= nil then
			blockDisplayGroup:toBack()
		end

		repositionAddBlock()

		originalScrollViewSize = (table.getn(content.blocks) + 1) * objectSpacing
		scrollView:setScrollHeight(originalScrollViewSize)

		return newBlock
	end

	function removeBlock()
		content.text[tablelength(content.text) - 1] = nil
	end

	--[[addBlock("Cheese", "GLORIOUS CHEESE", 0, nil)
	addBlock("Divine rapier", "Throwin' the game like a boss", 0, nil)
	addBlock("Heart of Tarrasque", "Get dat health regen", 0, nil)
	addBlock("Shiva's Guard", "Freeze, motherfucker!", 0, nil)
	addBlock("Butterfly", "Evasion for the win", 0, nil)
	addBlock("BKB", "DON'T TOUCH ME", 0, nil)
	addBlock("MKB", "No more dodgin' for you!", 0, nil)
	addBlock("Bloodstone", "I don't wanna be in heaven this long...", 0, nil)
	addBlock("Chainmail", "Stop. Touching. Me.", 0, nil)
	addBlock("Stout Shield", "Block! Block! Block!", 0, nil)--]]

	repositionAddBlock()
end
scene:addEventListener( "createScene", scene )

return scene