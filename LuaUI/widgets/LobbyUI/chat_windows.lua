ChatWindows = LCS.class{}

function ChatWindows:init()
    -- setup debug console to listen to commands
    --[[
    self.debugConsole = Console()
    self.debugConsole.listener = function(message)
        lobby:SendCustomCommand(message)
    end
    lobby:AddListener("OnCommandReceived",
        function(listner, command)
            self.debugConsole:AddMessage("<" .. command)
        end
    )
    lobby:AddListener("OnCommandSent",
        function(listner, command)
            self.debugConsole:AddMessage(">" .. command)
        end
    )
    --]]

    -- get a list of channels when login is done
    lobby:AddListener("OnLoginInfoEnd",
        function(listener)
            lobby:RemoveListener("OnLoginInfoEnd", listener)

            self.channels = {} -- list of known channels retrieved from OnChannel
            local onChannel = function(listener, chanName, userCount, topic)
                self.channels[chanName] = { userCount = userCount, topic = topic }
            end

            lobby:AddListener("OnChannel", onChannel)
            
            lobby:AddListener("OnEndOfChannels",
                function(listener)
                    lobby:RemoveListener("OnEndOfChannels", listener)
                    lobby:RemoveListener("OnChannel", onChannel)

                    local channelsArray = {}
                    for chanName, v in pairs(self.channels) do
                        table.insert(channelsArray, { 
                            chanName = chanName, 
                            userCount = v.userCount, 
                            topic = v.topic,
                        })
                    end
                    table.sort(channelsArray, 
                        function(a, b)
                            return a.userCount > b.userCount
                        end
                    )
                    self:UpdateChannels(channelsArray)
                end
            )

            lobby:Channels()
        end
    )

    self.channelConsoles = {}
    self.userListPanels = {}
    lobby:AddListener("OnJoin",
        function(listener, chanName)
            local channelConsole = Console()
            self.channelConsoles[chanName] = channelConsole

            channelConsole.listener = function(message)
                lobby:Say(chanName, message)
            end

            local userListPanel = UserListPanel(chanName)
            self.userListPanels[chanName] = userListPanel
            
            self.tabPanel:AddTab(
                {
                    name = "#" .. chanName, 
                    children = {
                        Control:New {
                            x = 0, y = 0, right = 202, bottom = 0,
                            padding={0,0,0,0}, itemPadding={0,0,0,0}, itemMargin={0,0,0,0},
                            children = { channelConsole.panel, },
                        },
                        Control:New {
                            width = 200, y = 0, right = 0, bottom = 0,
                            padding={0,0,0,0}, itemPadding={0,0,0,0}, itemMargin={0,0,0,0},
                            children = { userListPanel.panel, },
                        },
                    }
                }
            )

            lobby:AddListener("OnClients", 
                function(listener, clientsChanName, clients)
                    if chanName == clientsChanName then
                        Spring.Echo("Users in channel: " .. chanName, #lobby:GetChannel(chanName).users)
                    end
                end
            )
        end
    )
	
	lobby:AddListener("OnJoined",
		function(listener, chanName, userName)
			local channelConsole = self.channelConsoles[chanName]
			if channelConsole ~= nil then
                channelConsole:AddMessage("\255\128\255\0" .. userName .. " joined " .. chanName .. "\b")
            end
		end	
	)

	lobby:AddListener("OnLeft",
		function(listener, chanName, userName)
			local channelConsole = self.channelConsoles[chanName]
			if channelConsole ~= nil then
                channelConsole:AddMessage("\255\200\0\0" .. userName .. " left " .. chanName .. "\b")
            end
		end
	)
	
	-- channel chat
    lobby:AddListener("OnSaid", 
        function(listener, chanName, userName, message, msgDate)
            local channelConsole = self.channelConsoles[chanName]
            if channelConsole ~= nil then
                channelConsole:AddMessage(message, userName, msgDate)
            end
        end
    )
    lobby:AddListener("OnSaidEx", 
        function(listener, chanName, userName, message)
            local channelConsole = self.channelConsoles[chanName]
            if channelConsole ~= nil then
                channelConsole:AddMessage("\255\0\139\139" .. userName .. " " .. message .. "\b")
            end
        end
    )	
	
	-- private chat
	self.privateChatConsoles = {}	
    lobby:AddListener("OnSayPrivate",
        function(listener, userName, message)
			local privateChatConsole = self:GetPrivateChatConsole(userName)
			privateChatConsole:AddMessage(message, lobby:GetMyUserName())
        end
    )
	lobby:AddListener("OnSaidPrivate",
        function(listener, userName, message)
			if userName == 'Nightwatch' then
				local chanName, userName, mDate, msg = message:match('.-|(.+)|(.+)|(.+)|(.*)')
				local channelConsole = self.channelConsoles[chanName]
				if channelConsole ~= nil then
					channelConsole:AddMessage(msg, userName, mDate)
				end
			else
				local privateChatConsole = self:GetPrivateChatConsole(userName)
				privateChatConsole:AddMessage(message, userName)
			end
        end
    )

    self.serverPanel = ScrollPanel:New {
        x = 0,
        right = 5,
        y = 0,
        height = "100%",
    }
	
    self.tabPanel = Chili.TabPanel:New {
        x = 0,
		barheight = 25,
		tabWidth  = 100,
        right = 0,
        y = 0, 
        bottom = 0,
        padding = {0, 0, 0, 0}, margin = {0,0,0,0},
        tabs = {
            { name = "Channels", children = {self.serverPanel} },
            --{ name = "debug", children = {self.debugConsole.panel} },
        },
    }
	

	local scrH = screen0.height
	local scrW = screen0.width
	
    self.panel = Chili.Panel:New {
		parent = screen0,
		padding = {5,5,5,10},
        x = scrW/2 - 400, width = 800,
        y = 720, height = 300,
        children = {
            self.tabPanel,
        }
    }
	
	self.panel:BringToFront()
    -- self.window = Control:New {
        -- x = 0, right = 0,
        -- y = 10, bottom = 0,
		-- padding = {0,0,0,0}, margin = {0,0,0,0},
        -- children = {
            -- self.tabPanel,
        -- }
    -- }
	
	-- WG.MainMenu.AddControl('Chat',self.window)
	
	
    CHILI_LOBBY = { chatWindows = self }
end

function ChatWindows:UpdateChannels(channelsArray)
    self.serverPanel:ClearChildren()

    for i, channel in pairs(channelsArray) do
        self.serverPanel:AddChild(Button:New {
			tooltip = channel.topic:gsub('\\n','\n'),
            x = ((i - 1) % 4) * 25 + .5 ..'%',
            width = '24%',
            y = math.floor((i - 1) / 4) * 34,
            height = 32,
			caption = '',
			padding = {2,2,2,2},
			OnClick = {
                function()
                    lobby:Join(channel.chanName)
                end
            },
            children = {
                Label:New {
                    right = '80%',
                    width = 100,
                    y = 0,
                    height = 20,
					fontSize = 20,
                    caption = channel.userCount,
                },
                Label:New {
                    x = '23%',
                    width = 100,
                    y = 0,
                    height = 20,
					fontSize = 20,
                    caption = channel.chanName,
                },
            }
        })
    end
end

function ChatWindows:GetPrivateChatConsole(userName)
	if self.privateChatConsoles[userName] == nil then
		local privateChatConsole = Console()
		self.privateChatConsoles[userName] = privateChatConsole

		privateChatConsole.listener = function(message)
			lobby:SayPrivate(userName, message)
		end

		self.tabPanel:AddTab({name = "@" .. userName, children = {privateChatConsole.panel}})
	end
	
	return self.privateChatConsoles[userName]
end
