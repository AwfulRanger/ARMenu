local PANEL = {}



language.Add( "armenu_achievements", "Achievements" )

local menu
concommand.Add( "armenu_achievements", function()
	
	if IsValid( menu ) == true then menu:Remove() end
	
	menu = vgui.Create( "DFrame" )
	menu:SetSize( ScrW() * 0.4, ScrH() * 0.4 )
	menu:Center()
	menu:SetTitle( "#armenu_achievements" )
	menu:MakePopup()
	
	local scroll = vgui.Create( "DScrollPanel" )
	scroll:SetParent( menu )
	scroll:Dock( FILL )
	
	local dock = ScrH() * 0.01
	
	for i = 1, achievements.Count() - 1 do
		
		local a = vgui.Create( "DPanel" )
		a:SetParent( scroll )
		a:Dock( TOP )
		a:DockPadding( dock, dock, dock, dock )
		
		local icon = vgui.Create( "AchievementIcon" )
		icon:SetParent( a )
		icon:SetAchievement( i )
		icon:Dock( LEFT )
		icon:DockMargin( 0, 0, dock, 0 )
		
		local title = vgui.Create( "DLabel" )
		title:SetParent( a )
		title:Dock( TOP )
		title:SetTextColor( MenuColor.fg_alt )
		title:SetText( i .. ": " .. achievements.GetName( i ) )
		
		local desc = vgui.Create( "DLabel" )
		desc:SetParent( a )
		desc:Dock( TOP )
		desc:SetTextColor( MenuColor.fg_alt )
		desc:SetText( achievements.GetDesc( i ) )
		
		local progress = vgui.Create( "DProgress" )
		progress:SetParent( a )
		progress:Dock( BOTTOM )
		local f = achievements.GetCount( i ) / achievements.GetGoal( i )
		if achievements.GetCount( i ) == 0 and achievements.GetGoal( i ) == 1 then
			
			f = 0
			if achievements.IsAchieved( i ) == true then f = 1 end
			
		end
		function progress:PaintOver( w, h )
			
			local text = achievements.GetCount( i ) .. "/" .. achievements.GetGoal( i )
			if f == 1 then text = achievements.GetGoal( i ) .. "/" .. achievements.GetGoal( i ) end
			surface.SetFont( "DermaDefault" )
			local tw, th = surface.GetTextSize( text )
			surface.SetTextColor( MenuColor.fg_alt )
			local y = ( h * 0.5 ) - ( th * 0.5 )
			surface.SetTextPos( w - tw - y, y )
			surface.DrawText( text )
			
		end
		progress:SetFraction( f )
		
		a:SetTall( icon:GetWide() + ( ScrH() * 0.02 ) )
		
	end
	
end, nil, "Open achievements menu" )

function PANEL:Init()
	
	self:SetText( "#armenu_achievements" )
	self:InvalidateLayout( true )
	
end

function PANEL:DoClick()
	
	RunConsoleCommand( "armenu_achievements" )
	
end



vgui.Register( "Button_Achievements", PANEL, "MainMenuButton" )