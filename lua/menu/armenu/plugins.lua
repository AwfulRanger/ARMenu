language.Add( "armenu_plugins", "Plugins" )

local enabled = util.JSONToTable( file.Read( "armenu/plugins.dat" ) or "" ) or {}
local plugins = {}

local function getenabled( name )
	
	return enabled[ name ] or false
	
end

local function setenabled( name, bool )
	
	enabled[ name ] = bool
	file.Write( "armenu/plugins.dat", util.TableToJSON( enabled ) )
	local plugin = plugins[ name ]
	if plugin != nil then
		
		if bool == true and plugin.OnEnabled != nil then
			
			plugin.OnEnabled()
			
		elseif bool != true and plugin.OnDisabled != nil then
			
			plugin.OnDisabled()
			
		end
		
	end
	
end

function AddPlugin( name, tbl )
	
	if tbl.Name == nil then tbl.Name = "#armenu_plugin_" .. name .. ".name" end
	if tbl.Desc == nil then tbl.Desc = "#armenu_plugin_" .. name .. ".desc" end
	plugins[ name ] = tbl
	
end

local _, plugindir = file.Find( "lua/menu/armenu/plugins/*", "GAME" )
for i = 1, #plugindir do
	
	local path = "menu/armenu/plugins/" .. plugindir[ i ] .. "/" .. plugindir[ i ] .. ".lua"
	if file.Exists( "lua/" .. path, "GAME" ) == true then include( path ) end
	
end

hook.Add( "MenuLoaded", "Plugins", function()
	
	for _, v in pairs( plugins ) do
		
		if getenabled( _ ) == true and v.OnEnabled != nil then v.OnEnabled() end
		
	end
	
end )

local checkmat = Material( "html/img/enabled.png" )
local mat = Material( "icon16/wrench.png" )
local menu
hook.Add( "PreCreateMenuBarButtons", "Plugins", function()
	
	local pad = math.Round( ScrH() * 0.005 )
	
	local button = vgui.Create( "MenuBarButton" )
	button:SetWide( button:GetTall() )
	button:DockMargin( pad, 0, 0, 0 )
	button:SetText( "" )
	function button:PerformLayout( w, h )
		
		self:SetWide( h )
		
	end
	local paint = button.Paint
	function button:Paint( w, h, ... )
		
		paint( self, w, h, ... )
		
		local s = math.min( 16, w * 0.4, h * 0.4 )
		
		surface.SetDrawColor( MenuColor.white )
		surface.SetMaterial( mat )
		surface.DrawTexturedRect( ( w * 0.5 ) - ( s * 0.5 ), ( h * 0.5 ) - ( s * 0.5 ), s, s )
		
	end
	function button:DoClick()
		
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
				
				draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bgdim )
				
			end
			
			local scroll = vgui.Create( "DScrollPanel" )
			scroll:SetParent( self.popup )
			scroll:Dock( FILL )
			
			local bgpanel = vgui.Create( "DPanel" )
			bgpanel:SetParent( scroll )
			bgpanel:Dock( FILL )
			function bgpanel:Paint( w, h )
			end
			
			local dock = ScrH() * 0.005
			
			for _, v in pairs( plugins ) do
				
				local panel = vgui.Create( "DPanel" )
				panel:SetParent( bgpanel )
				panel:Dock( TOP )
				panel:DockPadding( dock, dock, dock, dock )
				panel:DockMargin( pad, pad, pad, 0 )
				panel:SetTall( ScrH() * 0.1 )
				function panel:Paint( w, h )
					
					draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bg_alt )
					
				end
				
				local top = vgui.Create( "DPanel" )
				top:SetParent( panel )
				top:Dock( TOP )
				top:DockMargin( 0, 0, 0, dock )
				function top:Paint( w, h )
				end
				
				local title = vgui.Create( "DLabel" )
				title:SetParent( top )
				title:Dock( FILL )
				title:SetTextColor( MenuColor.fg_alt )
				title:SetText( v.Name or "" )
				
				local check = vgui.Create( "DCheckBox" )
				check:SetParent( top )
				check:Dock( RIGHT )
				check:SetValue( getenabled( _ ) )
				function check:OnChange( bool )
					
					setenabled( _, bool )
					
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
				check:InvalidateParent( true )
				check:SetWide( check:GetTall() )
					
				
				local c = MenuColor.fg_alt
				
				local desc = vgui.Create( "RichText" )
				desc:SetParent( panel )
				desc:Dock( FILL )
				desc:InsertColorChange( c.r, c.g, c.b, c.a )
				desc:AppendText( v.Desc or "" )
				
			end
			
			bgpanel:InvalidateLayout( true )
			bgpanel:SizeToChildren( false, true )
			bgpanel:SetTall( bgpanel:GetTall() + pad )
			
			GetMainMenu():SetPopup( self.popup )
			
		end
		
	end
	AddMenuBarButton( button, 1000 )
	
end )