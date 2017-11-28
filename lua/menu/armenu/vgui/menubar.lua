local PANEL = {}



language.Add( "armenu_notinstalled", "Not installed" )
language.Add( "armenu_notowned", "Not owned" )
language.Add( "armenu_unmounted", "Unmounted" )
language.Add( "armenu_mounted", "Mounted" )

include( "menubarbutton.lua" )
include( "languagemenu.lua" )
include( "mountmenu.lua" )
include( "gamemodemenu.lua" )

local files = file.Find( "resource/localization/*.png", "MOD" )
local languages = {}
for i = 1, #files do languages[ string.lower( string.Left( files[ i ], #files[ i ] - 4 ) ) ] = Material( "resource/localization/" .. files[ i ] ) end

local mountmat = Material( "html/img/games.png" )

file.CreateDir( "armenu/icon24" )
local gamemodeicons = {}
local dogamemodes = function()
	
	local gms = engine.GetGamemodes()
	local names = {}
	table.SortByMember( gms, "title", true )
	for i = 1, #gms do
		
		local name = gms[ i ].name
		
		names[ name ] = i
		
		--Material doesn't have access to gamemodes in addons from menu
		--so put them in data before reading
		if file.Exists( "gamemodes/" .. name .. "/icon24.png", "GAME" ) == true then
			
			local from = file.Read( "gamemodes/" .. name .. "/icon24.png", "GAME" )
			local to = file.Read( "armenu/icon24/" .. name .. ".png" )
			
			if from != to then file.Write( "armenu/icon24/" .. name .. ".png", from ) end
			
			gamemodeicons[ i ] = Material( "../data/armenu/icon24/" .. name .. ".png" )
			
		end
		
	end
	
	return gms, names
	
end
local gamemodes, gamemodenames = dogamemodes()



local menubarbuttons = {}

function GetMenuBar()
	
	local menu = GetMainMenu()
	if IsValid( menu ) == true then return menu.menubar end
	
end

function AddMenuBarButton( button, pos )
	
	table.insert( menubarbuttons, { button = button, pos = pos } )
	
end



