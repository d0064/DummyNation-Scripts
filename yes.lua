if ADMINS == nil then getgenv().ADMINS = {} end
--[[
All made by noam#5887 the first exploiter in nations roleplay
A collection of most of the scripts I made for this game all in one
 
Commands:
invert/ - inverts map color
rainbow/ - makes the map rainbow
setcolor/color - sets the entire map to the one color
random/ - randomizes the map colors making it a mess
replace/color/newcolor - replaces the the map (doesn't work with a lot of colors sadly)
name/target/name - sets the target's rp name
noname/ - remove your rp name
admin/username - giver a user admin
unadmin/username - remove a users admin
admins/ - get a list of admins
ccolor/color - sets color for provinces you select
pcolor/color - sets all provinces to that color
select/color? (optional) - 
selects all provinces of the color if specified
if not specified
it lets you select provinces
middle button to toggle select/unselect provinces
 
unselect/color? || all? - stop selecting
cselect/ - clear selection
ssetcolor - set selected color
country/ - protects all your land for you automatically
uncountry/ - stops protecting
 
SAVE COMMANDS:
these commands only save after leaving if your exploit has a filesystem api
however if you arent using a good exploit then it will saved until you leave or rejoin
 
save/name - saves the map
load/name - loads a save
del/name - deletes a save
 
default save lists for exploits with no filesystem api:
default - the default map
inverted - the default map but inverted
]]--
local COUNTRYCOLOR = BrickColor.new()
local PROVINCES = {}
local provinces = workspace:FindFirstChild("Map")
local cansave,saves = true,nil
if not (isfolder and makefolder and readfile and writefile and isfile) then
    cansave = false
    saves = loadstring(game:HttpGet("https://pastebin.com/raw/7jHCikse"))()
end
if cansave then
    if not isfolder("mapgame") then makefolder("mapgame") end
    if not isfolder("mapgame/savesV2") then
        makefolder("mapgame/savesV2")
        local S = loadstring(game:HttpGet("https://pastebin.com/raw/7jHCikse"))()
        for i,v in next, S do writefile("mapgame/savesV2/"..i..".lua",v) end
    end
end
local plr = game.Players.LocalPlayer
local m = plr:GetMouse()
local COUNTRY = false
local SELECT = false
local SMODE = true
m.Button1Down:Connect(function()
    local t = m.Target
    if t.Name ~= "Province" then return end
    if not SELECT then return end
    if t:GetAttribute("SELECTED") ~= nil and SMODE == false then
        for i,v in next, PROVINCES do
            if v == t then table.remove(PROVINCES,i) break end
        end
        t:SetAttribute("SELECTED",nil)
    elseif t:GetAttribute("SELECTED") == nil and SMODE then
        table.insert(PROVINCES,t)
        t:SetAttribute("SELECTED",COUNTRYCOLOR)
    elseif t:GetAttribute("SELECTED") ~= nil and SMODE then
        t:SetAttribute("SELECTED",COUNTRYCOLOR)
    end
end)
game:GetService("UserInputService").InputBegan:Connect(function(i)
    if not SELECT then return end
    if i.UserInputType == Enum.UserInputType.MouseButton3 then
        SMODE = not SMODE
    end
end)
spawn(function()
    while task.wait(.25) do
        if not SELECT then continue end
        for i,v in next, provinces:GetChildren() do
            if v:IsA("Model") or v.Name == "Ocean" or v.Name ~= "Province" then continue end
            if v:GetAttribute("SELECTED") == nil then
                v.Material = Enum.Material.Pebble
            else
                v.Material = Enum.Material.Neon
            end
        end
    end
end)
local t = plr.Backpack:FindFirstChild("PaintBucket") or plr.Character:FindFirstChild("PaintBucket")
spawn(function()
    while task.wait(.1) do
        if not COUNTRY then continue end
        local r = t:FindFirstChild("Remotes")
        if not r then continue end
        r = r:WaitForChild("ServerControls")
        if not r then return end
        for i,v in next, PROVINCES do
            local c = v:GetAttribute("SELECTED")
            if v.BrickColor ~= c then
                spawn(function() paint(r,v,c.Color) end)
            end
        end
    end
end)
function get(p)
    local p1 = p.Position - (p.Size / 2)
    local p2 = p.Position + (p.Size / 2)
    return p1,p2
end
 
local r1 = {math.huge,math.huge,math.huge}
local r2 = {0,0,0}
for i,v in next,provinces:GetDescendants() do
    if v:IsA("BasePart") and v.Name == "Province" then
        local p1,p2 = get(v)
        if p1.X < r1[1] then r1[1] = p1.X end
        if p1.Y < r1[2] then r1[2] = p1.Y end
        if p1.Z < r1[3] then r1[3] = p1.Z end
        if p2.X > r2[1] then r2[1] = p2.X end
        if p2.Y > r2[2] then r2[2] = p2.Y end
        if p2.Z > r2[3] then r2[3] = p2.Z end
    end
end
r1 = Vector3.new(unpack(r1))
r2 = Vector3.new(unpack(r2))
local r = Region3.new(r1,r2)
 
function paint(rem, part, color)
    return rem:InvokeServer("PaintPart", {Part = part;Color = color})
end
 
function checkcol(c1, c2)
    return c1.R == c2.R and c1.G == c2.G and c1.B == c2.B
end
function invertColor(p)
    return Color3.new(1-p.Color.R,1-p.Color.G,1-p.Color.B)
end
 
function invert()
    if t then
        if t.Parent == plr.Backpack then plr.Character.Humanoid:EquipTool(t) end
        local r = t:WaitForChild("Remotes"):WaitForChild("ServerControls")
        for i,v in next, provinces:GetChildren() do
            if v:IsA("BasePart") then
                local c = invertColor(v)
                if v.Name == "Province" and not checkcol(v.Color, c) then
                    spawn(function() paint(r,v,c) end)
                end
            end
        end
    end
end
 
function rainbowColor(p)
    return Color3.fromHSV(math.abs((p.Position.X-r.CFrame.X)/r.Size.X),1,1)
end
 
function rainbow()
    if t then
        if t.Parent == plr.Backpack then plr.Character.Humanoid:EquipTool(t) end
        local r = t:WaitForChild("Remotes"):WaitForChild("ServerControls")
        for i,v in next, provinces:GetChildren() do
            if v:IsA("BasePart") then
                local c = rainbowColor(v)
                if v.Name == "Province" and not checkcol(v.Color, c) then
                    spawn(function() paint(r,v,c) end)
                end
            end
        end
    end
end
 
function save(name)
    local t = {
    }
    function new(i)
        table.insert(t,{i.Position;i.Color})
    end
    for i,v in next,provinces:GetDescendants() do
        if v:IsA("BasePart") and v.Name == "Province" then
            new(v)
        end
    end
    local s = "return {"
    for i,v in next, t do
        s = s.."{Vector3.new("..v[1].X..","..v[1].Y..","..v[1].Z..");Color3.new("..v[2].R..","..v[2].G..","..v[2].B..")};"
    end
    s = s.."}"
    if cansave then
        writefile("mapgame/savesV2/"..name..".lua",s)
    else
        saves[name] = s
    end
end
 
function loadColor(T,p)
    for i = 1,#T do
        local I
        if i%2 == 0 then
            I = #T+1-math.floor(i/2)
        else
            I = math.floor(i/2+.5)
        end
        if p.Position == T[I][1] then c = T[I][2] table.remove(T,I) return c end
    end
end
 
function loadmap(name)
    if cansave then
        if not isfile("mapgame/savesV2/"..name..".lua") then return false end
    else
        if saves[name] == nil then return false end
    end
    local T
    if cansave then
        T = loadstring(readfile("mapgame/savesV2/"..name..".lua"))()
    else
        T = loadstring(saves[name])()
    end
    if t then
        if t.Parent == plr.Backpack then plr.Character.Humanoid:EquipTool(t) end
        local r = t:WaitForChild("Remotes"):WaitForChild("ServerControls")
        for i,v in next, provinces:GetChildren() do
            if v:IsA("BasePart") and v.Name == "Province" then
                local c = loadColor(T,v)
                if not checkcol(v.Color, c) then
                    spawn(function() paint(r,v,c) end)
                end
            end
        end
    end
end
 
function name(n,t)
    for i,v in next,game.Players:GetPlayers() do
        if n:lower() == v.Name:lower():sub(1,#n) or n:lower() == v.DisplayName:lower():sub(1,#n) or n:lower() == "all" then
            for I,V in next, v.Character:GetChildren() do
                if V:FindFirstChild("ServerHandler") then
                    spawn(function() V.ServerHandler:FireServer(t) end)
                end
            end
        end
    end
end
 
function setcolor(color)
    local c = BrickColor.new(color).Color
    if t then
        if t.Parent == plr.Backpack then plr.Character.Humanoid:EquipTool(t) end
        local r = t:WaitForChild("Remotes"):WaitForChild("ServerControls")
        for i,v in next, provinces:GetChildren() do
            if v:IsA("BasePart") then
                if v.Name == "Province" and not checkcol(v.Color, c) then
                    spawn(function() paint(r,v,c) end)
                end
            end
        end
    end
end
function ssetcolor(color)
    local c = BrickColor.new(color).Color
    if t then
        if t.Parent == plr.Backpack then plr.Character.Humanoid:EquipTool(t) end
        local r = t:WaitForChild("Remotes"):WaitForChild("ServerControls")
        for i,v in next, PROVINCES do
            if v:IsA("BasePart") then
                if v.Name == "Province" and not checkcol(v.Color, c) then
                    spawn(function() paint(r,v,c) end)
                end
            end
        end
    end
end
 
function replace(col1,col2)
    local c1 = BrickColor.new(col1)
    local c2 = BrickColor.new(col2)
    if t then
        if t.Parent == plr.Backpack then plr.Character.Humanoid:EquipTool(t) end
        local r = t:WaitForChild("Remotes"):WaitForChild("ServerControls")
        for i,v in next, provinces:GetChildren() do
            if v:IsA("BasePart") then
                if v.Name == "Province" and v.BrickColor == c1 then
                    spawn(function() paint(r,v,c2.Color) end)
                end
            end
        end
    end
end
 
function RAND()
    if t then
        if t.Parent == plr.Backpack then plr.Character.Humanoid:EquipTool(t) end
        local r = t:WaitForChild("Remotes"):WaitForChild("ServerControls")
        for i,v in next, provinces:GetChildren() do
            if v:IsA("BasePart") then
                local c = Color3.new(math.random(0,255)/255,math.random(0,255)/255,math.random(0,255)/255)
                if v.Name == "Province" and not checkcol(v.Color, c) then
                    spawn(function() paint(r,v,c) end)
                end
            end
        end
    end
end
function admin(n)
    for i,v in next, game.Players:GetPlayers() do
        if n:lower() == v.Name:lower():sub(1,#n) or n:lower() == v.DisplayName:lower():sub(1,#n) or n:lower() == "all" then
            if table.find(ADMINS,v.UserId) == nil then
                table.insert(ADMINS,v.UserId)
            end
        end
    end
end
function unadmin(n)
    for i,v in next, game.Players:GetPlayers() do
        if n:lower() == v.Name:lower():sub(1,#n) or n:lower() == v.DisplayName:lower():sub(1,#n) or n:lower() == "all" then
            local f = table.find(ADMINS,v.UserId)
            if f ~= nil then
                table.remove(ADMINS,f)
            end
        end
    end
end
function CHAT(msg)
    t = plr.Backpack:FindFirstChild("PaintBucket") or plr.Character:FindFirstChild("PaintBucket")
    if msg:find("/") == nil then return end
    local cmd = msg:split("/")[1]
    local a = {select(2,unpack(msg:split("/")))}
    if cmd == "invert" then
        invert()
    elseif cmd == "rainbow" then
        rainbow()
    elseif cmd == "save" then
        save(a[1])
    elseif cmd == "load" then
        loadmap(a[1])
    elseif cmd == "del" then
        if cansave then
            delfile("mapgame/savesV2/"..a[1]..".lua")
        else
            saves[a[1]] = nil
        end
    elseif cmd == "noname" then
        plr.Character.Head.RPName:Destroy()
    elseif cmd == "nogui" then
        plr.Character.Head.LEADER:Destroy()
        plr.Character.Head.FLAG:Destroy()
    elseif cmd == "setcolor" then
        setcolor(a[1])
    elseif cmd == "replace" then
        replace(a[1],a[2])
    elseif cmd == "random" then
        RAND()
    elseif cmd == "admin" then
        admin(a[1])
    elseif cmd == "unadmin" then
        unadmin(a[1])
    elseif cmd == "admins" then
        local l = {}
        for i,v in next, ADMINS do
            local f = false
            for _,pl in next, game.Players:GetPlayers() do
                if pl.UserId == v then
                    table.insert(l,pl.Name)
                    f = true
                end
            end
            if not f then
                table.insert(l,v)
            end
        end
        game.StarterGui:SetCore("ChatMakeSystemMessage",
            {
                Text = table.concat(l,", ");
                Color = Color3.new(1,1,1);
                Font = Enum.Font.Arial;
            }
        )
    elseif cmd == "ccolor" then
        COUNTRYCOLOR = BrickColor.new(a[1])
    elseif cmd == "pcolor" then
        local c = BrickColor.new(a[1])
        for i,v in next, PROVINCES do
            v:SetAttribute("SELECTED",c)
        end
    elseif cmd == "select" then
        if #a[1] > 0 then
            if a[1] == "all" then
                for i,v in next, provinces:GetChildren() do
                    if v.Name ~= "Province" then continue end
                    if v:IsA("Model") then continue end
                    if v:GetAttribute("SELECTED") == nil then
                        table.insert(PROVINCES,v)
                        v:SetAttribute("SELECTED",v.BrickColor)
                    end
                end
            else
                local c = BrickColor.new(a[1])
                for i,v in next, provinces:GetChildren() do
                    if v.Name ~= "Province" then continue end
                    if v:IsA("Model") then continue end
                    if v.BrickColor == c and v:GetAttribute("SELECTED") == nil then
                        table.insert(PROVINCES,v)
                        v:SetAttribute("SELECTED",v.BrickColor)
                    end
                end
            end
        else
            SELECT = true
        end
    elseif cmd == "unselect" then
        SELECT = false
        for i,v in next, provinces:GetChildren() do
            if v.Name ~= "Province" then continue end
            if not v:IsA("BasePart") then continue end
            v.Material = Enum.Material.Pebble
        end
    elseif cmd == "cselect" then
        for i = #PROVINCES,1,-1 do
            PROVINCES[i]:SetAttribute("SELECTED",nil)
            table.remove(PROVINCES,i)
        end
    elseif cmd == "ssetcolor" then
        ssetcolor(a[1])
    elseif cmd == "country" then
        COUNTRY = true
    elseif cmd == "uncountry" then
        COUNTRY = false
    end
end
 
plr.Chatted:Connect(CHAT)
local CHATR = game.ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("OnMessageDoneFiltering")
CHATR.OnClientEvent:Connect(function(m,c)
    if m.SpeakerUserId == plr.UserId then return end
    if table.find(ADMINS,m.SpeakerUserId) ~= nil then
        CHAT(m.Message)
    end
end)
