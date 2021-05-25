-- Smart G Selector --
	--
	-- Handle gestures, short click, and long click actions with the G Selector button.
	-- Keep G Selector initial functionality.
	--
	-- Configure the smartButton variable to your assigned G Selector button, by default 6 is the "snipe" button.
	-- Set smartButton8Way to true to enable 8-way gestures with narrower directions, by default handle 4-way gestures.
	-- Create macros and alter the Left/Right/Up/Down/... PlayMacro("MacroName") sections of the code.
	-- Or write directly PressKey()/ReleaseKey() actions.
EnablePrimaryMouseButtonEvents(true)
deltaMin = 150  -- Minimum click time before registering an action or movement
delta = 550  -- Time to register a long click
debug = false -- Debug mode : if true does not perform any action --

--Button codes
LEFT_BUTTON = 1
RIGHT_BUTTON = 2
MIDDLE_BUTTON = 3
UP_BUTTON = 8
DOWN_BUTTON = 7
SMART_BUTTON = 6  -- The button affected to G Selector in Logitech control panel (default 6 = "snipe" thubm button)

ButtonAction = { button = 0, shortAction = "", longAction = "" }

function ButtonAction:new ( o, b, sA, lA )
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.button = b or -1
	self.shortAction = sA or ""
	self.longAction = lA or ""
	return o
end

function ButtonAction:IsButton( arg )
	return arg == self.button
end

function ButtonAction:OnAction( event )
	if event == "MOUSE_BUTTON_PRESSED" then
		buttonStart = GetRunningTime()
	elseif event == "MOUSE_BUTTON_RELEASED" then
		buttonDuration = GetRunningTime() - buttonStart
		if buttonDuration < deltaMin then
			OutputLogMessage("Short click (".. buttonDuration /1000 .."s < ".. deltaMin/1000 .."s) \n")
		elseif buttonDuration < delta then
			if not debug then
				PlayMacro(self.shortAction)
			end
			OutputLogMessage("Performed short action (".. self.shortAction ..") on button (".. self.button ..") \n")
		else
			if not debug then
				PlayMacro(self.longAction)
			end
			OutputLogMessage("Performed long action (".. self.longAction ..") on button (".. self.button ..") \n")
		end
	end
end