local function createbuttons( canvas )
	
	for i = 1, #menubarbuttons do
		
		if IsValid( menubarbuttons[ i ] ) == true then menubarbuttons[ i ]:Remove() end
		menubarbuttons[ i ] = nil
		
	end
	for i = 1, #canvas:GetChildren() do
		
		if IsValid( canvas:GetChildren()[ i ] ) == true then canvas:GetChildren()[ i ]:Remove() end
		
	end
	
	local pad = math.Round( ScrH() * 0.005 )
	local size = math.Round( ScrH() * 0.02 )
	local sep = math.Round( size * 0.25 )
	
	hook.Run( "PreCreateMenuBarButtons", menubarbuttons )
	
	
	if IsInGame() == true then
	
		local resume = vgui.Create( "MenuBarButton" )
		resume:DockMargin( 0, 0, pad, 0 )
		resume:SetSize( ScrW() * 0.1, ScrH() * 0.04 )
		resume:SetText( "#back_to_game" )
		resume:SetImage( "../../html/img/back_to_game.png" )
		function resume:DoClick()
			
			self:DoClickSound()
			
			gui.HideGameUI()
			
		end
		resume.ClickSound = resume.ReturnSound
		AddMenuBarButton( resume, -1000 )
		
	end
	
	
	if IsValid( GetMainMenu() ) == true and IsValid( GetMainMenu():GetInnerPanel() ) == true then
		
		local back = vgui.Create( "MenuBarButton" )
		back:SetWide( ScrW() * 0.1 )
		back:SetText( "#back_to_main_menu" )
		back:SetImage( "../../html/img/back_to_main_menu.png" )
		function back:DoClick()
			
			self:DoClickSound()
			
			GetMainMenu():OpenMainMenu()
			
		end
		back.ClickSound = back.ReturnSound
		AddMenuBarButton( back, -900 )
		
	end
	
	
	local lang = vgui.Create( "MenuBarButton" )
	lang:SetWide( lang:GetTall() )
	lang:DockMargin( pad, 0, 0, 0 )
	lang:SetText( "" )
	function lang:PerformLayout( w, h )
		
		self:SetWide( h )
		
	end
	local langpaint = lang.Paint
	function lang:Paint( w, h, ... )
		
		langpaint( self, w, h, ... )
		
		local lan = string.lower( GetConVar( "gmod_language" ):GetString() )
		if languages[ lan ] == nil then lan = "en" end
		
		local s = math.min( 16, w, h )
		
		surface.SetDrawColor( MenuColor.black )
		surface.DrawRect( ( w * 0.5 ) - ( s * 0.5 ) - 1, ( h * 0.5 ) - ( ( s * 0.5 ) * ( 11 / 16 ) ) - 1, s + 2, ( s * ( 11 / 16 ) ) + 2 )
		
		surface.SetDrawColor( MenuColor.white )
		surface.SetMaterial( languages[ lan ] )
		surface.DrawTexturedRect( ( w * 0.5 ) - ( s * 0.5 ), ( h * 0.5 ) - ( ( s * 0.5 ) * ( 11 / 16 ) ), s, s * ( 11 / 16 ) )
		
	end
	function lang:DoClick()
		
		if IsValid( self.popup ) == true then
			
			self:DoClickSound( self.ReturnSound )
			
			self.popup:Remove()
			
		else
			
			self:DoClickSound()
			
			self.popup = vgui.Create( "LanguageMenu" )
			self.popup:SetParent( GetMainMenu() )
			
			local x, y = self:GetPos()
			local bx, by = self:GetParent():GetPos()
			x = bx + x + self:GetWide() - self.popup:GetWide() - ( size * 0.5 ) - sep
			y = by - self.popup:GetTall() - ( size * 0.5 ) - sep
			self.popup:SetPos( x, y )
			
			GetMainMenu():SetPopup( self.popup )
			
		end
		
	end
	AddMenuBarButton( lang, 900 )
	
	
	local mount = vgui.Create( "MenuBarButton" )
	mount:SetWide( mount:GetTall() )
	mount:DockMargin( pad, 0, 0, 0 )
	mount:SetText( "" )
	function mount:PerformLayout( w, h )
		
		self:SetWide( h )
		
	end
	local mountpaint = mount.Paint
	function mount:Paint( w, h, ... )
		
		mountpaint( self, w, h, ... )
		
		local s = math.min( 16, w * 0.4, h * 0.4 )
		
		surface.SetDrawColor( MenuColor.white )
		surface.SetMaterial( mountmat )
		surface.DrawTexturedRect( ( w * 0.5 ) - ( s * 0.5 ), ( h * 0.5 ) - ( s * 0.5 ), s, s )
		
	end
	function mount:DoClick()
		
		if IsValid( self.popup ) == true then
			
			self:DoClickSound( self.ReturnSound )
			
			self.popup:Remove()
			
		else
			
			self:DoClickSound()
			
			self.popup = vgui.Create( "MountMenu" )
			self.popup:SetParent( GetMainMenu() )
			self.popup:SetSize( ScrW() * 0.15, ScrH() * 0.3 )
			
			local x, y = self:GetPos()
			local bx, by = self:GetParent():GetPos()
			x = bx + x + self:GetWide() - self.popup:GetWide() - ( size * 0.5 ) - sep
			y = by - self.popup:GetTall() - ( size * 0.5 ) - sep
			self.popup:SetPos( x, y )
			
			GetMainMenu():SetPopup( self.popup )
			
		end
		
	end
	AddMenuBarButton( mount, 800 )
	
	
	local gms = vgui.Create( "MenuBarButton" )
	gms:SetWide( gms:GetTall() )
	gms:DockMargin( pad, 0, 0, 0 )
	gms:SetText( "" )
	local gmspaint = gms.Paint
	function gms:Paint( w, h, ... )
		
		gmspaint( self, w, h, ... )
		
		local s = math.min( 32, math.Round( h * 0.8 ) )
		local spad = math.Round( ( h - s ) * 0.5 )
		local hpad = math.Round( h * 0.5 ) - math.Round( s * 0.5 )
		
		local gm = engine.ActiveGamemode()
		
		local mat = gamemodeicons[ gamemodenames[ gm ] ]
		if mat != nil and mat:IsError() != true then
			
			surface.SetDrawColor( MenuColor.white )
			surface.SetMaterial( mat )
			surface.DrawTexturedRect( spad, spad, s, s )
			
		end
		
		local bw = s + ( spad * 2 )
		
		local name = gamemodes[ gamemodenames[ gm ] ]
		if name != nil and name.title != nil then
			
			surface.SetFont( self:GetFont() )
			local tw, th = surface.GetTextSize( name.title )
			surface.SetTextPos( bw, ( h * 0.5 ) - ( th * 0.5 ) )
			surface.SetTextColor( self:GetColor() )
			surface.DrawText( name.title )
			
			bw = ( bw * 2 ) + tw
			
		end
		
		if w != bw then self:SetWide( bw ) end
		
	end
	function gms:DoClick()
		
		if IsValid( self.popup ) == true then
			
			self:DoClickSound( self.ReturnSound )
			
			self.popup:Remove()
			
		else
			
			self:DoClickSound()
			
			local size = math.Round( ScrH() * 0.02 )
			local sep = math.Round( size * 0.5 )
			local pad = math.Round( size * 0.25 )
			
			self.popup = vgui.Create( "GamemodeMenu" )
			self.popup.owner = self
			self.popup:SetParent( GetMainMenu() )
			self.popup:SetSize( ScrW() * 0.15, ScrH() * 0.3 )
			
			local x, y = self:GetPos()
			local bx, by = self:GetParent():GetPos()
			x = bx + x + self:GetWide() - self.popup:GetWide() - ( size * 0.5 ) - sep
			y = by - self.popup:GetTall() - ( size * 0.5 ) - sep
			self.popup:SetPos( x, y )
			
			GetMainMenu():SetPopup( self.popup )
			
		end
		
	end
	AddMenuBarButton( gms, 700 )
	
	
	hook.Run( "PostCreateMenuBarButtons", menubarbuttons )
	
	return menubarbuttons
	
