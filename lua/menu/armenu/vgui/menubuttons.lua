--TODO: addons, demos and saves
--TODO: proper server browser
local PANEL = {}



language.Add( "armenu_disconnectprompt", "Are you sure you want to disconnect?" )
language.Add( "armenu_quitprompt", "Are you sure you want to quit?" )

include( "mainmenubutton.lua" )

local menubuttons = {}

function GetMenuButtonCanvas()
	
	local menu = GetMainMenu()
	if IsValid( menu ) == true then return menu.menubuttons end
	
end

function AddMenuButton( button, pos )
	
	table.insert( menubuttons, { button = button, pos = pos } )
	
end



local function createbuttons( canvas )
	
	for i = 1, #menubuttons do
		
		if IsValid( menubuttons[ i ] ) == true then menubuttons[ i ]:Remove() end
		menubuttons[ i ] = nil
		
	end
	for i = 1, #canvas:GetChildren() do
		
		if IsValid( canvas:GetChildren()[ i ] ) == true then canvas:GetChildren()[ i ]:Remove() end
		
	end
	
	hook.Run( "PreCreateMenuButtons", menubuttons )
	
	local sep = ScrH() * 0.025
	
	if IsInGame() == true then
		
		local resume = vgui.Create( "MainMenuButton" )
		resume:DockMargin( 0, 0, 0, sep )
		resume:SetText( "#resume_game" )
		function resume:DoClick()
			
			gui.HideGameUI()
			
		end
		AddMenuButton( resume, -1000 )
		
		
		local disconnect = vgui.Create( "MainMenuButton" )
		disconnect:SetText( "#disconnect" )
		function disconnect:DoClick()
			
			local prompt = vgui.Create( "YesNoPrompt" )
			prompt:SetPos( 0, 0 )
			prompt:SetSize( ScrW(), ScrH() )
			prompt:SetText( "#armenu_disconnectprompt" )
			function prompt:OnYes()
				
				RunGameUICommand( "disconnect" )
				
			end
			prompt:MakePopup()
			
		end
		AddMenuButton( disconnect, 900 )
		
	end
	
	
	local newgame = vgui.Create( "MainMenuButton" )
	newgame:SetText( "#new_game" )
	function newgame:DoClick()
		
		GetMainMenu():SetInnerPanel( vgui.Create( "MainMenu_NewGame" ) )
		
	end
	AddMenuButton( newgame, -900 )
	
	
	local findmp = vgui.Create( "MainMenuButton" )
	findmp:SetText( "#find_mp_game" )
	findmp:DockMargin( 0, 0, 0, sep )
	function findmp:DoClick()
		
		GetMainMenu():SetInnerPanel( vgui.Create( "MainMenu_FindMP" ) )
		
	end
	AddMenuButton( findmp, -800 )
	
	
	local options = vgui.Create( "MainMenuButton" )
	options:SetText( "#options" )
	options:DockMargin( 0, 0, 0, sep )
	function options:DoClick()
		
		RunGameUICommand( "openoptionsdialog" )
		
	end
	AddMenuButton( options, 800 )
	
	
	local quit = vgui.Create( "MainMenuButton" )
	quit:SetText( "#quit" )
	function quit:DoClick()
		
		local prompt = vgui.Create( "YesNoPrompt" )
		prompt:SetPos( 0, 0 )
		prompt:SetSize( ScrW(), ScrH() )
		prompt:SetText( "#armenu_quitprompt" )
		function prompt:OnYes()
			
			RunGameUICommand( "quit" )
			
		end
		prompt:MakePopup()
		
	end
	AddMenuButton( quit, 1000 )
	
	
	hook.Run( "PostCreateMenuButtons", menubuttons )
	
	local lastvalue
	for _, v in SortedPairsByMemberValue( menubuttons, "pos", true ) do
		
		if lastvalue == pluginbutton and v.button != findmp and IsValid( pluginbutton ) == true then v.button:DockMargin( 0, 0, 0, sep ) end
		lastvalue = v.button
		
	end
	
	return menubuttons
	
end



function PANEL:CreateChildren()
	
	local y = 0
	for _, v in SortedPairsByMemberValue( createbuttons( self:GetCanvas() ), "pos" ) do
		
		v.button:SetParent( self )
		v.button:SetPos( 0, y )
		v.button:InvalidateLayout( true )
		
		local dl, dt, dr, db = v.button:GetDockMargin()
		y = y + v.button:GetTall() + db
		
	end
	
end

function PANEL:Init()
	
	self:CreateChildren()
	
end

function PANEL:Paint( w, h )
	
	if self.LastIsInGame == nil then self.LastIsInGame = IsInGame() end
	if self.LastIsInGame != IsInGame() then
		
		self:CreateChildren()
		self.LastIsInGame = IsInGame()
		
	end
	
end



vgui.Register( "MenuButtons", PANEL, "DScrollPanel" )