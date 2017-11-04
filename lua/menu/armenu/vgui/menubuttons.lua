--TODO: addons, demos and saves
--TODO: proper server browser
local PANEL = {}



include( "mainmenubutton.lua" )
include( "button_resume.lua" )
include( "button_newgame.lua" )
include( "button_findmp.lua" )
include( "button_addons.lua" )
include( "button_demos.lua" )
include( "button_saves.lua" )
include( "button_achievements.lua" )
include( "button_options.lua" )
include( "button_disconnect.lua" )
include( "button_quit.lua" )

function PANEL:CreateChildren()
	
	local ny = 0
	local sep = ScrH() * 0.025
	local y = 0
	
	if IsValid( self.resume ) == true then self.resume:Remove() end
	if IsInGame() == true then
		
		self.resume = vgui.Create( "Button_Resume" )
		self.resume:SetParent( self )
		self.resume:SetPos( 0, y )
		
		y = y + self.resume:GetTall() + sep
		
	end
	
	if IsValid( self.newgame ) == true then self.newgame:Remove() end
	self.newgame = vgui.Create( "Button_NewGame" )
	self.newgame:SetParent( self )
	self.newgame:SetPos( 0, y )
	
	y = y + self.newgame:GetTall() + ny
	
	if IsValid( self.findmp ) == true then self.findmp:Remove() end
	self.findmp = vgui.Create( "Button_FindMP" )
	self.findmp:SetParent( self )
	self.findmp:SetPos( 0, y )
	
	y = y + self.findmp:GetTall() + sep
	
	--[[
	if IsValid( self.addons ) == true then self.addons:Remove() end
	self.addons = vgui.Create( "Button_Addons" )
	self.addons:SetParent( self )
	self.addons:SetPos( 0, y )
	
	y = y + self.addons:GetTall() + ny
	
	if IsValid( self.demos ) == true then self.demos:Remove() end
	self.demos = vgui.Create( "Button_Demos" )
	self.demos:SetParent( self )
	self.demos:SetPos( 0, y )
	
	y = y + self.demos:GetTall() + ny
	
	if IsValid( self.saves ) == true then self.saves:Remove() end
	self.saves = vgui.Create( "Button_Saves" )
	self.saves:SetParent( self )
	self.saves:SetPos( 0, y )
	
	y = y + self.saves:GetTall() + sep
	]]--
	
	if IsValid( self.achievements ) == true then self.achievements:Remove() end
	self.achievements = vgui.Create( "Button_Achievements" )
	self.achievements:SetParent( self )
	self.achievements:SetPos( 0, y )
	
	y = y + self.achievements:GetTall() + ny
	
	if IsValid( self.options ) == true then self.options:Remove() end
	self.options = vgui.Create( "Button_Options" )
	self.options:SetParent( self )
	self.options:SetPos( 0, y )
	
	y = y + self.options:GetTall() + sep
	
	if IsValid( self.disconnect ) == true then self.disconnect:Remove() end
	if IsInGame() == true then
		
		self.disconnect = vgui.Create( "Button_Disconnect" )
		self.disconnect:SetParent( self )
		self.disconnect:SetPos( 0, y )
		
		y = y + self.disconnect:GetTall() + ny
		
	end
	
	if IsValid( self.quit ) == true then self.quit:Remove() end
	self.quit = vgui.Create( "Button_Quit" )
	self.quit:SetParent( self )
	self.quit:SetPos( 0, y )
	
	self:SizeToChildren( true, true )
	
end

function PANEL:Init()
	
	self:CreateChildren()
	
end

function PANEL:Paint( w, h )
	
	if self.LastIsInGame == nil then self.LastIsInGame = IsInGame() end
	if self.LastIsInGame != IsInGame() then
		
		self:CreateChildren()
		self.LastIsInGame = IsInGame()
		
	end
	
end



vgui.Register( "MenuButtons", PANEL, "DPanel" )