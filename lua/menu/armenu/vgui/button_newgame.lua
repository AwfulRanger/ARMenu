local PANEL = {}



function PANEL:Init()
	
	self:SetText( "#new_game" )
	self:InvalidateLayout( true )
	
end

function PANEL:DoClick()
	
	GetMainMenu():SetInnerPanel( vgui.Create( "MainMenu_NewGame" ) )
	
end



vgui.Register( "Button_NewGame", PANEL, "MainMenuButton" )