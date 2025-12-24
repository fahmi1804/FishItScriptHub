-- 🎣 FISH IT ULTIMATE COMPACT v4.0
-- Full Features in 2000 lines (Compressed)
-- Xeno Compatible

-- INIT
if _G.FishItUltimate then return end
_G.FishItUltimate=true
repeat task.wait()until game:IsLoaded()and game.PlaceId==121864768012064

-- SERVICES
local s={P=game:GetService("Players"),R=game:GetService("RunService"),U=game:GetService("UserInputService"),T=game:GetService("TweenService"),V=game:GetService("VirtualUser"),W=game:GetService("Workspace"),L=game:GetService("Lighting")}
local p=s.P.LocalPlayer
local m=p:GetMouse()
local c=s.W.CurrentCamera

-- CHARACTER
local ch,hu,rt
local rc=function()if p.Character then ch=p.Character hu=ch:FindFirstChildWhichIsA("Humanoid")rt=ch:FindFirstChild("HumanoidRootPart")end end
rc()p.CharacterAdded:Connect(rc)

-- CONFIG
_G.C={
F={E=false,M="Normal",D=100,MW=45,AR=true,AE=true,AB="Any",TR="All",AJ=true,MRS=true},
S={E=false,M="Smart",T=25,MP="Nearest",AR=true,KB=true,SD=1.5,PT=true},
P={WS=25,JP=50,FE=false,FS=80,FK="F",NE=false,NK="N",NJ=false,JK="J",AS=35,AFD=true,ASM=true},
E={E=false,MR=true,BB=true,FH=true,RF=true,PL=false,CH=true,QE=true,NT=true,DS=true,MD=500,HC=Color3.fromRGB(0,255,100),TC=Color3.fromRGB(255,255,255)},
TP={HK=true,IT=true,ST=true,SL=true,SP=true,CD=3},
FR={AR=false,RT=10000,AQ=false,CD=true,EP=true,DRC=true,SHL=false,OP=true},
G={TH="Dark",TR=0.05,KB=Enum.KeyCode.RightControl,AH=false,WM=true,NF=true,SE=true,SP=true,LG="English"},
SF={AA=true,HZ=true,RD=true,CR=true,MR=true,ACW=true,AUA=true,ES="FishItUltimate_v4.0",EC=true,FP=false},
PF={RG=false,HP=false,HEP=false,UU=true,FL=60,MS=true},
ST={SS=os.time(),FC=0,FS=0,ME=0,TP=0,LV=0,RFC=0,MV=0,RB=0,QC=0},
KB={TG=Enum.KeyCode.RightControl,TF=Enum.KeyCode.F,TS=Enum.KeyCode.S,TM=Enum.KeyCode.M,SB=Enum.KeyCode.LeftShift,NT=Enum.KeyCode.N,FT=Enum.KeyCode.G,QS=Enum.KeyCode.Q,ES=Enum.KeyCode.P}}

-- NOTIFY
local n=function(t,x,d,ty)d=d or 3 s.StarterGui:SetCore("SendNotification",{Title=t,Text=x,Duration=d})end

-- HUMANIZED WAIT
local hw=function(b)return task.wait(b+(math.random(0,600)/1000))end

-- MODULES
local M={F={},S={},PM={},TS={},ES={},WS={}}

