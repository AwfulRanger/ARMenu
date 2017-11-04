local PANEL = {}



function PANEL:Init()
	
	self:SetText( "#demos" )
	self:InvalidateLayout( true )
	
end

function PANEL:DoClick()
	
	GetMainMenu():SetInnerPanel( vgui.Create( "MainMenu_Demos" ) )
	
end



vgui.Register( "Button_Demos", PANEL, "MainMenuButton" )