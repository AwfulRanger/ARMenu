--TODO: return to game button
local PANEL = {}



language.Add( "armenu_notinstalled", "Not installed" )
language.Add( "armenu_notowned", "Not owned" )
language.Add( "armenu_unmounted", "Unmounted" )
language.Add( "armenu_mounted", "Mounted" )

local files = file.Find( "resource/localization/*.png", "MOD" )
local languages = {}
for i = 1, #files do languages[ string.lower( string.Left( files[ i ], #files[ i ] - 4 ) ) ] = Material( "resource/localization/" .. files[ i ] ) end

local mountmat = Material( "../../html/img/games.png" )
local notinstalled = Material( "../../html/img/notinstalled.png" )
local notowned = Material( "../../html/img/notowned.png" )
local checkmat = Material( "../../html/img/enabled.png" )

local gameicons = {}
local games = engine.GetGames()
table.SortByMember( games, "title", true )
for i = 1, #games do gameicons[ i ] = Material( "games/16/" .. games[ i ].folder .. ".png" ) end

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

function PANEL:CreateBack()
	
	self.back = vgui.Create( "DButton" )
	self.back:SetParent( self )
	self.back:Dock( LEFT )
	self.back:SetSize( ScrW() * 0.1, ScrH() * 0.04 )
	self.back:SetText( "#back_to_main_menu" )
	self.back:SetImage( "../../html/img/back_to_main_menu.png" )
	function self.back:Paint( w, h )
		
		local color = MenuColor.bg_alt
		if self:IsHovered() == true then color = MenuColor.active end
		draw.RoundedBox( 4, 0, 0, w, h, color )
		
	end
	function self.back:DoClick()
		
		GetMainMenu():OpenMainMenu()
		
	end
	
end

