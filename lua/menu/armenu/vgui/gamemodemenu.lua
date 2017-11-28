local PANEL = {}



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
			
			gamemodeicons[ i ] = Material( "data/armenu/icon24/" .. name .. ".png" )
			
		end
		
	end
	
	return gms, names
	
end
local gamemodes, gamemodenames = dogamemodes()

function PANEL:Init()
	
	local pad = ScrH() * 0.005
	
	local scroll = vgui.Create( "DScrollPanel" )
	scroll:SetParent( self )
	scroll:Dock( FILL )
	
	local bgpanel = vgui.Create( "DPanel" )
	bgpanel:SetParent( scroll )
	bgpanel:Dock( FILL )
	function bgpanel:Paint( w, h )
	end
	
	gamemodes, gamemodenames = dogamemodes()
	for i = 1, #gamemodes do
		
		if gamemodes[ i ].menusystem == true then
			
			local button = vgui.Create( "SoundButton" )
			button:SetParent( bgpanel )
			button:Dock( TOP )
			button:DockMargin( pad, pad, pad, 0 )
			button:SetTall( ScrH() * 0.04 )
			button:SetText( "" )
			local tip = gamemodes[ i ].name
			if gamemodes[ i ].workshopid != "" then tip = tip .. " (" .. gamemodes[ i ].workshopid .. ")" end
			button:SetTooltip( tip )
			function button:Paint( w, h )
				
				local spad = math.Round( h * 0.1 )
				local s = math.min( 32, h - ( spad * 2 ) )
				local hpad = ( h * 0.5 ) - ( s * 0.5 )
				
				local color = MenuColor.bg_alt
				if self:IsHovered() == true then color = MenuColor.active end
				if engine.ActiveGamemode() == gamemodes[ i ].name then color = MenuColor.selected end
				draw.RoundedBox( 4, 0, 0, w, h, color )
				
				local mat = gamemodeicons[ i ]
				if mat != nil and mat:IsError() != true then
					
					surface.SetDrawColor( MenuColor.white )
					surface.SetMaterial( mat )
					surface.DrawTexturedRect( hpad, hpad, s, s )
					
				end
				
				surface.SetFont( self:GetFont() )
				local tw, th = surface.GetTextSize( gamemodes[ i ].title )
				surface.SetTextPos( s + ( hpad * 2 ), ( h * 0.5 ) - ( th * 0.5 ) )
				surface.SetTextColor( MenuColor.fg_alt )
				surface.DrawText( gamemodes[ i ].title )
				
			end
			function button:DoClick()
				
				self:DoClickSound()
				
				RunConsoleCommand( "gamemode", gamemodes[ i ].name )
				GetMainMenu():SetPopup( nil )
				
			end
			
		end
		
	end
	
	bgpanel:InvalidateLayout( true )
	bgpanel:SizeToChildren( false, true )
	bgpanel:SetTall( bgpanel:GetTall() + pad )
	
end

function PANEL:Paint( w, h )
	
	draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bgdim )
	
end



vgui.Register( "GamemodeMenu", PANEL, "DPanel" )