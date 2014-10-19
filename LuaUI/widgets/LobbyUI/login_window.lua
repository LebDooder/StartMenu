LoginWindow = LCS.class{}

function LoginWindow:init()
	self.lblInstructions = Label:New {
		x = 1,
		width = 100,
		y = 20,
		height = 20,
		caption = "Connect to the Spring lobby server:",
	}

	self.ebUsername = EditBox:New {
		x = 0,
		width = '100%',
		y = 50,
		height = 20,
		text = user.name,
		hint = "Username",
	}
	self.ebPassword = EditBox:New {
		x = 0,
		width = '100%',
		y = 75,
		height = 20,
		text = user.pass,
		hint = "Password",
		passwordInput = true,
		OnKeyPress = {
			function(obj, key, mods, ...)
				if key == Spring.GetKeyCode("enter") or 
					key == Spring.GetKeyCode("numpad_enter") then
					self:tryLogin()
				end
				return true
			end
		},
	}
	self.chkRemember = Checkbox:New{
		x = 0,
		width = '100%',
		y = 100,
		checked = user.remember,
		caption = "Remember",
		OnChange = {
			function()
				user.remember = not user.remember
			end
		}
	}
	self.chkAuto = Checkbox:New{
		x = 0,
		width = '100%',
		y = 120,
		checked = user.auto,
		caption = "Login Automatically",
		OnChange = {
			function()
				user.auto = not user.auto
			end
		}
	}
	self.btnLogin = Button:New {
		x = 1,
		width = 80,
		bottom = 1,
		height = 20,
		caption = "Login",
		OnClick = {
			function()
				if user.remember then 
					user.name = self.ebUsername.text
					user.pass = self.ebPassword.text
				else
					user.name = ''
					user.pass = ''
				end
				self:tryLogin()
			end
		},
	}
	self.lblError = Label:New {
		x = 1,
		width = 100,
		y = 100,
		height = 80,
		caption = "",
		font = {
			color = { 1, 0, 0, 1 },
		},
	}

	self.window = Window:New {
		x = screen0.width/2 - 450,
		y = 500,
		width = 200,
		height = 200,
		caption = "Login",
		resizable = false,
		draggable = true,
		parent = screen0,
		children = {
			self.lblInstructions,
			self.ebUsername,
			self.ebPassword,
			self.lblError,
			self.chkAuto,
			self.chkRemember,
			self.btnLogin
		},
	}
	
	
	if user.auto then self:tryLogin() end
end

function LoginWindow:tryLogin()
	self.lblError:SetCaption("")

	username = self.ebUsername.text
	password = self.ebPassword.text
	if username == '' or password == '' then
		return
	end

	lobby:Initialize()

	lobby:AddListener("OnTASServer", 
		function(listener)
			lobby:RemoveListener("OnTASServer", listener)

			local onDenied = function(listener, reason)
				self.lblError:SetCaption(reason)
			end

			lobby:AddListener("OnAccepted",
				function(listener)
					local chatWindows = ChatWindows()
					self.window:Dispose()
					lobby:RemoveListener("OnAccepted", listener)
					lobby:RemoveListener("OnDenied", onDenied)
				end
			)

			lobby:AddListener("OnDenied", onDenied)
			
			local onAgreement = function(listener, line)
				if self.agreementText == nil then
					self.agreementText = ""
				end
				self.agreementText = self.agreementText .. line .. "\n"
			end
			lobby:AddListener("OnAgreement", onAgreement)

			lobby:AddListener("OnAgreementEnd", 
				function(listener)
					self:createAgreementWindow()
					lobby:RemoveListener("OnAgreementEnd", listener)
					lobby:RemoveListener("OnAgreement", onAgreement)
				end
			)

			lobby:Login(username, password, 3)
		end
	)

	lobby:Connect("springrts.com", "8200")
	--lobby:Connect("localhost", "8200")
end

function LoginWindow:createAgreementWindow()
	self.tbAgreement = TextBox:New {
		x = 1,
		right = 1,
		y = 1,
		height = "100%",
		text = self.agreementText,
	}
	self.btnYes = Button:New {
		x = 1,
		width = 80,
		bottom = 1,
		height = 40,
		caption = "Accept",
		OnClick = {
			function()
				self:acceptAgreement()
			end
		},
	}
	self.btnNo = Button:New {
		x = 150,
		width = 80,
		bottom = 1,
		height = 40,
		caption = "Decline",
		OnClick = {
			function()
				self:declineAgreement()
			end
		},
	}
	self.agreementWindow = Window:New {
		x = 600,
		y = 400,
		width = 350,
		height = 450,
		caption = "Use agreement",
		resizable = false,
		children = {
			ScrollPanel:New {
				x = 1,
				right = 7,
				y = 1,
				bottom = 42,
				children = {
					self.tbAgreement
				},
			},
			self.btnYes,
			self.btnNo,

		},
		parent = screen0,
	}
end

function LoginWindow:acceptAgreement()
	lobby:ConfirmAgreement()
	self.agreementWindow:Dispose()
end

function LoginWindow:declineAgreement()
	self.agreementWindow:Dispose()
end

