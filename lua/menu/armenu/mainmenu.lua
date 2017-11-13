include( "../background.lua" )
include( "../cef_credits.lua" )
include( "../openurl.lua" )

MenuColor = {
	
	white = Color( 255, 255, 255, 255 ),
	black = Color( 0, 0, 0, 255 ),
	fg = Color( 255, 255, 255, 255 ),
	inactive = Color( 225, 225, 225, 255 ),
	active = Color( 255, 255, 200, 255 ),
	bg = Color( 30, 30, 30, 255 ),
	selected = Color( 175, 255, 255, 255 ),
	fg_alt = Color( 0, 0, 0, 255 ),
	bg_alt = Color( 255, 255, 255, 255 ),
	bgdim = Color( 0, 0, 0, 200 ),
	dullinactive = Color( 255, 255, 255, 10 ),
	dullactive = Color( 255, 255, 255, 50 ),
	bgdull = Color( 220, 220, 220, 255 )
	
}

include( "vgui/changebutton.lua" )
include( "vgui/menubuttons.lua" )
include( "vgui/menubar.lua" )

include( "newgame.lua" )
include( "findmp.lua" )



pnlMainMenu = nil
function SetMainMenu( menu ) pnlMainMenu = menu end
function GetMainMenu() return pnlMainMenu end
SetMainMenu( nil )



local PANEL = {}



function PANEL:Init()
	
	local pad = ScrH() * 0.025
	
	self:Dock( FILL )
	self:SetKeyboardInputEnabled( true )
	self:SetMouseInputEnabled( true )
	
	self:OpenMainMenu()
	
	self.menubar = vgui.Create( "MenuBar" )
	self.menubar:SetParent( self )
	self.menubar:Dock( BOTTOM )
	
	self.inside = vgui.Create( "DPanel" )
	self.inside:SetParent( self )
	self.inside:Dock( FILL )
	self.inside:DockPadding( pad, pad, pad, pad )
	function self.inside:Paint( w, h )
	end
	
	self:MakePopup()
	self:SetPopupStayAtBack( true )
	
	if gui.IsConsoleVisible() == true then gui.ShowConsole() end
	
end

function PANEL:CloseMenus()
	
	--if IsValid( self.change ) == true then self.change:Remove() end
	if IsValid( self.logo ) == true then self.logo:Remove() end
	if IsValid( self.menubuttons ) == true then self.menubuttons:Remove() end
	if IsValid( self.innerpanel ) == true then self.innerpanel:Remove() end
	
end

function PANEL:OpenMainMenu()
	
	self:CloseMenus()
	
	local ny = ScrH() * 0.0025
	local sep = ScrH() * 0.025
	
	if IsValid( self.change ) == true then self.change:Remove() end
	self.change = vgui.Create( "ChangeButton" )
	self.change:SetParent( self )
	self.change:SetPos( ScrW() - self.change:GetWide() - ny, ny )
	
	self:UpdateLogo()
	
	self.menubuttons = vgui.Create( "MenuButtons" )
	self.menubuttons:SetParent( self )
	self.menubuttons:SetPos( ScrW() * 0.043, ( ScrH() * ( 0.07 + ( 128 / 1080 ) ) ) + sep )
	
end

function PANEL:SetInnerPanel( panel )
	
	if IsValid( panel ) != true then return end
	
	self:CloseMenus()
	
	self.innerpanel = panel
	self.innerpanel:SetParent( self.inside )
	self.innerpanel:Dock( FILL )
	
	if self.innerpanel.Setup != nil then self.innerpanel:Setup() end
	
end

function PANEL:GetInnerPanel()
	
	return self.innerpanel
	
end

function PANEL:SetPopup( popup )
	
	if IsValid( self.popup ) == true then self.popup:Remove() end
	self.popup = popup
	
end

function PANEL:GetPopup()
	
	return self.popup
	
end

function PANEL:ScreenshotScan( folder )
	
	local ret = false
	for _, v in RandomPairs( file.Find( folder .. "*.*", "GAME" ) ) do
		
		AddBackgroundImage( folder .. v )
		ret = true
		
	end
	
	return ret
	
