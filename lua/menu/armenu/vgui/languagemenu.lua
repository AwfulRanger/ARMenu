local PANEL = {}



local files = file.Find( "resource/localization/*.png", "MOD" )
local languages = {}
for i = 1, #files do languages[ string.lower( string.Left( files[ i ], #files[ i ] - 4 ) ) ] = Material( "resource/localization/" .. files[ i ] ) end

function PANEL:Init()
	
	local size = math.Round( ScrH() * 0.02 )
	local sep = math.Round( size * 0.25 )
	
	local i = 0
	for _, v in pairs( languages ) do
		
		i = i + 1
		
		local line = math.ceil( i / ( #files * 0.25 ) ) - 1
		local col = i - ( ( #files * 0.25 ) * line ) - 1
		
		local button = vgui.Create( "DButton" )
		button:SetParent( self )
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
	
	self:SizeToChildren( true, true )
	self:SetSize( self:GetWide() + sep, self:GetTall() + sep )
	
end

function PANEL:Paint( w, h )
	
	draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bgdim )
	
end



vgui.Register( "LanguageMenu", PANEL, "DPanel" )