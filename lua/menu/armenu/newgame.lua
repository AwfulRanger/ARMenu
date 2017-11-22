--TODO: make (un)favoriting a map not jitter everything around
--TODO: search bar
--TODO: fix leftover map panel (?????)
local PANEL = {}



language.Add( "armenu_maxplayers", "Max players" )

local favmat = Material( "../html/img/favourite.png" )
local addfavmat = Material( "../html/img/favourite_add.png" )
local remfavmat = Material( "../html/img/favourite_remove.png" )

local currentmap
local currentcat = "Favourites"

local maxplayers_help = "Change the maximum number of players allowed on this server."
local hostname_help = GetConVar( "hostname" ):GetHelpText()
local sv_lan_help = GetConVar( "sv_lan" ):GetHelpText()
local p2p_enabled_help = GetConVar( "p2p_enabled" ):GetHelpText()
local p2p_friendsonly_help = GetConVar( "p2p_friendsonly" ):GetHelpText()

gamemaxplayers = gamemaxplayers or 1
gamehostname = gamehostname or GetConVar( "hostname" ):GetString()
gamep2p = gamep2p or GetConVar( "p2p_enabled" ):GetInt()
gamefriends = gamefriends or GetConVar( "p2p_friendsonly" ):GetInt()
gamelan = gamelan or GetConVar( "sv_lan" ):GetInt()
gameoptions = gameoptions or {}
local function setoption( name, value )
	
	gameoptions[ name ] = value
	
	return gameoptions[ name ]
	
end
local function getoption( name, default )
	
	if gameoptions[ name ] == nil then return setoption( name, default ) end
	
	return gameoptions[ name ]
	
end

local function newcategory( name, tbl, parent )
	
	local num = 0
	if tbl != nil then num = #tbl end
	
	local button = vgui.Create( "DButton" )
	button:SetParent( parent )
	button:Dock( TOP )
	button:DockMargin( 0, 0, 0, ScrH() * 0.005 )
	button:SetText( "" )
	function button:Paint( w, h )
		
		local color = MenuColor.bgdull
		if self:IsHovered() == true then color = MenuColor.active end
		if currentcat == name then color = MenuColor.selected end
		draw.RoundedBox( 4, 0, 0, w, h, color )
		
		surface.SetFont( "DermaDefault" )
		local tw, th = surface.GetTextSize( name )
		local tpad = math.Round( h * 0.5 ) - math.Round( th * 0.5 )
		surface.SetTextPos( tpad, tpad )
		surface.SetTextColor( MenuColor.fg_alt )
		surface.DrawText( name )
		
		surface.SetFont( "DermaDefaultBold" )
		local nw, nh = surface.GetTextSize( num )
		local npad = math.Round( h * 0.5 ) - math.Round( nh * 0.5 )
		draw.RoundedBox( 4, w - nw - ( npad * 3 ), npad, nw + ( npad * 2 ), nh, MenuColor.fg )
		
		surface.SetTextPos( w - nw - ( npad * 2 ), npad )
		surface.DrawText( num )
		
	end
	function button:DoClick()
		
		parent:GetParent():CreateMapList( name )
		currentcat = name
		
	end
	
	return button
	
end

function PANEL:CreateMapCategories( maplist )
	
	if IsValid( self.category ) == true then self.category:Remove() end
	
	if maplist == nil then maplist = GetMapList() or {} end
	
	self.category = vgui.Create( "DScrollPanel" )
	self.category:SetParent( self )
	self.category:Dock( LEFT )
	self.category:SetWide( ScrW() * 0.125 )
	
	local fav = newcategory( "Favourites", maplist.Favourites, self.category )
	local sb = newcategory( "Sandbox", maplist.Sandbox, self.category )
	
	for _, v in SortedPairs( maplist ) do
		
		if _ != "Favourites" and _ != "Sandbox" then
			
			local cat = newcategory( _, v, self.category )
			
		end
		
	end
	
end