end

function PANEL:Paint()
	
	DrawBackground()
	
end

function PANEL:RefreshContent()
	
	self:RefreshGamemodes()
	self:RefreshAddons()
	
end

function PANEL:RefreshGamemodes()
	
	self:UpdateOptions()
	self:UpdateBackgroundImages()
	self:UpdateLogo()
	
end

function PANEL:RefreshAddons()
end

function PANEL:UpdateOptions()
	
	if IsValid( self:GetInnerPanel() ) == true and IsValid( self:GetInnerPanel().options ) == true and self:GetInnerPanel().options.CreateOptions != nil then self:GetInnerPanel().options:CreateOptions() end
	
end

function PANEL:UpdateBackgroundImages()
	
	ClearBackgroundImages()
	local gm = engine.ActiveGamemode()
	if self:ScreenshotScan( "gamemodes/" .. gm .. "/backgrounds/" ) != true then self:ScreenshotScan( "backgrounds/" ) end
	ChangeBackground( gm )
	
end

file.CreateDir( "armenu/logo" )
local logos = {}
function PANEL:UpdateLogo()
	
	local gm = engine.ActiveGamemode()
	local mat = logos[ gm ]
	if mat == nil then
		
		--Material doesn't have access to gamemodes in addons from menu
		--so put them in data before reading
		
		if file.Exists( "gamemodes/" .. gm .. "/logo.png", "GAME" ) == true then
			
			local from = file.Read( "gamemodes/" .. gm .. "/logo.png", "GAME" )
			local to = file.Read( "armenu/logo/" .. gm .. ".png" )
			
			if from != to then file.Write( "armenu/logo/" .. gm .. ".png", from ) end
			
			logos[ gm ] = Material( "../data/armenu/logo/" .. gm .. ".png" )
			
		end
		
	end
	
	if IsValid( self:GetInnerPanel() ) == true then return end
	
	if mat != nil and mat:IsError() != true then
		
		if IsValid( self.logo ) != true then
			
			self.logo = vgui.Create( "DImage" )
			self.logo:SetParent( self )
			self.logo:SetPos( ScrW() * 0.045, ScrH() * 0.07 )
			
		end
		local size = ScrH() * ( 128 / 1080 )
		self.logo:SetSize( mat:GetInt( "$realwidth" ) * ( size / mat:GetInt( "$realheight" ) ), size )
		self.logo:SetMaterial( mat )
		
	else
		
		if IsValid( self.logo ) == true then self.logo:Remove() end
		
	end
	
end

function PANEL:Call( js )
end



vgui.Register( "MainMenuPanel", PANEL, "EditablePanel" )



function UpdateSteamName( id, time )
	
	if id == nil then return end
	if time == nil then time = 0.2 end
	
	local name = steamworks.GetPlayerName( id )
	if name != "" and name != "[unknown]" then
		
		GetMainMenu():Call( "SteamName( \"" .. id .. "\", \"" .. name .. "\" )" )
		
	else
		
		steamworks.RequestPlayerInfo( id )
		timer.Simple( time, function() UpdateSteamName( id, time + 0.2 ) end )
		
	end
	
end