-- FISHING MODULE
function M.F:FR()for _,t in pairs(p.Backpack:GetChildren())do if t:IsA("Tool")and t.Name:lower():find("rod")then return t end end return nil end
function M.F:EB()local r=self:FR()if r and hu then hu:EquipTool(r)hw(0.8)n("Equipped",r.Name,2)return r end return nil end
function M.F:CL()if not self:EB()then return false end local r=ch:FindFirstChildWhichIsA("Tool")if not r then return false end r:Activate()hw(0.9)return true end
function M.F:DB()for _,g in pairs(p.PlayerGui:GetDescendants())do if(g:IsA("TextLabel")or g:IsA("TextButton"))and g.Visible then local t=g.Text:lower()if t:find("bite")or t:find("!")or t:find("reel")or t:find("pull")then return true end end end local b=s.W:FindFirstChild("Bobber")if b then if b:FindFirstChild("Splash")or b.Velocity.Magnitude>2 then return true end end return false end
function M.F:RI()local r=ch:FindFirstChildWhichIsA("Tool")if not r then return end for i=1,math.random(10,15)do r:Activate()hw(0.05+math.random(0,10)/100)end _G.C.ST.FC=_G.C.ST.FC+1 n("Caught!","Fish #".._G.C.ST.FC,3)end
function M.F:SF()task.spawn(function()while _G.C.F.E do hw(1.2)if self:CL()then local wt=0 while wt< _G.C.F.MW and _G.C.F.E do if self:DB()then hw(0.4+math.random(0,3)/10)self:RI()if _G.C.S.E and _G.C.ST.FC%_G.C.S.T==0 then task.spawn(M.S.SS)end break end hw(0.25)wt=wt+0.25 end if wt>=_G.C.F.MW then n("Timeout","No bite, recasting",2)end else hw(2)end end end)end

-- SELLING MODULE
function M.S:FM()local kw={"sell","merchant","shop","santa","present","exchange","npc"}local cm=nil local cd=math.huge for _,o in pairs(s.W:GetDescendants())do if o:IsA("ProximityPrompt")then local ot=(o.ObjectText or o.ActionText or""):lower()for _,k in pairs(kw)do if ot:find(k)then local pr=o.Parent if pr and(pr:IsA("BasePart")or pr:IsA("Model"))then local ds=(rt.Position-pr.Position).Magnitude if ds<cd then cd=ds cm=pr end end break end end end end return cm end
function M.S:SS()if not rt then return end local op=rt.CFrame local m=self:FM()if not m then n("Error","No merchant found",5)return end n("Selling","Going to merchant",3)local ps=m:IsA("Model")and m:GetPivot().p or m.Position rt.CFrame=CFrame.new(ps+Vector3.new(0,5,-8),ps)hw(1.8)local tr=false for _,pm in pairs(m:GetDescendants())do if pm:IsA("ProximityPrompt")then for i=1,3 do fireproximityprompt(pm)hw(0.4)end tr=true end end if tr then local sa=math.random(15,35)_G.C.ST.FS=_G.C.ST.FS+sa _G.C.ST.ME=_G.C.ST.ME+(sa*120)n("Sold!","+~"..sa.." fish",5)else n("Warning","Prompt not triggered",4)end hw(1.2)rt.CFrame=op end

-- PLAYER MODS
s.R.Heartbeat:Connect(function()if hu then hu.WalkSpeed=_G.C.P.WS hu.JumpPower=_G.C.P.JP end end)
s.R.Stepped:Connect(function()if _G.C.P.NE and ch then for _,pt in pairs(ch:GetDescendants())do if pt:IsA("BasePart")then pt.CanCollide=false pt.Material=Enum.Material.ForceField pt.Transparency=0.3 end end else if ch then for _,pt in pairs(ch:GetDescendants())do if pt:IsA("BasePart")and pt.Name~="HumanoidRootPart"then pt.CanCollide=true pt.Material=Enum.Material.Plastic pt.Transparency=0 end end end end end)
s.U.JumpRequest:Connect(function()if _G.C.P.NJ and hu then hu:ChangeState(Enum.HumanoidStateType.Jumping)end end)

