Console = LCS.class{}

function Console:init()
    self.listener = nil
	self.lastUser = ''
	
    self.spHistory = ScrollPanel:New {
        x = 0,
        right = 0,
        y = 0,
        bottom = 42,
    }
	
    self.tbHistory = Chili.StackPanel:New {
        x = 0,
        y = 0,
		width       = '100%',
		resizeItems = false,
		autosize    = true,
		padding     = {0,0,0,0},
		itemPadding = {0,0,0,0},
		itemMargin  = {0,0,0,0},
        parent = self.spHistory,
    }

    self.ebInputText = EditBox:New {
        x = 0,
        bottom = 7,
        height = 25,
        right = 100,
        text = "",
    }
    self.btnSubmit = Button:New {
        bottom = 0,
        height = 40,
        right = 0,
        width = 90,
        caption = "Submit",
        OnClick = { 
            function(...)
                self:SendMessage()
            end
        }
    }
    self.ebInputText.OnKeyPress = {
        function(obj, key, mods, ...)
            if key == Spring.GetKeyCode("enter") or 
                key == Spring.GetKeyCode("numpad_enter") then
                self:SendMessage()
            end

        end
    }
    self.panel = Control:New {
        x = 0,
        y = 0,
        right = 0,
        bottom = 0,
        padding      = {0, 0, 0, 0},
        itemPadding  = {0, 4, 0, 0},
        itemMargin   = {0, 2, 0, 2},
        children = {
            self.spHistory,
            self.ebInputText,
            self.btnSubmit
        },
    }
end

function Console:SendMessage()
    if self.ebInputText.text ~= "" then
        message = self.ebInputText.text
        if self.listener then
            self.listener(message)
        end
        self.ebInputText:SetText("")
    end
end

function Console:AddMessage(message, userName, msgDate)
	local font = self.tbHistory.font
	local wrapped = font:WrapText(message, self.tbHistory.width, 100)
	local _,_,numLines = self.tbHistory.font:GetTextHeight(wrapped)
	local height = numLines and numLines * 14 or 14
	
	name = self.lastUser == userName and '     ' or userName
	self.lastUser = userName
	
	self.tbHistory:AddChild(Control:New{
		x = 0,
		width = '100%',
		height = height,
		padding = {0,0,0,0},
		tooltip = msgDate or os.date('%c'),
		children = {
			Label:New{
				x = 0,
				align = 'right',
				width = 95,
				fontsize = 12,
				caption = name and name .. ' |' or '      |',
			},
			TextBox:New{
				x = 100,
				right = 0,
				margin = {0,5,0,0},
				text = message,
			},
			
		},	
	})
end