function PANEL:CreateMapList( category )
	
	if IsValid( self.maps ) == true then self.maps:Remove() end
	
	timer.Simple( 0, function()
		
		if IsValid( self ) != true then return end
		
		if category == nil then category = currentcat end
		if category == nil then category = "Favourites" end
		local maplist = GetMapList()[ category ] or {}
		
		self.maps = vgui.Create( "DScrollPanel" )
		self.maps:SetParent( self )
		self.maps:Dock( FILL )
		
		self:InvalidateParent( true )
		self.maps:InvalidateParent( true )
		
		local w = self.maps:GetWide()
		local sep = w * 0.02
		local pad = ScrH() * 0.01
		
		self.maps:DockMargin( sep, sep - pad, sep, sep - pad )
		
		local rows = 8
		local size = ( w * ( 0.97 / rows ) ) - sep
		
		for i = 1, #maplist do
			
			local row = ( i - 1 ) % rows
			local col = math.floor( ( i - 1 ) / rows )
			
			local x = ( size + sep ) * row
			local y = ( size + sep ) * col
			
			local mat = MapIcons[ maplist[ i ] ]
			
			local button = vgui.Create( "DButton" )
			button:SetParent( self.maps )
			button:SetText( "" )
			button:SetPos( x, y )
			button:SetSize( size, size )
			function button:Paint( w, h )
				
				local pad = math.Round( w * 0.05 )
				
				local color = MenuColor.bgdull
				if self:IsHovered() == true then color = MenuColor.active end
				if currentmap == maplist[ i ] then color = MenuColor.selected end
				draw.RoundedBox( 4, 0, 0, w, h, color )
				
				if mat != nil then
					
					surface.SetDrawColor( MenuColor.white )
					surface.SetMaterial( mat )
					surface.DrawTexturedRect( pad, pad, w - ( pad * 2 ), h - ( pad * 2 ) )
					
				end
				
			end
			function button:DoClick()
				
				currentmap = maplist[ i ]
				
			end
			
			local isfav = false
			for i_ = 1, #GetMapList().Favourites do
				
				if GetMapList().Favourites[ i_ ] == maplist[ i ] then
					
					isfav = true
					break
					
				end
				
			end
			
			local favbutton = vgui.Create( "DButton" )
			favbutton:SetParent( button )
			favbutton:SetPos( size - 16, 0 )
			favbutton:SetSize( 16, 16 )
			favbutton:SetText( "" )
			function favbutton:Paint( w, h )
				
				local mat = favmat
				if self:IsHovered() == true then
					
					if isfav != true then
						
						mat = addfavmat
						
					else
						
						mat = remfavmat
						
					end
					
				end
				surface.SetMaterial( mat )
				
				surface.SetDrawColor( MenuColor.white )
				surface.DrawTexturedRect( 0, 0, w, h )
				
			end
			function favbutton:DoClick()
				
				isfav = !isfav
				ToggleFavourite( maplist[ i ] )
				
			end
			
			local name = vgui.Create( "DLabel" )
			name:SetParent( self.maps )
			name:SetText( maplist[ i ] )
			name:SetPos( x, y + size )
			name:SetSize( size, sep )
			function name:Paint( w, h )
				
				surface.SetFont( self:GetFont() )
				surface.SetTextPos( ( w * 0.5 ) - ( surface.GetTextSize( self:GetText() ) * 0.5 ), 0 )
				surface.SetTextColor( MenuColor.fg_alt )
				surface.DrawText( self:GetText() )
				
				return true
				
			end
			
		end
		
	end )
	
end