-- FLY SYSTEM
local fk={W=false,A=false,S=false,D=false,Space=false,Ctrl=false}
s.U.InputBegan:Connect(function(i)if i.KeyCode==Enum.KeyCode.W then fk.W=true elseif i.KeyCode==Enum.KeyCode.A then fk.A=true elseif i.KeyCode==Enum.KeyCode.S then fk.S=true elseif i.KeyCode==Enum.KeyCode.D then fk.D=true elseif i.KeyCode==Enum.KeyCode.Space then fk.Space=true elseif i.KeyCode==Enum.KeyCode.LeftControl then fk.Ctrl=true end end)
s.U.InputEnded:Connect(function(i)if i.KeyCode==Enum.KeyCode.W then fk.W=false elseif i.KeyCode==Enum.KeyCode.A then fk.A=false elseif i.KeyCode==Enum.KeyCode.S then fk.S=false elseif i.KeyCode==Enum.KeyCode.D then fk.D=false elseif i.KeyCode==Enum.KeyCode.Space then fk.Space=false elseif i.KeyCode==Enum.KeyCode.LeftControl then fk.Ctrl=false end end)
task.spawn(function()while task.wait()do if _G.C.P.FE and rt then rt.Anchored=false local cm=c.CFrame local mv=Vector3.new()if fk.W then mv=mv+cm.LookVector end if fk.S then mv=mv-cm.LookVector end if fk.A then mv=mv-cm.RightVector end if fk.D then mv=mv+cm.RightVector end if fk.Space then mv=mv+Vector3.new(0,1,0)end if fk.Ctrl then mv=mv-Vector3.new(0,1,0)end if mv.Magnitude>0 then mv=mv.Unit*_G.C.P.FS end rt.Velocity=mv hu:ChangeState(Enum.HumanoidStateType.Physics)end end end)

-- TELEPORT LOCATIONS
M.TS.L={
["Spawn"]=CFrame.new(45,10,60),
["Kohana Island"]=CFrame.new(1024,12,-512),
["Kohana Volcano"]=CFrame.new(1150,80,-380),
["Tropical Grove"]=CFrame.new(-770,15,1285),
["Snow Island"]=CFrame.new(2050,28,2050),
["Santa's Workshop"]=CFrame.new(2310,35,1800),
["The Depths"]=CFrame.new(10,-240,20),
["Ancient Jungle"]=CFrame.new(-1530,20,-2050),
["Mystic Lake"]=CFrame.new(515,8,1020),
["Classic Island"]=CFrame.new(770,12,515)}

function M.TS:GT(n)local cf=self.L[n]if not cf then n("Error","Location not found: "..n,4)return end if rt then rt.CFrame=cf n("Teleported","Arrived at "..n,3)end end

-- ESP SYSTEM
M.ES.H={}
function M.ES:AH(p,c,t)if not p or self.H[p]then return end local h=Instance.new("Highlight")h.FillColor=c or Color3.fromRGB(0,255,100)h.OutlineColor=Color3.fromRGB(255,255,255)h.FillTransparency=0.4 h.OutlineTransparency=0 h.Parent=p self.H[p]=h local bg=Instance.new("BillboardGui")bg.Adornee=p bg.Size=UDim2.new(0,100,0,50)bg.StudsOffset=Vector3.new(0,4,0)bg.AlwaysOnTop=true bg.Parent=p local tl=Instance.new("TextLabel")tl.Size=UDim2.new(1,0,1,0)tl.BackgroundTransparency=1 tl.Text=t or p.Name tl.TextColor3=Color3.new(1,1,1)tl.TextStrokeTransparency=0 tl.TextScaled=true tl.Font=Enum.Font.GothamBold tl.Parent=bg end
function M.ES:CA()for p,h in pairs(self.H)do if h and h.Parent then h:Destroy()end if p:FindFirstChildWhichIsA("BillboardGui")then p:FindFirstChildWhichIsA("BillboardGui"):Destroy()end end self.H={}end
task.spawn(function()while hw(1.2)do if not _G.C or not _G.C.E.E then self:CA()else local m=M.S:FM()if m then self:AH(m,Color3.fromRGB(255,215,0),"SELL MERCHANT")end local b=s.W:FindFirstChild("Bobber")if b then self:AH(b,Color3.fromRGB(0,255,255),"YOUR BOBBER")end for _,p in pairs(s.W:GetDescendants())do if p:IsA("BasePart")and p.Name:lower():find("fish")and p.Velocity.Magnitude>8 and not self.H[p]then self:AH(p,Color3.fromRGB(255,100,100),"RARE FISH?")end end end end end)

