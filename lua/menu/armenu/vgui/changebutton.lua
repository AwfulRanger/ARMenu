local PANEL = {}



surface.CreateFont( "ARMenu_ChangeButton", {
	
	font = "Roboto Bold Condensed",
	size = ScrH() * 0.015,
	weight = 900,
	
} )

function PANEL:Init()
	
	self:SetFont( "ARMenu_ChangeButton" )
	self:SetText( "You are on the " .. BRANCH .. " branch. Click here to find out more. ( " .. VERSIONSTR .. " )" )
	self:InvalidateLayout( true )
	
end

function PANEL:Paint( w, h )
	
	draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bg )
	
	surface.SetFont( self:GetFont() )
	local color = MenuColor.inactive
	if self:IsHovered() == true then color = MenuColor.fg end
	surface.SetTextColor( color )
	local text = self:GetText()
	local tw, th = surface.GetTextSize( text )
	surface.SetTextPos( ( w * 0.5 ) - ( tw * 0.5 ), ( h * 0.5 ) - ( th * 0.5 ) )
	surface.DrawText( text )
	
	return true
	
end

function PANEL:PerformLayout( w, h )
	
	self:SizeToContents()
	
end

function PANEL:DoClick()
	
	if BRANCH == "dev" then gui.OpenURL( "http://wiki.garrysmod.com/changelist/" ) return end
	if BRANCH == "prerelease" then gui.OpenURL( "http://wiki.garrysmod.com/changelist/prerelease/" ) return end
	
	gui.OpenURL( "http://www.garrysmod.com/updates/" )
	
end



vgui.Register( "ChangeButton", PANEL, "DButton" )