function PANEL:CreateChildren()
	
	local pad = ScrH() * 0.005
	
	if IsValid( self.languages ) == true then self.languages:Remove() end
	self.languages = vgui.Create( "DButton" )
	self.languages:SetParent( self )
	self.languages:Dock( RIGHT )
	self.languages:DockMargin( pad, 0, 0, 0 )
	self.languages:SetSize( ScrH() * 0.04, ScrH() * 0.04 )
	self.languages:SetText( "" )
	function self.languages:Paint( w, h )
		
		local lan = string.lower( GetConVar( "gmod_language" ):GetString() )
		if languages[ lan ] == nil then lan = "en" end
		
		local color = MenuColor.bg_alt
		if self:IsHovered() == true then color = MenuColor.active end
		if self:IsDown() == true then color = MenuColor.selected end
		draw.RoundedBox( 4, 0, 0, w, h, color )
		
		local s = math.min( 16, w, h )
		
		surface.SetDrawColor( MenuColor.black )
		surface.DrawRect( ( w * 0.5 ) - ( s * 0.5 ) - 1, ( h * 0.5 ) - ( ( s * 0.5 ) * ( 11 / 16 ) ) - 1, s + 2, ( s * ( 11 / 16 ) ) + 2 )
		
		surface.SetDrawColor( MenuColor.white )
		surface.SetMaterial( languages[ lan ] )
		surface.DrawTexturedRect( ( w * 0.5 ) - ( s * 0.5 ), ( h * 0.5 ) - ( ( s * 0.5 ) * ( 11 / 16 ) ), s, s * ( 11 / 16 ) )
		
	end
	function self.languages:DoClick()
		
		if IsValid( self.popup ) == true then
			
			self.popup:Remove()
			
		else
			
			local size = math.Round( ScrH() * 0.02 )
			local sep = math.Round( size * 0.25 )
			
			self.popup = vgui.Create( "DPanel" )
			self.popup:SetParent( GetMainMenu() )
			
			local i = 0
			for _, v in pairs( languages ) do
				
				i = i + 1
				
				local line = math.ceil( i / ( #files * 0.25 ) ) - 1
				local col = i - ( ( #files * 0.25 ) * line ) - 1
				
				local button = vgui.Create( "DButton" )
				button:SetParent( self.popup )
				button:SetText( "" )
				button:SetPos( ( size * col ) + ( sep * ( col + 1 ) ), ( size * ( line ) ) + ( sep * ( line + 1 ) ) )
				button:SetSize( size, size )
				function button:Paint( w, h )
					
					local lan = string.lower( GetConVar( "gmod_language" ):GetString() )
					if languages[ lan ] == nil then lan = "en" end
					
					local color = MenuColor.bg_alt
					if self:IsHovered() == true then color = MenuColor.active end
					if _ == lan then color = MenuColor.selected end
					draw.RoundedBox( 4, 0, 0, w, h, color )
					
					local s = math.min( 16, w, h )
					
					surface.SetDrawColor( MenuColor.black )
					surface.DrawRect( ( w * 0.5 ) - ( s * 0.5 ) - 1, ( h * 0.5 ) - ( ( s * 0.5 ) * ( 11 / 16 ) ) - 1, s + 2, ( s * ( 11 / 16 ) ) + 2 )
					
					surface.SetDrawColor( MenuColor.white )
					surface.SetMaterial( v )
					surface.DrawTexturedRect( ( w * 0.5 ) - ( s * 0.5 ), ( h * 0.5 ) - ( ( s * 0.5 ) * ( 11 / 16 ) ), s, s * ( 11 / 16 ) )
					
				end
				function button:DoClick()
					
					RunConsoleCommand( "gmod_language", _ )
					GetMainMenu():SetPopup( nil )
					
				end
				
			end
			
			self.popup:SizeToChildren( true, true )
			local x, y = self:GetPos()
			local bx, by = self:GetParent():GetPos()
			x = bx + x + self:GetWide() - self.popup:GetWide() - ( size * 0.5 ) - sep
			y = by - self.popup:GetTall() - ( size * 0.5 ) - sep
			self.popup:SetPos( x, y )
			self.popup:SetSize( self.popup:GetWide() + sep, self.popup:GetTall() + sep )
			function self.popup:Paint( w, h )
				
				draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bgdim )
				
			end
			
			GetMainMenu():SetPopup( self.popup )
			
		end
		
	end
	
	if IsValid( self.mounted ) == true then self.mounted:Remove() end
	self.mounted = vgui.Create( "DButton" )
	self.mounted:SetParent( self )
	self.mounted:Dock( RIGHT )
	self.mounted:DockMargin( pad, 0, 0, 0 )
	self.mounted:SetSize( ScrH() * 0.04, ScrH() * 0.04 )
	self.mounted:SetText( "" )
	function self.mounted:Paint( w, h )
		
		local color = MenuColor.bg_alt
		if self:IsHovered() == true then color = MenuColor.active end
		if self:IsDown() == true then color = MenuColor.selected end
		draw.RoundedBox( 4, 0, 0, w, h, color )
		
		surface.SetDrawColor( MenuColor.white )
		surface.SetMaterial( mountmat )
		local w_ = math.Round( w * 0.4 )
		local h_ = math.Round( h * 0.4 )
		surface.DrawTexturedRect( ( w * 0.5 ) - ( w_ * 0.5 ), ( h * 0.5 ) - ( h_ * 0.5 ), w_, h_ )
		
	end
	function self.mounted:DoClick()
		
		if IsValid( self.popup ) == true then
			
			self.popup:Remove()
			
		else
			
			local size = math.Round( ScrH() * 0.02 )
			local sep = math.Round( size * 0.5 )
			local pad = math.Round( size * 0.25 )
			
			self.popup = vgui.Create( "DPanel" )
			self.popup:SetParent( GetMainMenu() )
			self.popup:SetSize( ScrW() * 0.15, ScrH() * 0.3 )
			local x, y = self:GetPos()
			local bx, by = self:GetParent():GetPos()
			x = bx + x + self:GetWide() - self.popup:GetWide() - ( size * 0.5 )
			y = by - self.popup:GetTall() - ( size * 0.5 )
			self.popup:SetPos( x, y )
			function self.popup:Paint( w, h )
				
				--draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bgdim )
				surface.SetDrawColor( MenuColor.bgdim )
				surface.DrawRect( 0, 0, w, h )
				
			end
			
			local scroll = vgui.Create( "DScrollPanel" )
			scroll:SetParent( self.popup )
			scroll:Dock( FILL )
			
			local bgpanel = vgui.Create( "DPanel" )
			bgpanel:SetParent( scroll )
			bgpanel:Dock( FILL )
			function bgpanel:Paint( w, h )
			end
			
			local games = engine.GetGames()
			table.SortByMember( games, "title", true )
			for i = 1, #games do
				
				local panel = vgui.Create( "DPanel" )
				panel:SetParent( bgpanel )
				panel:Dock( TOP )
				panel:DockMargin( pad, pad, pad, 0 )
				panel:SetTall( ScrH() * 0.025 )
				panel:SetTooltip( games[ i ].folder .. " (" .. games[ i ].depot .. ")" )
				function panel:Paint( w, h )
					
					draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bg_alt )
					
				end
				
				local image
				if games[ i ].installed != true then image = notinstalled end
				if games[ i ].owned != true then image = notowned end
				
				local spad = math.Round( panel:GetTall() * 0.1 )
				local s = math.min( 16, panel:GetTall() - ( spad * 2 ) )
				local hpad = ( panel:GetTall() * 0.5 ) - ( s * 0.5 )
				local psize = panel:GetTall() - ( spad * 2 )
				if image == nil then
					
					local check = vgui.Create( "DCheckBox" )
					check:SetParent( panel )
					check:Dock( LEFT )
					check:DockMargin( spad, spad, spad, spad )
					check:SetSize( psize, psize )
					check:SetChecked( games[ i ].mounted )
					local tip = "#armenu_unmounted"
					if games[ i ].mounted == true then tip = "#armenu_mounted" end
					check:SetTooltip( tip )
					function check:OnChange( new )
						
						engine.SetMounted( games[ i ].depot, new )
						
						local tip = "#armenu_unmounted"
						if new == true then tip = "#armenu_mounted" end
						self:SetTooltip( tip )
						
					end
					function check:Paint( w, h )
						
						surface.SetDrawColor( MenuColor.fg_alt )
						surface.DrawRect( 0, 0, w, h )
						
						local w_ = math.ceil( w * 0.01 )
						local h_ = math.ceil( h * 0.01 )
						
						surface.SetDrawColor( MenuColor.bg_alt )
						surface.DrawRect( w_, h_, w - ( w_ * 2 ), h - ( h_ * 2 ) )
						
						if self:GetChecked() == true then
							
							local s = math.min( 16, w, h )
							surface.SetDrawColor( MenuColor.white )
							surface.SetMaterial( checkmat )
							surface.DrawTexturedRect( ( w * 0.5 ) - ( s * 0.5 ), ( h * 0.5 ) - ( s * 0.5 ), s, s )
							
						end
						
					end
					
				else
					
					local status = vgui.Create( "DImage" )
					status:SetParent( panel )
					status:Dock( LEFT )
					status:DockMargin( spad, hpad, spad, hpad )
					status:SetSize( psize, psize )
					status:SetMaterial( image )
					if games[ i ].owned != true then
						
						status:SetTooltip( "#armenu_notowned" )
						
					elseif games[ i ].installed != true then
						
						status:SetTooltip( "#armenu_notinstalled" )
						
					end
					function status:Paint( w, h )
						
						if self:GetMaterial() != nil then
							
							local s = math.min( 16, w, h )
							surface.SetDrawColor( MenuColor.white )
							surface.SetMaterial( self:GetMaterial() )
							surface.DrawTexturedRect( ( w * 0.5 ) - ( s * 0.5 ), ( h * 0.5 ) - ( s * 0.5 ), s, s )
							
						end
						
					end
					
				end
				
				local mat = gameicons[ i ]
				--if mat != nil and mat:IsError() != true then
					
					local icon = vgui.Create( "DImage" )
					icon:SetParent( panel )
					icon:Dock( LEFT )
					icon:DockMargin( 0, hpad, spad, hpad )
					icon:SetSize( s, s )
					if mat != nil and mat:IsError() != true then icon:SetMaterial( mat ) end
					
				--end
				
				local name = vgui.Create( "DLabel" )
				name:SetParent( panel )
				name:Dock( FILL )
				name:SetText( games[ i ].title )
				name:SetTextColor( MenuColor.fg_alt )
				
			end
			
			bgpanel:InvalidateLayout( true )
			bgpanel:SizeToChildren( false, true )
			bgpanel:SetTall( bgpanel:GetTall() + pad )
			
			GetMainMenu():SetPopup( self.popup )
			
		end
		
	end
	
	if IsValid( self.gamemodes ) == true then self.gamemodes:Remove() end
	self.gamemodes = vgui.Create( "DPanel" )
	self.gamemodes:SetParent( self )
	self.gamemodes:Dock( RIGHT )
	self.gamemodes:DockMargin( pad, 0, 0, 0 )
	self.gamemodes:SetSize( ScrH() * 0.2, ScrH() * 0.04 )
	
	local spad = math.Round( self.gamemodes:GetTall() * 0.1 )
	local s = math.min( 32, self.gamemodes:GetTall() - ( spad * 2 ) )
	local hpad = ( self.gamemodes:GetTall() * 0.5 ) - ( s * 0.5 )
	
	local bicon = vgui.Create( "DImage" )
	bicon:SetParent( self.gamemodes )
	bicon:Dock( LEFT )
	bicon:DockMargin( spad, hpad, spad * 2, hpad )
	bicon:SetSize( s, s )
	function bicon:Think()
		
		local gm = engine.ActiveGamemode()
		
		if gm != self.lastgm then
			
			local mat = gamemodeicons[ gamemodenames[ gm ] ]
			if mat != nil and mat:IsError() != true then self:SetMaterial( mat ) end
			
		end
		
		self.lastgm = gm
		
	end
	
	local bname = vgui.Create( "DLabel" )
	bname:SetParent( self.gamemodes )
	bname:Dock( FILL )
	bname:SetTextColor( MenuColor.fg_alt )
	function bname:Think()
		
		local gm = engine.ActiveGamemode()
		
		if gm != self.lastgm then
			
			local name = gamemodes[ gamemodenames[ gm ] ]
			if name != nil and name.title != nil then self:SetText( name.title ) end
			
			local parent = self:GetParent()
			if IsValid( parent ) == true then
				
				local x, y = parent:GetPos()
				x = x + parent:GetWide()
				
				surface.SetFont( self:GetFont() )
				local iw = ( s * 2 ) + ( spad * 6 ) + surface.GetTextSize( self:GetText() )
				parent:SetWide( iw )
				parent:SetPos( x - iw, y )
				
			end
			
		end
		
		self.lastgm = gm
		
	end
	
	local bbutton = vgui.Create( "DButton" )
	bbutton:SetParent( self.gamemodes )
	bbutton:SetText( "" )
	function bbutton:Paint( w, h )
	end
	function bbutton:Think()
		
		self:SetPos( 0, 0 )
		self:SetSize( self:GetParent():GetWide(), self:GetParent():GetTall() )
		
	end
	function bbutton:DoClick()
		
		if IsValid( self:GetParent().popup ) == true then
			
			self:GetParent().popup:Remove()
			
		else
			
			local size = math.Round( ScrH() * 0.02 )
			local sep = math.Round( size * 0.5 )
			local pad = math.Round( size * 0.25 )
			
			self:GetParent().popup = vgui.Create( "DPanel" )
			self:GetParent().popup:SetParent( GetMainMenu() )
			self:GetParent().popup:SetSize( ScrW() * 0.15, ScrH() * 0.3 )
			local x, y = self:GetParent():GetPos()
			local bx, by = self:GetParent():GetParent():GetPos()
			x = bx + x + self:GetParent():GetWide() - self:GetParent().popup:GetWide() - ( size * 0.5 )
			y = by - self:GetParent().popup:GetTall() - ( size * 0.5 )
			self:GetParent().popup:SetPos( x, y )
			self:GetParent().popup.Paint = function( self, w, h )
				
				--draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bgdim )
				surface.SetDrawColor( MenuColor.bgdim )
				surface.DrawRect( 0, 0, w, h )
				
			end
			
			local scroll = vgui.Create( "DScrollPanel" )
			scroll:SetParent( self:GetParent().popup )
			scroll:Dock( FILL )
			
			local bgpanel = vgui.Create( "DPanel" )
			bgpanel:SetParent( scroll )
			bgpanel:Dock( FILL )
			function bgpanel:Paint( w, h )
			end
			
			gamemodes, gamemodenames = dogamemodes()
			for i = 1, #gamemodes do
				
				if gamemodes[ i ].menusystem == true then
					
					local button = vgui.Create( "DButton" )
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
						
						RunConsoleCommand( "gamemode", gamemodes[ i ].name )
						GetMainMenu():SetPopup( nil )
						
					end
					
				end
				
			end
			
			bgpanel:InvalidateLayout( true )
			bgpanel:SizeToChildren( false, true )
			bgpanel:SetTall( bgpanel:GetTall() + pad )
			
			GetMainMenu():SetPopup( self:GetParent().popup )
			
		end
		
	end
	
	function self.gamemodes:Paint( w, h )
		
		local color = MenuColor.bg_alt
		if bbutton:IsHovered() == true then color = MenuColor.active end
		if bbutton:IsDown() == true then color = MenuColor.selected end
		draw.RoundedBox( 4, 0, 0, w, h, color )
		
	end
	
	if IsValid( self.back ) == true then self.back:Remove() end
	if IsValid( GetMainMenu() ) == true and IsValid( GetMainMenu():GetInnerPanel() ) == true then
		
		self:CreateBack()
		
	end
	
	self:SetTall( ScrH() * 0.05 )
	
end

function PANEL:Init()
	
	local pad = ScrH() * 0.005
	self:DockPadding( pad, pad, pad, pad )
	self:CreateChildren()
	
end

local barcolor = Color( 0, 0, 0, 200 )
function PANEL:Paint( w, h )
	
	surface.SetDrawColor( barcolor )
	surface.DrawRect( 0, 0, w, h )
	
	if IsValid( GetMainMenu():GetInnerPanel() ) == true and IsValid( self.back ) != true then
		
		self:CreateBack()
		
	elseif IsValid( GetMainMenu():GetInnerPanel() ) == false and IsValid( self.back ) == true then
		
		self.back:Remove()
		
	end
	
end



vgui.Register( "MenuBar", PANEL, "DPanel" )