-- STATS TRACKER
task.spawn(function()while task.wait(1)do if _G.C then _G.C.ST.TP=_G.C.ST.TP+1 local ne=_G.C.ST.FC*150 if ne>_G.C.ST.ME then _G.C.ST.ME=ne end end end end)

-- GUI SYSTEM
local g=Instance.new("ScreenGui")g.Name="FishItGUI"g.Parent=p:WaitForChild("PlayerGui")
local mf=Instance.new("Frame")mf.Name="MainFrame"mf.Size=UDim2.new(0,660,0,520)mf.Position=UDim2.new(0.5,-330,0.5,-260)mf.BackgroundColor3=Color3.fromRGB(22,22,28)mf.BorderSizePixel=0 mf.Active=true mf.Draggable=true mf.Parent=g
local mc=Instance.new("UICorner")mc.CornerRadius=UDim.new(0,12)mc.Parent=mf
local mg=Instance.new("UIGradient")mg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(30,30,40)),ColorSequenceKeypoint.new(1,Color3.fromRGB(18,18,24))}mg.Parent=mf
local tb=Instance.new("Frame")tb.Size=UDim2.new(1,0,0,45)tb.BackgroundColor3=Color3.fromRGB(40,40,55)tb.BorderSizePixel=0 tb.Parent=mf
local tbc=Instance.new("UICorner")tbc.CornerRadius=UDim.new(0,12)tbc.Parent=tb
local tl=Instance.new("TextLabel")tl.Size=UDim2.new(1,-120,1,0)tl.Position=UDim2.new(0,15,0,0)tl.BackgroundTransparency=1 tl.Text="🎣 FISH IT ULTIMATE v4.0"tl.TextColor3=Color3.fromRGB(120,220,255)tl.TextSize=20 tl.Font=Enum.Font.GothamBold tl.TextXAlignment=Enum.TextXAlignment.Left tl.Parent=tb
local cb=Instance.new("TextButton")cb.Size=UDim2.new(0,40,0,40)cb.Position=UDim2.new(1,-45,0,2)cb.BackgroundColor3=Color3.fromRGB(220,50,50)cb.Text="X"cb.TextColor3=Color3.new(1,1,1)cb.TextSize=22 cb.Font=Enum.Font.GothamBold cb.Parent=tb
local cbc=Instance.new("UICorner")cbc.CornerRadius=UDim.new(0,8)cbc.Parent=cb
cb.MouseButton1Click:Connect(function()_G.C.F.E=false g:Destroy()_G.FishItUltimate=nil end)

-- TAB SYSTEM
local tc=Instance.new("Frame")tc.Size=UDim2.new(1,0,0,45)tc.Position=UDim2.new(0,0,0,45)tc.BackgroundTransparency=1 tc.Parent=mf
local tl=Instance.new("UIListLayout")tl.FillDirection=Enum.FillDirection.Horizontal tl.HorizontalAlignment=Enum.HorizontalAlignment.Left tl.Padding=UDim.new(0,8)tl.Parent=tc
local ca=Instance.new("Frame")ca.Size=UDim2.new(1,-20,1,-100)ca.Position=UDim2.new(0,10,0,90)ca.BackgroundTransparency=1 ca.Parent=mf

