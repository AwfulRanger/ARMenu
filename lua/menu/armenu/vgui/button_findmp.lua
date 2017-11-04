local PANEL = {}



function PANEL:Init()
	
	self:SetText( "#find_mp_game" )
	self:InvalidateLayout( true )
	
end

function PANEL:DoClick()
	
	GetMainMenu():SetInnerPanel( vgui.Create( "MainMenu_FindMP" ) )
	RunGameUICommand( "openserverbrowser" )
	
end



vgui.Register( "Button_FindMP", PANEL, "MainMenuButton" )