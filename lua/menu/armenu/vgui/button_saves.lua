local PANEL = {}



function PANEL:Init()
	
	self:SetText( "#saves" )
	self:InvalidateLayout( true )
	
end

function PANEL:DoClick()
	
	GetMainMenu():SetInnerPanel( vgui.Create( "MainMenu_Saves" ) )
	
end



vgui.Register( "Button_Saves", PANEL, "MainMenuButton" )