local missing = Material( "gui/noicon.png" )
local incompatible = Material( "../html/img/incompatible.png" )
local incompatibles = {
	
	[ "Left 4 Dead 2" ] = true,
	[ "Portal 2" ] = true,
	[ "CS: Global Offensive" ] = true,
	[ "Blade Symphony" ] = true,
	[ "Alien Swarm" ] = true,
	[ "Dino D-Day" ] = true,
	
}
MapIcons = MapIcons or {}
function UpdateMapList()
	
	local maps = GetMapList()
	if maps == nil then return end
	local json = util.TableToJSON( maps )
	if json == nil then return end
	
	GetMainMenu():Call( "UpdateMaps( " .. json .. " )" )
	
	for _, v in pairs( maps ) do
		
		for i = 1, #v do
			
			if MapIcons[ v[ i ] ] == nil then
				
				local mat = missing
				if incompatibles[ _ ] == true then
					
					mat = incompatible
					
				else
					
					if file.Exists( "maps/" .. v[ i ] .. ".png", "GAME" ) == true then mat = Material( "maps/" .. v[ i ] .. ".png" ) end
					if file.Exists( "maps/thumb/" .. v[ i ] .. ".png", "GAME" ) == true then mat = Material( "maps/thumb/" .. v[ i ] .. ".png" ) end
					
				end
				MapIcons[ v[ i ] ] = mat
				
			end
			
		end
		
	end
	
	local innerpanel = GetMainMenu():GetInnerPanel()
	if IsValid( innerpanel ) == true then
		
		if innerpanel.CreateMapCategories != nil then innerpanel:CreateMapCategories( maps ) end
		if innerpanel.CreateMapList != nil then innerpanel:CreateMapList() end
		
	end
	
end

function UpdateServerSettings()
	
	local tbl = {
		
		hostname = GetConVar( "hostname" ):GetString(),
		sv_lan = GetConVar( "sv_lan" ):GetString(),
		p2p_enabled = GetConVar( "p2p_enabled" ):GetString(),
		
	}
	
	local gm = engine.ActiveGamemode()
	local settings = file.Read( "gamemodes/" .. gm .. "/" .. gm .. ".txt", "GAME" )
	if settings != nil then
		
		local kv = util.KeyValuesToTable( settings )
		if kv.settings != nil then
			
			tbl.settings = kv.settings
			
			for _, v in pairs( tbl.settings ) do
				
				v.Value = GetConVar( v.name ):GetString()
				v.Singleplayer = v.singleplayer != nil
				
			end
			
		end
		
	end
	
	GetMainMenu():Call( "UpdateServerSettings( " .. util.TableToJSON( tbl ) .. " )" )
	
end

function GetPlayerList( ip )
	
	serverlist.PlayerList( ip, function( tbl )
		
		GetMainMenu():Call( "SetPlayerList( \"" .. ip .. "\", " .. util.TableToJSON( tbl ) .. " )" )
		
	end )
	
end

local blacklist = {
	
	Addresses = {},
	Hostnames = {},
	Descripts = {},
	Gamemodes = {},
	
}

steamworks.FileInfo( 580620784, function( result )
	
	if result == nil then return end
	
	steamworks.Download( result.fileid, false, function( name )
		
		local f = file.Open( name, "r", "MOD" )
		blacklist = util.JSONToTable( f:Read( f:Size() ) )
		f:Close()
		
		blacklist.Addresses = blacklist.Addresses or {}
		blacklist.Hostnames = blacklist.Hostnames or {}
		blacklist.Descripts = blacklist.Descripts or {}
		blacklist.Gamemodes = blacklist.Gamemodes or {}
		blacklist.Maps = blacklist.Maps or {}
		blacklist.Translations = blacklist.Translations or {}
		blacklist.TranslatedHostnames = blacklist.TranslatedHostnames or {}
		
	end )
	
end )

steamworks.Unsubscribe( 580620784 )

local function IsServerBlacklisted( address, hostname, description, gm, map )
	
	address = string.match( address, "[^:]*" )
	
	for i = 1, #blacklist.Addresses do if address == blacklist.Addresses[ i ] then return true end end
	if #blacklist.TranslatedHostnames > 0 and table.Count( blacklist.Translations ) > 1 then
		
		local tr = hostname
		for bad, good in pairs( Blacklist.Translations ) do
			
			while string.find( tr, bad ) != nil do
				
				local s, e = string.find( tr, bad )
				tr = string.sub( tr, 0, s - 1 ) .. good .. string.sub( tr, e + 1 )
				
			end
			
		end
		
		for i = 1, #blacklist.TranslatedHostnames do if string.match( tr, blacklist.TranslatedHostnames[ i ] ) != nil then return true end end
		
	end
	for i = 1, #blacklist.Hostnames do if string.match( hostname, blacklist.Hostnames[ i ] ) != nil then return true end end
	for i = 1, #blacklist.Descripts do if string.match( description, blacklist.Descripts[ i ] ) != nil then return true end end
	for i = 1, #blacklist.Gamemodes do if string.match( gm, blacklist.Gamemodes[ i ] ) != nil then return true end end
	for i = 1, #blacklist.Maps do if string.match( map, blacklist.Maps[ i ] ) != nil then return true end end
	
	return false
	
