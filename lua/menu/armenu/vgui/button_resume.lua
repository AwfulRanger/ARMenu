local PANEL = {}



function PANEL:Init()
	
	self:SetText( "#resume_game" )
	self:InvalidateLayout( true )
	
end

function PANEL:DoClick()
	
	gui.HideGameUI()
	
end



vgui.Register( "Button_Resume", PANEL, "MainMenuButton" )