function OnEvent(event, arg)
	-- Smart button / G Selector --
	
	smartButtonGestures = true -- Set to false to deactivate gestures.
	smartButton8Way = true -- Set to false for U/D/L/R gestures only, otherwise also handle the diagonals (greater leeway in 4-way mode)

	smartButtonDistanceMin = 2000  -- Minimum distance to register a movement
	smartButtonDistanceMax = 30000  -- Maximum distance for a movement
	smartButtonMonitorRatio = 16/9  -- Monitor ratio

	
	
	if arg == SMART_BUTTON then
		if event == "MOUSE_BUTTON_PRESSED" then
			GSelectorActive = true

			smartButtonStart = GetRunningTime()
			smartButtonDuration = nil
			smx1, smy1 = GetMousePosition()

			--OutputLogMessage("Mouse at: "..smx1..", "..smy1.."\n");
	
		elseif event == "MOUSE_BUTTON_RELEASED" then
			smartButtonDuration = GetRunningTime() - smartButtonStart
			smx2, smy2 = GetMousePosition()
			smxDelta = math.floor((smx2 - smx1) * smartButtonMonitorRatio)  -- Normalize delta X for 16:9 monitor
			smyDelta = smy2 - smy1
			smAngle = math.floor((math.atan(smyDelta, smxDelta) * 180 / math.pi) * 10) / 10
			smDistance = math.floor(math.sqrt((smxDelta^2) + (smyDelta^2)))

			if debug then
				OutputLogMessage("Mouse moved by: "..smxDelta..", "..smyDelta..". ");
				OutputLogMessage("Angle: ".. smAngle..", distance: "..smDistance..".\n")
			end

			if GSelectorAction then
				-- Do nothing: G Selector action already performed
				OutputLogMessage("Cancel action: G Selector action already performed \n")

			elseif smDistance > smartButtonDistanceMax then
				-- Do nothing: moved too far
				OutputLogMessage("Cancel action: Moved too far (".. smDistance .." > ".. smartButtonDistanceMax ..")\n")

			elseif smartButtonDuration < deltaMin or smDistance < smartButtonDistanceMin then
				-- Simple click
				if smartButtonDuration < deltaMin then
					OutputLogMessage("Short click (".. smartButtonDuration /1000 .."s < ".. deltaMin/1000 .."s) \n")
				elseif smDistance < smartButtonDistanceMin then
					OutputLogMessage("No movement (".. smDistance .." < ".. smartButtonDistanceMin ..")\n")
				end

				if smartButtonDuration < delta then
					-- Short click
					OutputLogMessage("Perform smart button short action \n")
					if not debug then
						PlayMacro("SmartShort")
					end
				else
					-- Long click
					OutputLogMessage("Perform smart button long action \n")
					if not debug then
						PlayMacro("SmartLong")
					end
				end

			elseif (smartButtonGestures) and ((smartButton8Way and ((180 >= smAngle and smAngle > 157.5) or (-157.5 > smAngle and smAngle >= -180)))
				or (not smartButton8Way and ((180 >= smAngle and smAngle > 135) or (-135 > smAngle and smAngle >= -180))))then
				-- Left
				OutputLogMessage("Left \n")
				if not debug then
					PlayMacro("Playlist1")
				end

			elseif (smartButtonGestures) and ((smartButton8Way and 22.5 >= smAngle and smAngle > -22.5)
				or (not smartButton8Way and 45 >= smAngle and smAngle > -45)) then
				-- Right
				OutputLogMessage("Right \n")
				if not debug then
					PlayMacro("Playlist2")
				end

			elseif (smartButtonGestures) and ((smartButton8Way and -67.5 >= smAngle and smAngle > -112.5)
				or (not smartButton8Way and -45 >= smAngle and smAngle > -135)) then
				-- Up
				OutputLogMessage("Up \n")
				if not debug then
					PlayMacro("Playlist3")
				end

			elseif (smartButtonGestures) and ((smartButton8Way and 112.5 >= smAngle and smAngle > 67.5)
				or (not smartButton8Way and 135 >= smAngle and smAngle > 45)) then
				-- Down
				OutputLogMessage("Down \n")
				if not debug then
					PlayMacro("Playlist4")
				end

			elseif smartButtonGestures and smartButton8Way and -112.5 >= smAngle and smAngle > -157.5 then
				-- Up Left
				OutputLogMessage("Up Left \n")
				if not debug then
					PlayMacro("UpLeft")
				end
			
			elseif smartButtonGestures and smartButton8Way and -22.5 >= smAngle and smAngle > -67.5 then
				-- Up Right
				OutputLogMessage("Up Right \n")
				if not debug then
					PlayMacro("UpRight")
				end

			elseif smartButtonGestures and smartButton8Way and 157.5 >= smAngle and smAngle > 112.5 then
				-- Down Left
				OutputLogMessage("Down Left \n")
				if not debug then
					PlayMacro("DownLeft")
				end

			elseif smartButtonGestures and smartButton8Way and 67.5 >= smAngle and smAngle > 22.5 then
				-- Donw Right
				OutputLogMessage("Down Right \n")
				if not debug then
					PlayMacro("DownRight")
				end

			end

			GSelectorActive = false
			GSelectorAction = false
		end

		return
	end

	-- Capture button actions --
	OutputLogMessage("Event: "..event.." Arg: "..arg.."\n");
	if GSelectorActive and (event == "MOUSE_BUTTON_PRESSED" or event == "MOUSE_BUTTON_RELEASED" ) then
		GSelectorAction = true

		-- I don't have real objects here, so we just re-use the same handle. It work, I lua known't.
		button = {}

		button = ButtonAction:new( nil, MIDDLE_BUTTON, "PlayPause", "Stop")
		if button:IsButton(arg) then
			button:OnAction( event )
		end

		button = ButtonAction:new( nil, LEFT_BUTTON, "Previous", "Previous")
		if button:IsButton(arg) then
			button:OnAction( event )
		end		

		button = ButtonAction:new( nil, RIGHT_BUTTON, "Next", "Next")
		if button:IsButton(arg) then
			button:OnAction( event )
		end
		
		button = ButtonAction:new( nil, UP_BUTTON, "", "ToggleLyrics")
		if button:IsButton(arg) then
			button:OnAction( event )
		end

		button = ButtonAction:new( nil, DOWN_BUTTON, "", "")
		if button:IsButton(arg) then
			button:OnAction( event )
		end
	end
end