end



function PANEL:CreateChildren()
	
	local lx = ScrH() * 0.005
	local rx = ScrH() * 0.005
	local buttons = createbuttons( self )
	for _, v in SortedPairsByMemberValue( buttons, "pos" ) do
		
		if v.pos < 0 then
			
			v.button:SetParent( self )
			v.button:Dock( LEFT )
			v.button:InvalidateLayout( true )
			--v.button:SetPos( lx, 0 )
			if v.button.MenuSetup != nil then v.button:MenuSetup( self ) end
			
			local dl, dt, dr, db = v.button:GetDockMargin()
			lx = lx + v.button:GetWide() + dr
			
		else
			
			break
			
		end
		
	end
	for _, v in SortedPairsByMemberValue( buttons, "pos", true ) do
		
		if v.pos >= 0 then
			
			v.button:SetParent( self )
			v.button:Dock( RIGHT )
			v.button:InvalidateLayout( true )
			---v.button:SetPos( ScrW() - rx - v.button:GetWide(), 0 )
			if v.button.MenuSetup != nil then v.button:MenuSetup( self ) end
			
			local dl, dt, dr, db = v.button:GetDockMargin()
			rx = rx + v.button:GetWide() + dl
			
		else
			
			break
			
		end
		
	end
	
end

function PANEL:Init()
	
	local pad = ScrH() * 0.005
	self:DockPadding( pad, pad, pad, pad )
	self:SetTall( ( ScrH() * 0.04 ) + ( pad * 2 ) )
	self:CreateChildren()
	
end

local barcolor = Color( 0, 0, 0, 200 )
function PANEL:Paint( w, h )
	
	surface.SetDrawColor( barcolor )
	surface.DrawRect( 0, 0, w, h )
	
	if self.LastIsInGame == nil then self.LastIsInGame = IsInGame() end
	if self.LastIsInGame != IsInGame() then
		
		self:CreateChildren()
		self.LastIsInGame = IsInGame()
		
	end
	local valid = IsValid( GetMainMenu() ) == true and IsValid( GetMainMenu():GetInnerPanel() ) == true
	if self.LastInnerPanel == nil then self.LastInnerPanel = valid end
	if self.LastInnerPanel != valid then
		
		self:CreateChildren()
		self.LastInnerPanel = valid
		
	end
	
end



vgui.Register( "MenuBar", PANEL, "DPanel" )