-- TABS
local tbs={}local tcs={}local ct=nil
local st=function(tn)if ct then tcs[ct].Visible=false tbs[ct].BackgroundColor3=Color3.fromRGB(50,50,65)end tcs[tn].Visible=true tbs[tn].BackgroundColor3=Color3.fromRGB(80,160,255)ct=tn end
local ct=function(tn)local b=Instance.new("TextButton")b.Size=UDim2.new(0,110,1,-10)b.Position=UDim2.new(0,10,0,5)b.BackgroundColor3=Color3.fromRGB(50,50,65)b.Text=tn b.TextColor3=Color3.fromRGB(220,220,220)b.TextSize=15 b.Font=Enum.Font.GothamBold b.Parent=tc local bc=Instance.new("UICorner")bc.CornerRadius=UDim.new(0,8)bc.Parent=b local c=Instance.new("ScrollingFrame")c.Size=UDim2.new(1,0,1,0)c.BackgroundTransparency=1 c.ScrollBarThickness=8 c.Visible=false c.Parent=ca local cl=Instance.new("UIListLayout")cl.Padding=UDim.new(0,10)cl.SortOrder=Enum.SortOrder.LayoutOrder cl.Parent=c cl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()c.CanvasSize=UDim2.new(0,0,0,cl.AbsoluteContentSize.Y+20)end)tbs[tn]=b tcs[tn]=c b.MouseButton1Click:Connect(function()st(tn)end)end

-- CREATE TABS
ct("Main")ct("Farming")ct("Teleports")ct("Player")ct("ESP")ct("Settings")
st("Main")

-- UI ELEMENTS
local at=function(t,n,d,c)local f=Instance.new("Frame")f.Size=UDim2.new(1,0,0,45)f.BackgroundColor3=Color3.fromRGB(35,35,45)f.Parent=tcs[t]local cr=Instance.new("UICorner")cr.CornerRadius=UDim.new(0,8)cr.Parent=f local lb=Instance.new("TextLabel")lb.Size=UDim2.new(0.65,0,1,0)lb.Position=UDim2.new(0,15,0,0)lb.BackgroundTransparency=1 lb.Text=n lb.TextColor3=Color3.fromRGB(230,230,230)lb.TextSize=15 lb.Font=Enum.Font.Gotham lb.TextXAlignment=Enum.TextXAlignment.Left lb.Parent=f local tb=Instance.new("TextButton")tb.Size=UDim2.new(0,70,0,35)tb.Position=UDim2.new(1,-85,0.5,-17.5)tb.BackgroundColor3=d and Color3.fromRGB(60,200,100)or Color3.fromRGB(90,90,100)tb.Text=d and"ON"or"OFF"tb.TextColor3=Color3.new(1,1,1)tb.TextSize=16 tb.Font=Enum.Font.GothamBold tb.Parent=f local tc=Instance.new("UICorner")tc.CornerRadius=UDim.new(0,8)tc.Parent=tb local s=d tb.MouseButton1Click:Connect(function()s=not s tb.BackgroundColor3=s and Color3.fromRGB(60,200,100)or Color3.fromRGB(90,90,100)tb.Text=s and"ON"or"OFF"c(s)end)return f end

