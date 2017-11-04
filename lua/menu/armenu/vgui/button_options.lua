local PANEL = {}



function PANEL:Init()
	
	self:SetText( "#options" )
	self:InvalidateLayout( true )
	
end

function PANEL:DoClick()
	
	RunGameUICommand( "openoptionsdialog" )
	
end



vgui.Register( "Button_Options", PANEL, "MainMenuButton" )