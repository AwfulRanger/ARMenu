local PANEL = {}



surface.CreateFont( "ARMenu_Buttons", {
	
	font = "Roboto",
	size = ScrH() * 0.0245,
	weight = 900,
	
} )

function PANEL:Init()
	
	self:SetFont( "ARMenu_Buttons" )
	self:NoClipping( true )
	
end

function PANEL:Paint( w, h )
	
	local text = self:GetText()
	
	surface.SetFont( self:GetFont() )
	
	local tw, th = surface.GetTextSize( text )
	
	local x = ( w * 0.5 ) - ( tw * 0.5 )
	local y = ( h * 0.5 ) - ( th * 0.5 )
	local sh = ScrW() * 0.0015
	
	surface.SetTextColor( MenuColor.bg )
	surface.SetTextPos( x + sh, y + sh )
	surface.DrawText( text )
	
	local color = MenuColor.fg
	if self:IsHovered() == true then color = MenuColor.active end
	surface.SetTextColor( color )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
	
	return true
	
end

function PANEL:PerformLayout( w, h )
	
	self:SizeToContents()
	
end



vgui.Register( "MainMenuButton", PANEL, "SoundButton" )