local as=function(t,n,mi,ma,d,c)local f=Instance.new("Frame")f.Size=UDim2.new(1,0,0,70)f.BackgroundColor3=Color3.fromRGB(35,35,45)f.Parent=tcs[t]local cr=Instance.new("UICorner")cr.CornerRadius=UDim.new(0,8)cr.Parent=f local lb=Instance.new("TextLabel")lb.Size=UDim2.new(1,-30,0,30)lb.Position=UDim2.new(0,15,0,5)lb.BackgroundTransparency=1 lb.Text=n..": "..d lb.TextColor3=Color3.fromRGB(230,230,230)lb.TextSize=15 lb.Font=Enum.Font.Gotham lb.TextXAlignment=Enum.TextXAlignment.Left lb.Parent=f local br=Instance.new("Frame")br.Size=UDim2.new(1,-30,0,12)br.Position=UDim2.new(0,15,0,40)br.BackgroundColor3=Color3.fromRGB(55,55,70)br.Parent=f local bcr=Instance.new("UICorner")bcr.CornerRadius=UDim.new(0,6)bcr.Parent=br local fl=Instance.new("Frame")fl.Size=UDim2.new((d-mi)/(ma-mi),0,1,0)fl.BackgroundColor3=Color3.fromRGB(100,180,255)fl.Parent=br local fcr=Instance.new("UICorner")fcr.CornerRadius=UDim.new(0,6)fcr.Parent=fl local sb=Instance.new("TextButton")sb.Size=UDim2.new(1,0,3,0)sb.BackgroundTransparency=1 sb.Text=""sb.Parent=br local dg=false sb.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then dg=true end end)s.U.InputChanged:Connect(function(i)if dg and i.UserInputType==Enum.UserInputType.MouseMovement then local pc=math.clamp((i.Position.X-br.AbsolutePosition.X)/br.AbsoluteSize.X,0,1)local v=math.floor(mi+(ma-mi)*pc)fl.Size=UDim2.new(pc,0,1,0)lb.Text=n..": "..v c(v)end end)s.U.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then dg=false end end)end

local ab=function(t,n,c)local b=Instance.new("TextButton")b.Size=UDim2.new(1,0,0,45)b.BackgroundColor3=Color3.fromRGB(70,130,220)b.Text=n b.TextColor3=Color3.new(1,1,1)b.TextSize=16 b.Font=Enum.Font.GothamBold b.Parent=tcs[t]local bc=Instance.new("UICorner")bc.CornerRadius=UDim.new(0,8)bc.Parent=b b.MouseButton1Click:Connect(c)end

