local function explode(div,str)
  if (div=='') then return false end
  local pos,arr = 0,{}
  -- for each divider found
  for st,sp in function() return string.find(str,div,pos,true) end do
    table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
    pos = sp + 1 -- Jump past current divider
  end
  table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
  return arr
end

-- WARNING: Don't include this file if you won't use the Wrapper, it overrides the Interface functions
Wrapper = Interface:extends{}

function Wrapper:init()
--    self:super("init")
    -- don't use these fields directly, they are subject to change
    self.users = {}
    self.userCount = 0

    self.channels = {}
    self.channelCount = 0

    self.battles = {}
    self.battleCount = 0

    self.latency = 0 -- in ms
	
	self.myUserName = nil
end

function Wrapper:Login(user, ...)
	self.myUserName = user
	self:super("Login", user, ...)
end

-- override
function Wrapper:_OnAddUser(userName, country, cpu, accountID)
    cpu = tonumber(cpu)
    accountID = tonumber(accountID)

    self.users[userName] = {userName=userName, country=country, cpu=cpu, accountID=accountID}
    self.userCount = self.userCount + 1

    self:super("_OnAddUser", userName, country, cpu, accountID)
end
Interface.commands["ADDUSER"] = Wrapper._OnAddUser

-- override
function Wrapper:_OnRemoveUser(userName)
    self.users[userName] = nil
    self.userCount = self.userCount - 1

    self:super("_OnRemoveUser", userName)
end
Interface.commands["REMOVEUSER"] = Wrapper._OnRemoveUser

-- override
function Wrapper:Ping()
    self.pingTimer = Spring.GetTimer()
    return self:super("Ping")
end

-- override
function Wrapper:_OnPong()
    self.pongTimer = Spring.GetTimer()
    self.latency = Spring.DiffTimers(self.pongTimer, self.pingTimer, true)
    self:super("_OnPong")
end
Interface.commands["PONG"] = Wrapper._OnPong

-- override
function Wrapper:_OnBattleOpened(battleID, type, natType, founder, ip, port, maxPlayers, passworded, rank, mapHash, other)
    battleID = tonumber(battleID)
    type = tonumber(type)
    natType = tonumber(natType)
    port = tonumber(port)
    maxPlayers = tonumber(maxPlayers)
    passworded = tonumber(passworded) ~= 0
    
    local engineName, engineVersion, map, title, gameName = unpack(explode("\t", other))

    self.battles[battleID] = { 
		battleID=battleID, type=type, natType=natType, founder=founder, ip=ip, port=port, 
		maxPlayers=maxPlayers, passworded=passworded, rank=rank, mapHash=mapHash, 
		engineName=engineName, engineVersion=engineVersion, map=map, title=title, gameName=gameName, users={founder},
	}
    self.battleCount = self.battleCount + 1

    self:super("_OnBattleOpened", battleID, type, natType, founder, ip, port, maxPlayers, passworded, rank, mapHash, other)
end
Interface.commands["BATTLEOPENED"] = Wrapper._OnBattleOpened

-- override
function Wrapper:_OnBattleClosed(battleID)
    self.battles[battleID] = nil
    self.battleCount = self.battleCount - 1

    self:super("_OnBattleClosed", battleID)
end
Interface.commands["BATTLECLOSED"] = Wrapper._OnBattleClosed

-- override
function Wrapper:_OnJoinedBattle(battleID, userName, scriptPassword)
    battleID = tonumber(battleID)
    table.insert(self.battles[battleID].users, userName)

    self:super("_OnJoinedBattle", battleID, userName, scriptPassword)
end
Interface.commands["JOINEDBATTLE"] = Wrapper._OnJoinedBattle

-- override
function Wrapper:_OnLeftBattle(battleID, userName)
    battleID = tonumber(battleID)

    local battleUsers = self.battles[battleID].users
    for i, v in pairs(battleUsers) do
        if v == userName then
            table.remove(battleUsers, i)
            break
        end
    end

    self:super("_OnLeftBattle", battleID, userName)
end
Interface.commands["LEFTBATTLE"] = Wrapper._OnLeftBattle

-- will also create a channel if it doesn't already exist
function Wrapper:_GetChannel(chanName)
    local channel = self.channels[chanName]
    if channel == nil then
        channel = { chanName = chanName }
        self.channels[chanName] = channel
        self.channelCount = self.channelCount + 1
    end
    return channel
end

-- override
function Wrapper:_OnChannel(chanName, userCount, topic)
    local channel = self:_GetChannel(chanName)
    channel.userCount = userCount
    channel.topic = topic

    self:super("_OnChannel", chanName, userCount, topic)
end
Interface.commands["CHANNEL"] = Wrapper._OnChannel

-- override
function Wrapper:_OnClients(chanName, clientsStr)
    local channel = self:_GetChannel(chanName)
    local users = explode(" ", clientsStr)

    if channel.users ~= nil then
        for _, user in pairs(users) do
            local found = false
            for _, existingUser in pairs(channel.users) do
                if user == existingUser then
                    found = true
                    break
                end
            end
            if not found then
                table.insert(channel.users, user)
            end
        end
    else
        channel.users = users
    end
    self:super("_OnClients", chanName, clientsStr)
end
Interface.commands["CLIENTS"] = Wrapper._OnClients

function ShallowCopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- users
function Wrapper:GetUserCount()
    return self.userCount
end
function Wrapper:GetUser(userName)
    return self.users[userName]
end
-- returns users table (not necessarily an array)
function Wrapper:GetUsers()
    return ShallowCopy(self.users)
end

-- battles
function Wrapper:GetBattleCount()
    return self.battleCount
end
function Wrapper:GetBattle(battleID)
    return self.battles[battleID]
end
-- returns battles table (not necessarily an array)
function Wrapper:GetBattles()
    return ShallowCopy(self.battles)
end

-- channels
function Wrapper:GetChannelCount()
    return self.channelCount
end
function Wrapper:GetChannel(channelName)
    return self.channels[channelName]
end
-- returns channels table (not necessarily an array)
function Wrapper:GetChannels()
    return ShallowCopy(self.channels)
end

function Wrapper:GetLatency()
    return self.latency
end

-- My data
-- My user
function Wrapper:GetMyUserName()
	return self.myUserName
end

return Wrapper
