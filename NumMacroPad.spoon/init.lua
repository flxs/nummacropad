--- === NumMacroPad ===
--- Use your numpad as a text macro pad
---

local obj={}
obj.__index = obj

-- Metadata
obj.name = "NumMacroPad"
obj.version = "0.0.1"
-- End of Metadata

obj.last_msgs = {}
obj.layer = 1

function obj:key_layer_shift(key)
	hs.hotkey.bind({}, "pad"..key, 
		function() obj.layer=2 end,
		function() obj.layer=1 end)
end

function obj:key_message(key, messages_primary, messages_alt)
	hs.hotkey.bind({}, "pad"..key, function()
		keystr = hs.inspect(mod)..key
		
		local messages
		if obj.layer==1 then
			messages = messages_primary
		elseif obj.layer==2 then
			messages = messages_alt
		end

		local write_message 
		if messages==nil then
			print("Message for key "..key..", layer "..layer.." is nil!")
			return
		elseif type(messages) == "string" then
			print("str")
			write_message = messages
		elseif type(messages) == "table" then			
			if #messages == 1 then
				write_message = messages[1]
			else
				index = hs.math.randomFromRange(1,#messages)
				write_message = messages[index]
				-- avoid sending the same message twice in a row
				-- only applicable if there are at least two messages
				-- 100 iterations max, no infinite loops
				iterations = 0
				while #messages>1 and write_message == obj.last_msgs[keystr] and iterations<100 do
					iterations = iterations+1
					write_message = messages[hs.math.randomFromRange(1,#messages)]
				end
			end
		else
			print("Message for key "..key..", layer "..layer.." is invalid: '"..messages.."'")
			return
		end
		
		-- actually type the message, with return or without
		if string.find(write_message, "<enter>$") then
			write_message_cleaned = string.gsub(write_message, "<enter>$", "")
			hs.eventtap.keyStrokes(write_message_cleaned)
			hs.eventtap.keyStroke({}, "return")
		else
			hs.eventtap.keyStrokes(write_message)
		end
		
		-- save message for the next not-twice-in-a-row check
		obj.last_msgs[keystr] = write_message
	end)
end

return obj