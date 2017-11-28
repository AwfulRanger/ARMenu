local PANEL = {}



function PANEL:Paint( w, h )
	
	local color = MenuColor.bg_alt
	if self:IsHovered() == true then color = MenuColor.active end
	if self:IsDown() == true then color = MenuColor.selected end
	draw.RoundedBox( 4, 0, 0, w, h, color )
	
end



vgui.Register( "MenuBarButton", PANEL, "SoundButton" )