function PANEL:CreateOptions()
	
	if IsValid( self.options ) == true then self.options:Remove() end
	
	local pad = ScrH() * 0.01
	
	local bgpanel = vgui.Create( "DPanel" )
	bgpanel:SetParent( self )
	bgpanel:Dock( RIGHT )
	bgpanel:SetWide( ScrW() * 0.125 )
	function bgpanel:Paint( w, h )
		
		draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bgdull )
		
	end
	
	local parent = self
	
	local startgame = vgui.Create( "DButton" )
	startgame:SetParent( bgpanel )
	startgame:Dock( BOTTOM )
	startgame:DockMargin( pad, pad, pad, pad )
	startgame:SetText( "" )
	startgame:SetTall( ScrH() * 0.05 )
	function startgame:Paint( w, h )
		
		local color = MenuColor.bg_alt
		if self:IsHovered() == true then color = MenuColor.active end
		if self:IsDown() == true then color = MenuColor.selected end
		draw.RoundedBox( 4, 0, 0, w, h, color )
		
		surface.SetFont( "DermaLarge" )
		local tw, th = surface.GetTextSize( "#start_game" )
		surface.SetTextPos( ( w * 0.5 ) - ( tw * 0.5 ), ( h * 0.5 ) - ( th * 0.5 ) )
		surface.SetTextColor( MenuColor.fg_alt )
		surface.DrawText( "#start_game" )
		
	end
	function startgame:DoClick()
		
		GetMainMenu():OpenMainMenu()
		
		SaveLastMap( currentmap, currentcat )
		
		hook.Run( "StartGame" )
		
		RunConsoleCommand( "progress_enable" )
		RunConsoleCommand( "disconnect" )
		RunConsoleCommand( "maxplayers", gamemaxplayers )
		
		RunConsoleCommand( "sv_cheats", "0" )
		RunConsoleCommand( "commentary", "0" )
		
		for _, v in pairs( gameoptions ) do
			
			RunConsoleCommand( _, v )
			
		end
		
		RunConsoleCommand( "hostname", gamehostname )
		RunConsoleCommand( "p2p_enabled", gamep2p )
		RunConsoleCommand( "p2p_friendsonly", gamefriends )
		RunConsoleCommand( "sv_lan", gamelan )
		RunConsoleCommand( "maxplayers", gamemaxplayers )
		RunConsoleCommand( "map", currentmap )
		RunConsoleCommand( "hostname", gamehostname )
		
	end
	
	self.options = vgui.Create( "DScrollPanel" )
	self.options:SetParent( bgpanel )
	self.options:Dock( FILL )
	self.options:SetWide( ScrW() * 0.125 )
	self.options:GetCanvas():DockPadding( pad, pad, pad, pad )
	
	local panel
	
	function self.options:CreateOptions()
		
		if IsValid( panel ) == true then panel:Remove() end
		
		local pad = ScrH() * 0.01
		
		panel = vgui.Create( "DPanel" )
		panel:SetParent( self )
		panel:Dock( FILL )
		function panel:Paint( w, h )
		end
		
		
		local maxplayers = vgui.Create( "DPanel" )
		maxplayers:SetParent( panel )
		maxplayers:Dock( TOP )
		maxplayers:DockMargin( 0, 0, 0, pad )
		maxplayers:SetTooltip( maxplayers_help )
		function maxplayers:Paint( w, h )
		end
		
		local mpdesc = vgui.Create( "DLabel" )
		mpdesc:SetParent( maxplayers )
		mpdesc:Dock( LEFT )
		mpdesc:SetText( "#server_players" )
		mpdesc:SetTextColor( MenuColor.fg_alt )
		mpdesc:SizeToContents()
		
		local mpwang = vgui.Create( "DNumberWang" )
		mpwang:SetParent( maxplayers )
		mpwang:Dock( RIGHT )
		mpwang:SetMin( 1 )
		mpwang:SetMax( 128 )
		mpwang:SetDecimals( 0 )
		mpwang:SetValue( gamemaxplayers )
		function mpwang.OnValueChanged( mpwang, value )
			
			local value_ = math.Round( math.Clamp( tonumber( value ) or 1, 1, 128 ) )
			
			local oldmp = gamemaxplayers
			gamemaxplayers = value_
			
			if ( oldmp == 1 and value_ != 1 ) or ( oldmp != 1 and value_ == 1 ) then self:CreateOptions() end
			
			if value != tostring( value_ ) then self:SetValue( value_ ) end
			
		end
		function mpwang:OnEnter()
			
			self:SetValue( gamemaxplayers )
			self:SetText( gamemaxplayers )
			
		end
		
		
		if gamemaxplayers > 1 then
			
			local servername = vgui.Create( "DPanel" )
			servername:SetParent( panel )
			servername:Dock( TOP )
			servername:DockMargin( 0, 0, 0, pad )
			servername:SetTooltip( hostname_help )
			function servername:Paint( w, h )
			end
			
			local sndesc = vgui.Create( "DLabel" )
			sndesc:SetParent( servername )
			sndesc:Dock( TOP )
			sndesc:SetText( "#server_name" )
			sndesc:SetTextColor( MenuColor.fg_alt )
			sndesc:SizeToContents()
			
			local snentry = vgui.Create( "DTextEntry" )
			snentry:SetParent( servername )
			snentry:Dock( FILL )
			snentry:SetValue( gamehostname )
			function snentry:OnValueChange( value )
				
				gamehostname = value
				
			end
			
			servername:SetTall( servername:GetTall() + sndesc:GetTall() )
			
			
			local lan = vgui.Create( "DCheckBoxLabel" )
			lan:SetParent( panel )
			lan:Dock( TOP )
			lan:DockMargin( 0, 0, 0, pad )
			lan:SetText( "#lan_server" )
			lan:SetTextColor( MenuColor.fg_alt )
			lan:SetTooltip( sv_lan_help )
			lan:SetValue( ( gamelan != 0 and true ) or false )
			function lan:OnChange( value )
				
				gamelan = ( value == false and 0 ) or 1
				
			end
			
			
			local p2p = vgui.Create( "DCheckBoxLabel" )
			p2p:SetParent( panel )
			p2p:Dock( TOP )
			p2p:DockMargin( 0, 0, 0, pad )
			p2p:SetText( "#p2p_server" )
			p2p:SetTextColor( MenuColor.fg_alt )
			p2p:SetTooltip( p2p_enabled_help )
			p2p:SetValue( ( gamep2p != 0 and true ) or false )
			function p2p:OnChange( value )
				
				gamep2p = ( value == false and 0 ) or 1
				
			end
			
			
			local friends = vgui.Create( "DCheckBoxLabel" )
			friends:SetParent( panel )
			friends:Dock( TOP )
			friends:DockMargin( 0, 0, 0, pad )
			friends:SetText( "#p2p_server_friendsonly" )
			friends:SetTextColor( MenuColor.fg_alt )
			friends:SetTooltip( p2p_friendsonly_help )
			friends:SetValue( ( gamefriends != 0 and true ) or false )
			function friends:OnChange( value )
				
				gamefriends = ( value == false and 0 ) or 1
				
			end
			
		end
		
		local separator = vgui.Create( "DPanel" )
		separator:SetParent( panel )
		separator:Dock( TOP )
		separator:DockMargin( 0, 0, 0, pad )
		function separator:Paint( w, h )
		end
		
		local gmoptions = file.Read( "gamemodes/" .. engine.ActiveGamemode() .. "/" .. engine.ActiveGamemode() .. ".txt", "GAME" )
		if gmoptions != nil then
			
			gmoptions = util.KeyValuesToTable( gmoptions )
			if gmoptions != nil and gmoptions.settings != nil then
				
				gmoptions = gmoptions.settings
				for i = 1, #gmoptions do
					
					local option = gmoptions[ i ]
					if option != nil and ( gamemaxplayers > 1 or option.singleplayer != nil ) then
						
						local t = string.lower( option.type or "" )
						if t == "checkbox" then
							
							local check = vgui.Create( "DCheckBoxLabel" )
							check:SetParent( panel )
							check:Dock( TOP )
							check:DockMargin( 0, 0, 0, pad )
							check:SetText( language.GetPhrase( option.text or "" ) )
							check:SetTextColor( MenuColor.fg_alt )
							if option.help != nil then check:SetTooltip( language.GetPhrase( option.help ) ) end
							local val = getoption( option.name, option.default )
							if val != nil then check:SetValue( ( val != 0 and true ) or false ) end
							function check:OnChange( value )
								
								if option.name != nil then setoption( option.name, ( value == false and 0 ) or 1 ) end
								
							end
							
						elseif t == "numeric" then
							
							local num = vgui.Create( "DPanel" )
							num:SetParent( panel )
							num:Dock( TOP )
							num:DockMargin( 0, 0, 0, pad )
							if option.help != nil then num:SetTooltip( language.GetPhrase( option.help ) ) end
							function num:Paint( w, h )
							end
							
							local desc = vgui.Create( "DLabel" )
							desc:SetParent( num )
							desc:Dock( LEFT )
							desc:SetText( language.GetPhrase( option.text or "" ) )
							desc:SetTextColor( MenuColor.fg_alt )
							desc:SizeToContents()
							
							local wang = vgui.Create( "DNumberWang" )
							wang:SetParent( num )
							wang:Dock( RIGHT )
							wang:SetMin( -1000000 )
							wang:SetMax( 1000000 )
							local val = getoption( option.name, option.default )
							if val then wang:SetValue( val ) end
							function wang:OnValueChanged( value )
								
								if option.name != nil then setoption( option.name, value ) end
								
							end
							
						else
							
							local text = vgui.Create( "DPanel" )
							text:SetParent( panel )
							text:Dock( TOP )
							text:DockMargin( 0, 0, 0, pad )
							if option.help != nil then text:SetTooltip( language.GetPhrase( option.help ) ) end
							function text:Paint( w, h )
							end
							
							local desc = vgui.Create( "DLabel" )
							desc:SetParent( text )
							desc:Dock( TOP )
							desc:SetText( language.GetPhrase( option.text or "" ) )
							desc:SetTextColor( MenuColor.fg_alt )
							desc:SizeToContents()
							
							local entry = vgui.Create( "DTextEntry" )
							entry:SetParent( text )
							entry:Dock( FILL )
							local val = getoption( option.name, option.default )
							if val != nil then entry:SetValue( val ) end
							function entry:OnValueChange( value )
								
								if option.name != nil then setoption( option.name, value ) end
								
							end
							
							text:SetTall( text:GetTall() + desc:GetTall() )
							
						end
						
					end
					
				end
				
			end
			
		end
		
		self:SetTall( 0 )
		panel:InvalidateParent( true )
		panel:InvalidateLayout( true )
		panel:SizeToChildren( false, true )
		
	end
	
	self.options:CreateOptions()
	
end

function PANEL:MenuSetup()
	
	currentmap = game.GetMap()
	
	local pad = ScrH() * 0.01
	self:DockPadding( pad, pad, pad, pad )
	
	self:CreateMapCategories()
	self:CreateOptions()
	self:CreateMapList()
	
end

function PANEL:Paint( w, h )
	
	draw.RoundedBox( 8, 0, 0, w, h, MenuColor.bg_alt )
	
end



vgui.Register( "MainMenu_NewGame", PANEL, "EditablePanel" )