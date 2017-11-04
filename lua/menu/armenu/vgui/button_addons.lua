local PANEL = {}



function PANEL:Init()
	
	self:SetText( "#addons" )
	self:InvalidateLayout( true )
	
end

function PANEL:DoClick()
	
	GetMainMenu():SetInnerPanel( vgui.Create( "MainMenu_Addons" ) )
	
end



vgui.Register( "Button_Addons", PANEL, "MainMenuButton" )