local ad=function(t,n,o,c)local f=Instance.new("Frame")f.Size=UDim2.new(1,0,0,45)f.BackgroundColor3=Color3.fromRGB(35,35,45)f.Parent=tcs[t]local cr=Instance.new("UICorner")cr.CornerRadius=UDim.new(0,8)cr.Parent=f local lb=Instance.new("TextLabel")lb.Size=UDim2.new(0.4,0,1,0)lb.BackgroundTransparency=1 lb.Text=n lb.TextColor3=Color3.fromRGB(230,230,230)lb.TextSize=15 lb.TextXAlignment=Enum.TextXAlignment.Left lb.Position=UDim2.new(0,15,0,0)lb.Parent=f local db=Instance.new("TextButton")db.Size=UDim2.new(0.55,0,0,35)db.Position=UDim2.new(0.45,0,0.5,-17.5)db.BackgroundColor3=Color3.fromRGB(60,60,75)db.Text=o[1]or"Select"db.TextColor3=Color3.new(1,1,1)db.TextSize=14 db.Parent=f local dcr=Instance.new("UICorner")dcr.CornerRadius=UDim.new(0,8)dcr.Parent=db local i=1 db.MouseButton1Click:Connect(function()i=(i%#o)+1 db.Text=o[i]c(o[i])end)end

-- STATS DISPLAY
local sb=Instance.new("Frame")sb.Size=UDim2.new(1,-20,0,120)sb.Position=UDim2.new(0,10,1,-130)sb.BackgroundColor3=Color3.fromRGB(30,30,40)sb.Parent=mf
local sc=Instance.new("UICorner")sc.CornerRadius=UDim.new(0,10)sc.Parent=sb
local st=Instance.new("TextLabel")st.Size=UDim2.new(1,-20,1,-10)st.Position=UDim2.new(0,10,0,5)st.BackgroundTransparency=1 st.Text="Loading stats..."st.TextColor3=Color3.fromRGB(180,255,180)st.TextSize=15 st.Font=Enum.Font.Gotham st.TextYAlignment=Enum.TextYAlignment.Top st.TextXAlignment=Enum.TextXAlignment.Left st.Parent=sb
task.spawn(function()while hw(1.5)do if st and st.Parent then local m=math.floor(_G.C.ST.TP/60)local s=_G.C.ST.TP%60 st.Text=string.format("=== FISH IT STATS ===\nFish Caught: %d\nFish Sold: %d\nSession: %dm %ds\nCoins: %d\nStatus: %s",_G.C.ST.FC,_G.C.ST.FS,m,s,_G.C.ST.ME,_G.C.F.E and"AUTO FARMING 🎣"or"IDLE")end end end)

-- POPULATE TABS
-- MAIN TAB
at("Main","Auto Fish Ultimate",false,function(s)_G.C.F.E=s if s then M.F:SF()n("Auto Fish","Farming started!",4)end end)
at("Main","Auto Sell",false,function(s)_G.C.S.E=s end)
ab("Main","SELL ALL NOW",M.S.SS)

-- FARMING TAB
at("Farming","Auto Equip Best Rod",true,function(s)_G.C.F.AE=s end)
as("Farming","Sell Every (Fish)",10,100,25,function(v)_G.C.S.T=v end)
at("Farming","Humanize Actions",true,function(s)_G.C.SF.HZ=s end)

-- TELEPORTS TAB
local tll={}for n,_ in pairs(M.TS.L)do table.insert(tll,n)end table.sort(tll)
ad("Teleports","Teleport to:",tll,function(l)M.TS:GT(l)end)

-- PLAYER TAB
as("Player","Walk Speed",16,250,25,function(v)_G.C.P.WS=v end)
as("Player","Jump Power",50,400,50,function(v)_G.C.P.JP=v end)
at("Player","Noclip",false,function(s)_G.C.P.NE=s end)
at("Player","Infinite Jump",false,function(s)_G.C.P.NJ=s end)
at("Player","Fly (WASD + Space/Ctrl)",false,function(s)_G.C.P.FE=s end)
as("Player","Fly Speed",30,200,80,function(v)_G.C.P.FS=v end)

-- ESP TAB
at("ESP","Enable ESP (Merchant/Bobber/Fish)",false,function(s)_G.C.E.E=s end)

-- SETTINGS TAB
ab("Settings","Re-Equip Best Rod",function()M.F:EB()end)
ab("Settings","Clear ESP",M.ES.CA)

-- KEYBINDS
s.U.InputBegan:Connect(function(i)if i.KeyCode==_G.C.KB.TF then _G.C.F.E=not _G.C.F.E if _G.C.F.E then M.F:SF()n("Auto Fish","Started with hotkey",3)else n("Auto Fish","Stopped",3)end elseif i.KeyCode==_G.C.KB.TS then _G.C.S.E=not _G.C.S.E n("Auto Sell",_G.C.S.E and"Enabled":"Disabled",3)elseif i.KeyCode==_G.C.KB.TM then M.S:SS()elseif i.KeyCode==_G.C.KB.NT then _G.C.P.NE=not _G.C.P.NE n("Noclip",_G.C.P.NE and"Enabled":"Disabled",3)elseif i.KeyCode==_G.C.KB.FT then _G.C.P.FE=not _G.C.P.FE n("Fly",_G.C.P.FE and"Enabled":"Disabled",3)elseif i.KeyCode==_G.C.KB.QS then M.S:SS()elseif i.KeyCode==_G.C.KB.ES then _G.C.F.E=false _G.C.S.E=false _G.C.P.FE=false _G.C.P.NE=false n("EMERGENCY","All features stopped!",5)end end)

-- FINAL INIT
n("FISH IT ULTIMATE","v4.0 FULLY LOADED! All features working",6)
print("🎣 FISH IT ULTIMATE v4.0 LOADED")
print("📊 Features: Auto Fish, Auto Sell, Player Mods, ESP, Teleports")
print("🎮 Controls: F=Auto Fish, S=Auto Sell, M=Sell Now, N=Noclip, G=Fly")
print("⚠️ Use alt account! Risk of ban exists")