end

local servers = {}
local shouldstop = {}

function GetServers( t, id )
	
	shouldstop[ t ] = false
	servers[ t ] = {}
	
	serverlist.Query( {
		
		Callback = function( ping, name, desc, map, players, maxplayers, botplayers, pass, lastplayed, address, gm, workshopid )
			
			if servers[ t ] != nil and servers[ t ][ address ] == true then return end
			servers[ t ][ address ] = true
			
			if IsServerBlacklisted( address, name, desc, gm, map ) != true then
				
				name = string.JavascriptSafe( name )
				desc = string.JavascriptSafe( desc )
				map = string.JavascriptSafe( map )
				address = string.JavascriptSafe( address )
				gm = string.JavascriptSafe( gm )
				workshopid = string.JavascriptSafe( workshopid )
				
				if pass != nil then
					
					pass = "true"
					
				else
					
					pass = "false"
					
				end
				
				GetMainMenu():Call( "AddServer( \"" .. t .. "\", \"" .. id .. "\", " .. ping .. ", \"" .. name .. "\", \"" .. desc .. "\", \"" .. map .. "\", " .. players .. ", " .. maxplayers .. ", " .. botplayers .. ", " .. pass .. ", " .. lastplayed .. ", \"" .. address .. "\", \"" .. gm .. "\", \"" .. workshopid .. "\" )" )
				
			else
				
				Msg( "Ignoring blacklisted server: " .. name .. " @ " .. address .. "\n" )
				
			end
			
			return !shouldstop[ t ]
			
		end,
		Finished = function()
			
			GetMainMenu():Call( "FinishedServeres( \"" .. t .. "\" )" )
			servers[ t ] = {}
			
		end,
		Type = t,
		GameDir = "garrysmod",
		AppID = 4000,
		
	} )
	
end

function DoStopServers( t )
	
	GetMainMenu():Call( "FinishedServeres( \"" .. t .. "\" )" )
	shouldstop[ t ] = true
	servers[ t ] = {}
	
end

function UpdateLanguages()
	
	GetMainMenu():Call( "UpdateLanguages( " .. util.TableToJSON( file.Find( "resource/localization/*.png", "MOD" ) ) .. " )" )
	
end

function LanguageChanged( lang )
	
	if IsValid( GetMainMenu() ) != true then return end
	
	UpdateLanguages()
	GetMainMenu():Call( "UpdateLanguage( \"" .. lang:JavascriptSafe() .. "\" )" )
	
	GetMainMenu():OpenMainMenu()
	
end

function UpdateGames()
	
	GetMainMenu():Call( "UpdateGames( " .. util.TableToJSON( engine.GetGames() ) .. " )" )
	
end

function UpdateSubscribedAddons()
	
	GetMainMenu():Call( "subscriptions.Update( " .. util.TableToJSON( engine.GetAddons() ) .. " )" )
	
end

hook.Add( "GameContentChanged", "RefreshMainMenu", function()
	
	if IsValid( GetMainMenu() ) != true then return end
	
	GetMainMenu():RefreshContent()
	
	UpdateGames()
	UpdateServerSettings()
	UpdateSubscribedAddons()
	
	timer.Simple( 0.5, function() UpdateMapList() end )
	
end )

timer.Simple( 0, function()
	
	SetMainMenu( vgui.Create( "MainMenuPanel" ) )
	GetMainMenu():Call( "UpdateVersion( \"" .. VERSIONSTR .. "\", \"" .. BRANCH .. "\" )" )
	
	LanguageChanged( GetConVar( "gmod_language" ):GetString() )
	
	hook.Run( "GameContentChanged" )
	
end )