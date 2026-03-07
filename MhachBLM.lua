MhachBLM = {
	BLM = {
		CD = true,
		DOT = true,
		AOE = true,
		Potion = true,
		Polyglot = true,
		Ley_Lines = true,
		Manafont = true,
		Amplifier = true,
		Triplecast = true,
		Burn = true,
		Smart_Target = true,
		More_Move = true,
	},
 	BLMGUI = {
		WindowName = "MhachBLM BLM Control",  -- 窗口名称
		IsVisible = true,                  -- 窗口是否可见
		WindowFlags = GUI.WindowFlags_AlwaysAutoResize  -- 窗口标志
					| GUI.WindowFlags_NoTitleBar
					| GUI.WindowFlags_NoResize
					| GUI.WindowFlags_NoCollapse,
		Buttons = {  -- 定义按钮及其初始状态
			{Label = "CD", Enabled = true, Clickable = true},
			{Label = "DOT", Enabled = true, Clickable = true},
			{Label = "AOE", Enabled = true, Clickable = true},
			{Label = "爆发药", Enabled = true, Clickable = true},
			{Label = "通晓", Enabled = true, Clickable = true},
			{Label = "黑魔纹", Enabled = true, Clickable = true},
			{Label = "魔泉", Enabled = true, Clickable = true},
			{Label = "详述", Enabled = true, Clickable = true},
			{Label = "三连咏唱", Enabled = true, Clickable = true},
			{Label = "Burn", Enabled = true, Clickable = true},
			{Label = "智能目标", Enabled = true, Clickable = true},
			{Label = "更多移动", Enabled = true, Clickable = true},
			},
			ButtonWidth = 129,  -- 按钮宽度
			ButtonHeight = 34,  -- 按钮高度
	},

	NextSkillUI = {
		WindowName = "MhachBLM BLM NextSkill",  -- 窗口名称
		IsVisible = true,                  -- 窗口是否可见
		WindowFlags = GUI.WindowFlags_AlwaysAutoResize  -- 窗口标志
					| GUI.WindowFlags_NoTitleBar
					| GUI.WindowFlags_NoResize
					| GUI.WindowFlags_NoCollapse,
	},

	HotBarUI = {
		WindowName = "MhachBLM BLM HotBar",  -- 窗口名称
		IsVisible = true,                  -- 窗口是否可见
		WindowFlags = GUI.WindowFlags_AlwaysAutoResize  -- 窗口标志
					| GUI.WindowFlags_NoTitleBar
					| GUI.WindowFlags_NoResize
					| GUI.WindowFlags_NoCollapse,
	},

	Target = {
		aoe_num = 0,
	},

	isPVE = true,
	isPVP = false,
	ispve = true,
	ispvp = false
}

MhachBLM.Settings = {
    Debug = true,
	FuckAnimation = false,  --是否开启了动画锁
	RedPlayer = false,   --红丸循环
	Between_the_Aetherial = false,  --魔纹步替代以太步
	ShowNextSkill = false,  --显示接下来的技能
	NewCombo = false,
	ShowHotBar = false,   --显示热键栏
	Lock = false,  --是否在战斗外禁用热键栏
	DotBlackList = {}  --dot黑名单
}

MhachBLM.GUI = {
    open = false,
    visible = true,
    name = "MhachBLM",
}

MhachBLM.classes = {
    [FFXIV.JOBS.BLACKMAGE] = true,
}

MhachBLM.region = {1, 2, 3}
--local MinionPath = GetStartupPath()
--local LuaPath = GetLuaModsPath()
--local ModulePath = LuaPath .. [[ACR\CombatRoutines\MhachBLM\]]
--local ModuleSettings = ModulePath .. [[Settings.lua]]
--local ImageFolder = ModulePath .. [[Images\]]

--[[更改buff id
火苗 165
云砧 3870
三连咏唱 1211
魔纹环 738
黑魔纹 737
闪雷
震雷
爆雷
霹雷
高闪雷 3871
高震雷 3872

]]
MhachBLM.BuffID = {
    Huomiao = 165,
    Yunzhen = 3870,
	Sanlian = 1211,
	Heimowen = 737,
	Mowen = 738,
	Dot3 = 3871,
	AoeDot3 = 3872
}

function MhachBLM.BLMGUI.ApplyButtonStyle(enabled, customStyle)
    local DefaultEnabledColor = {0.47, 0.56, 0.24, 1.0}    -- 绿色（True）   
    local DefaultDisabledColor = {0.5, 0.5, 0.5, 1.0}   -- 灰色（False）
    local HoveredColor = {0.47, 0.56, 0.24, 1.0}           -- 启动状态下悬停    
    local ActiveColor = {0.4, 0.1, 0.5, 1.0}            -- 启动状态下点击    

    -- 如果存在自定义样式，优先使用
    if customStyle then
	    if enabled then
            GUI:PushStyleColor(GUI.Col_Button, unpack(customStyle.Button))
            GUI:PushStyleColor(GUI.Col_ButtonHovered, unpack(customStyle.Hovered))
            GUI:PushStyleColor(GUI.Col_ButtonActive, unpack(customStyle.Active))
		else
		    GUI:PushStyleColor(GUI.Col_Button, unpack(customStyle.Dark))
            GUI:PushStyleColor(GUI.Col_ButtonHovered, unpack(customStyle.Dark))
            GUI:PushStyleColor(GUI.Col_ButtonActive, unpack(customStyle.Dark))
		end
    else
        -- 根据状态使用默认样式
        if enabled then
            GUI:PushStyleColor(GUI.Col_Button, unpack(DefaultEnabledColor))
            GUI:PushStyleColor(GUI.Col_ButtonHovered, unpack(HoveredColor))
            GUI:PushStyleColor(GUI.Col_ButtonActive, unpack(ActiveColor))
        else
            GUI:PushStyleColor(GUI.Col_Button, unpack(DefaultDisabledColor))
            GUI:PushStyleColor(GUI.Col_ButtonHovered, unpack(DefaultDisabledColor))
            GUI:PushStyleColor(GUI.Col_ButtonActive, unpack(DefaultDisabledColor))
        end
    end
end

function MhachBLM.HasTarget()     --检查是否有有效目标
	if TensorCore.mGetTarget()~=nil and TensorCore.mGetTarget().attackable then
		return true
	else
		return false
	end
end

AnyoneCore.Settings.PrepullHelper.peloton = false


-- This is to have a different logic for AOE healing if player is in a donjon or raid

MhachBLM.Skills = {}
MhachBLM.PrognosisTime = 0
MhachBLM.CurrentDPSTarget = 0
MhachBLM.HasDPSTarget = false


function MhachBLM.DebugPrint(...)
    if MhachBLM.Settings.Debug then
        d("[MhachBLM] " .. ...)
    end
end


function MhachBLM.GetSkill(SkillID)
    if not SkillID then
        return nil
    end
    if not MhachBLM.Skills[SkillID] then
        MhachBLM.DebugPrint("Skill not found: " .. tostring(SkillID))
    else
        return MhachBLM.Skills[SkillID]
    end
end

-- 这个工具函数用于注册一项技能并保存一些数据，这样我们就不必每次都请求它了。----------------------------------------------------------------------------------------------------------------------------------------------------
function MhachBLM.RegisterSkill(action, isGCD, tag)
	tag = tag or "Default"  --传入一个tag，标记为AOE，DOT以特殊处理
    if action then
        MhachBLM.Skills[action.id] = {
			name = action.name,
            IsGCD = isGCD,  -- 是否为gcd技能
			holdTime = 0,  --延后时间，秒
			delayTime = 0, --acr队列时间，秒
			iconPath =  GetLuaModsPath() .. [[ACR\CombatRoutines\MhachBLM\Icons\]] .. action.id .. ".png",  --图片路径
			showHotbar = false,  --是否显示hotbar
			changed = false,  --按钮中间值
			keyBind = nil,  --绑定的按键
			keyName = nil, --按键名称
			keyC = false,  --Ctrl
			keyA = false,  --ALT
			keyS = false,  --Shift
			keyBinding = false,  --是否正在绑定按键
			inHotbarList = false,  --是否在热键栏队列
			tag = tag,
        }
        MhachBLM.DebugPrint("Registered Skill: " .. action.name .. " (" .. action.id .. ")")
    else
		--特殊技能处理，比如锁定面向
		if tag == "LockFace" then
			MhachBLM.Skills[-1] = {
				name = tag,
				IsGCD = isGCD,  -- 是否为gcd技能
				holdTime = 0,  --延后时间，秒
				delayTime = 0, --acr队列时间，秒
				iconPath =  GetLuaModsPath() .. [[ACR\CombatRoutines\MhachBLM\Icons\]] .. "face.png",  --图片路径
				showHotbar = false,  --是否显示hotbar
				changed = false,  --按钮中间值
				keyBind = nil,  --绑定的按键
				keyName = nil, --按键名称
				keyC = false,  --Ctrl
				keyA = false,  --ALT
				keyS = false,  --Shift
				keyBinding = false,  --是否正在绑定按键
				inHotbarList = false,  --是否在热键栏队列
				tag = tag,
			}

		else
			MhachBLM.DebugPrint("Action with ID " .. action.id .. " could not be find, is it valid ? Report to a dev.")
		end
    end
end

--技能id和是否为gcd-------------------------------------------------------------------------------------------------------------------------------------
local Ice_1 = ActionList:Get(1, 142)
MhachBLM.RegisterSkill(Ice_1, true)  --冰结

local Fire_1 = ActionList:Get(1, 141)
MhachBLM.RegisterSkill(Fire_1, true)  --火炎

local Xing_Ling = ActionList:Get(1, 149)
MhachBLM.RegisterSkill(Xing_Ling, false) --星灵移位

local DOT_1 = ActionList:Get(1, 144)
MhachBLM.RegisterSkill(DOT_1, true, "DOT") --闪雷

local Ice_2 = ActionList:Get(1, 25793)
MhachBLM.RegisterSkill(Ice_2, true) --冰冻

local Beng_Kui = ActionList:Get(1, 156)
MhachBLM.RegisterSkill(Beng_Kui, true) --崩溃

local Fire_2 = ActionList:Get(1, 147)
MhachBLM.RegisterSkill(Fire_2, true, "AOE") --烈炎

local DOT_AOE_1 = ActionList:Get(1, 7447)
MhachBLM.RegisterSkill(DOT_AOE_1, true, "AOE") --震雷

local Mo_Zhao = ActionList:Get(1, 157)
MhachBLM.RegisterSkill(Mo_Zhao, false) --魔罩

local Fire_3 = ActionList:Get(1, 152)
MhachBLM.RegisterSkill(Fire_3, true) --爆炎

local Yi_Tai = ActionList:Get(1, 155)
MhachBLM.RegisterSkill(Yi_Tai, false, "MO") --以太步

local Mo_Quan = ActionList:Get(1, 158)
MhachBLM.RegisterSkill(Mo_Quan, false) --魔泉

local Ice_3 = ActionList:Get(1, 154)
MhachBLM.RegisterSkill(Ice_3, true) --冰封

local Ling_Ji_Hun = ActionList:Get(1, 16506)
MhachBLM.RegisterSkill(Ling_Ji_Hun, true) --灵极魂

local Ice_AOE = ActionList:Get(1, 159)
MhachBLM.RegisterSkill(Ice_AOE, true, "AOE") --玄冰

local DOT_2 = ActionList:Get(1, 153)
MhachBLM.RegisterSkill(DOT_2, true, "DOT") --暴雷

local He_Bao = ActionList:Get(1, 162)
MhachBLM.RegisterSkill(He_Bao, true, "AOE") --核爆

local Mo_Wen = ActionList:Get(1, 3573)
MhachBLM.RegisterSkill(Mo_Wen, false) --黑魔纹

local Ice_4 = ActionList:Get(1, 3576)
MhachBLM.RegisterSkill(Ice_4, true) --冰澈

local Fire_4 = ActionList:Get(1, 3577)
MhachBLM.RegisterSkill(Fire_4, true) --炽炎

local Mo_Wen_Bu = ActionList:Get(1, 7419)
MhachBLM.RegisterSkill(Mo_Wen_Bu, false) --魔纹步

local DOT_AOE_2 = ActionList:Get(1, 7420)
MhachBLM.RegisterSkill(DOT_AOE_2, true, "AOE") --霹雷

local San_Lian = ActionList:Get(1, 7421)
MhachBLM.RegisterSkill(San_Lian, false) --三连咏唱

local Hui_Zhuo = ActionList:Get(1, 7422)
MhachBLM.RegisterSkill(Hui_Zhuo, true, "AOE") --秽浊

local Jue_Wang = ActionList:Get(1, 16505)
MhachBLM.RegisterSkill(Jue_Wang, true) --绝望

local Yi_Yan = ActionList:Get(1, 16507)
MhachBLM.RegisterSkill(Yi_Yan, true) --异言

local Fire_5 = ActionList:Get(1, 25794)
MhachBLM.RegisterSkill(Fire_5, true, "AOE") --高烈炎

local Ice_5 = ActionList:Get(1, 25795)
MhachBLM.RegisterSkill(Ice_5, true, "AOE") --高冰冻

local Xiang_Shu = ActionList:Get(1, 25796)
MhachBLM.RegisterSkill(Xiang_Shu, false) --详述

local DOT_3 = ActionList:Get(1, 36986)
MhachBLM.RegisterSkill(DOT_3, true, "DOT") --高闪雷

local DOT_AOE_3 = ActionList:Get(1, 36987)
MhachBLM.RegisterSkill(DOT_AOE_3, true, "AOE") --高震雷

local Mo_Wen_Reset = ActionList:Get(1, 36988)
MhachBLM.RegisterSkill(Mo_Wen_Reset, false) --魔纹重置

local Yao_Xing = ActionList:Get(1, 36989)
MhachBLM.RegisterSkill(Yao_Xing, true, "AOE") --耀星

local Bei_Lun = ActionList:Get(1, 25797)
MhachBLM.RegisterSkill(Bei_Lun, true) --悖论

local Hun_Luan = ActionList:Get(1, 7560)
MhachBLM.RegisterSkill(Hun_Luan, false, "Target") --昏乱

local Cui_Mian = ActionList:Get(1, 25880)
MhachBLM.RegisterSkill(Cui_Mian, true) --催眠

local Xing_Meng = ActionList:Get(1, 7562)
MhachBLM.RegisterSkill(Xing_Meng, false) --醒梦

local Ji_Ke = ActionList:Get(1, 7561)
MhachBLM.RegisterSkill(Ji_Ke, false) --即刻咏唱

local Chen_Wen = ActionList:Get(1, 7559)
MhachBLM.RegisterSkill(Chen_Wen, false) --沉稳咏唱

local LB = ActionList:Get(1, 203)
MhachBLM.RegisterSkill(LB, false) --极限技1

local LB2 = ActionList:Get(1, 204)
MhachBLM.RegisterSkill(LB2, false) --极限技2

local LB3 = ActionList:Get(1, 205)
MhachBLM.RegisterSkill(LB3, false) --极限技3

local Sprint = ActionList:Get(1, 3)
MhachBLM.RegisterSkill(Sprint, false) -- 冲刺

MhachBLM.RegisterSkill(nil, false, "LockFace") -- 自动面向

local AutoAttack = ActionList:Get(5, 1).name  --自动攻击
local sortedIds = {}  --使技能按id排列
for id in pairs(MhachBLM.Skills) do
    table.insert(sortedIds, id)
end

table.sort(sortedIds)  -- 对id进行排序

--------------------------------------------------------------------------------------------------------------------------------------------
local Queue = {}
Queue.__index = Queue

--初始化队列
function Queue.new()
	return setmetatable({
		items = {}, --存储元素
		head = 1,  --队首指针，指向第一个元素
		tail = 1  --队尾指针，指向下一个入队元素
	},Queue)
end

--入队
function Queue:enqueue(value)
	self.items[self.tail] = value
	self.tail = self.tail + 1
end

--检查队列中有无指定元素
function Queue:contains(value)
	for i = self.head, self.tail - 1 do
		if self.items[i] == value then
			return true
		end
	end
	return false
end

function Queue:enqueueUnic(value)  --不允许插入重复值
	-- 遍历当前队列元素，检查是否已存在
    if self:contains(value) then
		return false
	end
    -- 不存在重复值，正常入队
    self.items[self.tail] = value
    self.tail = self.tail + 1
    return true
end

--出队
function Queue:dequeue()
	if self:isEmpty() then return nil end
	local value = self.items[self.head]
	self.items[self.head] = nil  --释放内存
	self.head = self.head + 1
	return value
end

--查看队首元素（不移除）
function Queue:peek()
	return self.items[self.head]
end

--获取队列元素数量
function Queue:size()
	return self.tail - self.head
end



--清除队列所有指定元素
function Queue:removeAll(value)
	local newItems = {}
	local newHead = 1
	local removedCount = 0

	for i = self.head, self.tail - 1 do
		if self.items[i] ~= value then
			newItems[newHead] = self.items[i]
			newHead = newHead + 1
		else
			removedCount = removedCount + 1
		end
	end

	self.items = newItems
	self.head = 1
	self.tail = newHead

	return removedCount  -- 返回被移除的元素数量
end

--检查队列是否为空
function Queue:isEmpty()
	return self.head >= self.tail
end

--清空队列
function Queue:clear()
	self.items = {}
	self.head = 1
	self.tail = 1
end
----------------------------------------------------------------------------------------------------------------

local ParadoxGauge = {[3] = true, [7] = true, [11] = true, [15] = true, [19] = true, [23] = true, [27] = true}  --悖论量谱快速鉴定
local DotBuffs = {[161] = true, [162] = true, [163] = true, [1210] = true, [3871] = true, [3872] = true }
local enemys = nil
local target = nil
local moTarget = nil
local TargetTuanfu = {3849, 1221} --目标团辅
local PlayerTuanfu = {1878, 3889, 786, 1185, 2599, 2964, 141, 1822, 1825, 2703, 1297, 3685}  --角色团辅
local ShunFa = {167, 1211}  --瞬发buff
local PlayerSkills = Queue:new()  --用户自定义循环列表
local HotbarSkills = Queue:new()  --热键栏技能队列
local HoldList = {}  --hold技能列表
local lastTime = 0
local nowTime = 0
local fpsTime = 0
local LuaPath = GetLuaModsPath()
local ModulePath = LuaPath .. [[ACR\CombatRoutines\MhachBLM\]]
local Module = ModulePath .. [[Test.lua]]
local Rotation = ModulePath .. [[MhachBLMRotation.lua]]
local Settings = ModulePath .. [[Settings.lua]]
local HotbarSettings = ModulePath .. [[HotbarSettings.lua]]
local Icons = LuaPath .. [[ACR\CombatRoutines\MhachBLM\Icons\]]
local defultIcon = Icons .. "disable.png"
local MhachBLMTest = {}
local InstantWindow = false   --是否需要瞬发窗口
local ForceAbl = false   --是否强制硬插
local nextGCD = nil  --下一个gcd技能
local nextAbl = nil --下一个能力技
local lastSkill = nil  --上一个技能
local lastABLTime = 0  --上一个能力技的全局时间ms
local lastGCDTime = 0  --上一个gcd技能的全局时间ms
local ablTickTime = 0  --能力技加入队列全局时间ms
local gcdTickTime = 0  --gcd加入队列全局时间ms
local settingUI = true  --acr设置主界面
local hotbarUI = false  --hotbar设置界面

local faceX = nil  --面向坐标
local faceY = nil
local faceZ = nil

local speed_B = 2.4000000953674
local speed_F = 6
local speed_S = 2.4000000953674
local speed_W = 2.4000000953674
MhachBLM.prepull = false
--------------------------------------------------------------------------------------------------
local function SaveHotBar()
	local tbl = {}
	for _, id in ipairs(sortedIds) do
		local skill = MhachBLM.Skills[id]
		tbl[id] = {
			showHotbar = skill.showHotbar,  --是否显示hotbar
			keyBind = skill.keyBind,  --绑定的按键
			keyName = skill.keyName, --按键名称
			keyC = skill.keyC,  --Ctrl
			keyA = skill.keyA,  --ALT
			keyS = skill.keyS,  --Shift
		}
		if skill.keyBind == nil or skill.keyBind == -1 then
			tbl[id].keyBind = -1
			tbl[id].keyName = "None"
		end
	end
	FileSave(HotbarSettings,tbl)
end

local function LoadHotBar()
	local tbl = FileLoad(HotbarSettings)
	if tbl ~= nil then
		for _, id in ipairs(sortedIds) do
			local skill = MhachBLM.Skills[id]
			skill.showHotbar = tbl[id].showHotbar
			skill.keyBind = tbl[id].keyBind
			skill.keyName = tbl[id].keyName
			skill.keyC = tbl[id].keyC
			skill.keyA = tbl[id].keyA
			skill.keyS = tbl[id].keyS
		end
	end
end

local function LoadSettings()
	local tbl = FileLoad(Settings)
	if tbl ~= nil then
		MhachBLM.BLM.CD = tbl.Value.CD
		MhachBLM.BLM.DOT = tbl.Value.DOT
		MhachBLM.BLM.AOE = tbl.Value.AOE
		MhachBLM.BLM.Potion = tbl.Value.Potion
		MhachBLM.BLM.Polyglot = tbl.Value.Polyglot
		MhachBLM.BLM.Ley_Lines = tbl.Value.Ley_Lines
		MhachBLM.BLM.Manafont = tbl.Value.Manafont
		MhachBLM.BLM.Amplifier = tbl.Value.Amplifier
		MhachBLM.BLM.Triplecast = tbl.Value.Triplecast
		MhachBLM.BLM.Burn = tbl.Value.Burn
		MhachBLM.BLM.Smart_Target = tbl.Value.Smart_Target
		MhachBLM.BLM.More_Move = tbl.Value.More_Move
		MhachBLM.Settings.Debug = tbl.Value.Debug
		MhachBLM.Settings.FuckAnimation = tbl.Value.FuckAnimation
		MhachBLM.Settings.RedPlayer = tbl.Value.RedPlayer
		MhachBLM.Settings.Between_the_Aetherial = tbl.Value.Between_the_Aetherial
		MhachBLM.Settings.ShowNextSkill = tbl.Value.ShowNextSkill
		MhachBLM.Settings.NewCombo = tbl.Value.NewCombo
		MhachBLM.Settings.ShowHotBar = tbl.Value.ShowHotBar
		MhachBLM.Settings.Lock = tbl.Value.Lock
		MhachBLM.Settings.DotBlackList = tbl.Value.DotBlackList
	end
end

local function SaveSettings()
	local tbl =
{
	Value =
	{
		AOE = true,
		Amplifier = true,
		Burn = true,
		CD = true,
		DOT = true,
		Debug = true,
		Ley_Lines = true,
		Manafont = true,
		More_Move = true,
		NewCombo = true,
		Polyglot = true,
		Potion = true,
		Smart_Target = true,
		Triplecast = true,
	},
}
	tbl.Value.CD = MhachBLM.BLM.CD
	tbl.Value.DOT = MhachBLM.BLM.DOT
	tbl.Value.AOE = MhachBLM.BLM.AOE
	tbl.Value.Potion = MhachBLM.BLM.Potion
	tbl.Value.Polyglot = MhachBLM.BLM.Polyglot
	tbl.Value.Ley_Lines = MhachBLM.BLM.Ley_Lines
	tbl.Value.Manafont = MhachBLM.BLM.Manafont
	tbl.Value.Amplifier = MhachBLM.BLM.Amplifier
	tbl.Value.Triplecast = MhachBLM.BLM.Triplecast
	tbl.Value.Burn = MhachBLM.BLM.Burn
	tbl.Value.Smart_Target = MhachBLM.BLM.Smart_Target
	tbl.Value.More_Move = MhachBLM.BLM.More_Move
	tbl.Value.Debug = MhachBLM.Settings.Debug
	tbl.Value.FuckAnimation = MhachBLM.Settings.FuckAnimation
	tbl.Value.RedPlayer = MhachBLM.Settings.RedPlayer
	tbl.Value.Between_the_Aetherial = MhachBLM.Settings.Between_the_Aetherial
	tbl.Value.ShowNextSkill = MhachBLM.Settings.ShowNextSkill
	tbl.Value.NewCombo = MhachBLM.Settings.NewCombo
	tbl.Value.ShowHotBar = MhachBLM.Settings.ShowHotBar
	tbl.Value.Lock = MhachBLM.Settings.Lock
	tbl.Value.DotBlackList = MhachBLM.Settings.DotBlackList
	FileSave(Settings,tbl)
end

--------------------------------------------------------------------------------------------------------------------------------   键位设置

MhachBLM.KeyCodes =
{
	[1] =  { key = 33, name = "PAGE UP", },
	[2] =  { key = 35, name = "END", },
	[3] =  { key = 37, name = "LEFT ARROW", },
	[4] =  { key = 39, name = "RIGHT ARROW", },
	[5] =  { key = 41, name = "SELECT", },
	[6] =  { key = 43, name = "EXECUTE", },
	[7] =  { key = 45, name = "INS", },
	[8] =  { key = 47, name = "HELP", },
	[9] =  { key = 49, name = "1", },
	[10] =  { key = 51, name = "3", },
	[11] =  { key = 53, name = "5", },
	[12] =  { key = 55, name = "7", },
	[13] =  { key = 57, name = "9", },
	[14] =  { key = 251, name = "Zoom", },
	[15] =  { key = 66, name = "B", },
	[16] =  { key = 70, name = "F", },
	[17] =  { key = 74, name = "J", },
	[18] =  { key = 78, name = "N", },
	[19] =  { key = 82, name = "R", },
	[20] =  { key = 86, name = "V", },
	[21] =  { key = 90, name = "Z", },
	[22] =  { key = 98, name = "Numpad 2", },
	[23] =  { key = 102, name = "Numpad 6", },
	[24] =  { key = 106, name = "Multiply", },
	[25] =  { key = 110, name = "Decimal", },
	[26] =  { key = 114, name = "F3", },
	[27] =  { key = 118, name = "F7", },
	[28] =  { key = 122, name = "F11", },
	[29] =  { key = 126, name = "F15", },
	[30] =  { key = 132, name = "F21", },
	[31] =  { key = 164, name = "Left MENU", },
	[32] =  { key = 172, name = "Browser Start and Home", },
	[33] =  { key = 180, name = "Start Mail", },
	[34] =  { key = 188, name = ",", },
	[35] =  { key = 220, name = "|", },
	[36] =  { key = 1, name = "Left mouse button", },
	[37] =  { key = 2, name = "Right mouse button", },
	[38] =  { key = 133, name = "F22", },
	[39] =  { key = 165, name = "Right MENU", },
	[40] =  { key = 173, name = "Volume Mute", },
	[41] =  { key = 181, name = "Select Media", },
	[42] =  { key = 3, name = "Control-break processing", },
	[43] =  { key = 221, name = "]}", },
	[44] =  { key = 229, name = "IME PROCESS", },
	[45] =  { key = 4, name = "Middle mouse button", },
	[46] =  { key = 67, name = "C", },
	[47] =  { key = 71, name = "G", },
	[48] =  { key = 75, name = "K", },
	[49] =  { key = 5, name = "X1 mouse button", },
	[50] =  { key = 83, name = "S", },
	[51] =  { key = 87, name = "W", },
	[52] =  { key = 91, name = "Left Windows key", },
	[53] =  { key = 6, name = "X2 mouse button", },
	[54] =  { key = 99, name = "Numpad 3", },
	[55] =  { key = 103, name = "Numpad 7", },
	[56] =  { key = 107, name = "Add", },
	[57] =  { key = 111, name = "Divide", },
	[58] =  { key = 115, name = "F4", },
	[59] =  { key = 119, name = "F8", },
	[60] =  { key = 123, name = "F12", },
	[61] =  { key = 8, name = "BACKSPACE", },
	[62] =  { key = 134, name = "F23", },
	[63] =  { key = 9, name = "TAB", },
	[64] =  { key = 166, name = "Browser Back", },
	[65] =  { key = 174, name = "Volume Down", },
	[66] =  { key = 182, name = "Start Application 1", },
	[67] =  { key = 12, name = "CLEAR", },
	[68] =  { key = 13, name = "ENTER", },
	[69] =  { key = 222, name = "Quote", },
	[70] =  { key = 230, name = "OEM specific", },
	[71] =  { key = 246, name = "Attn", },
	[72] =  { key = 254, name = "Clear", },
	[73] =  { key = 19, name = "PAUSE", },
	[74] =  { key = 20, name = "CAPS LOCK", },
	[75] =  { key = 21, name = "IME Kana mode", },
	[76] =  { key = 23, name = "IME Junja mode", },
	[77] =  { key = 24, name = "IME final mode", },
	[78] =  { key = 25, name = "IME Kanji mode", },
	[79] =  { key = 27, name = "ESC", },
	[80] =  { key = 28, name = "IME convert", },
	[81] =  { key = 29, name = "IME nonconvert", },
	[82] =  { key = 30, name = "IME accept", },
	[83] =  { key = 31, name = "IME mode change request", },
	[84] =  { key = 32, name = "SPACEBAR", },
	[85] =  { key = 34, name = "PAGE DOWN", },
	[86] =  { key = 36, name = "HOME", },
	[87] =  { key = 38, name = "UP ARROW", },
	[88] =  { key = 40, name = "DOWN ARROW", },
	[89] =  { key = 42, name = "PRINT", },
	[90] =  { key = 44, name = "PRINT SCREEN", },
	[91] =  { key = 46, name = "DEL", },
	[92] =  { key = 48, name = "0", },
	[93] =  { key = 50, name = "2", },
	[94] =  { key = 52, name = "4", },
	[95] =  { key = 54, name = "6", },
	[96] =  { key = 56, name = "8", },
	[97] =  { key = 231, name = "VK_Packet", },
	[98] =  { key = 247, name = "CrSel", },
	[99] =  { key = 68, name = "D", },
	[100] =  { key = 72, name = "H", },
	[101] =  { key = 76, name = "L", },
	[102] =  { key = 80, name = "P", },
	[103] =  { key = 84, name = "T", },
	[104] =  { key = 88, name = "X", },
	[105] =  { key = 92, name = "Right Windows key", },
	[106] =  { key = 96, name = "Numpad 0", },
	[107] =  { key = 100, name = "Numpad 4", },
	[108] =  { key = 104, name = "Numpad 8", },
	[109] =  { key = 108, name = "Separator", },
	[110] =  { key = 112, name = "F1", },
	[111] =  { key = 116, name = "F5", },
	[112] =  { key = 120, name = "F9", },
	[113] =  { key = 124, name = "F13", },
	[114] =  { key = 128, name = "F17", },
	[115] =  { key = 144, name = "NUM LOCK", },
	[116] =  { key = 160, name = "Left SHIFT", },
	[117] =  { key = 168, name = "Browser Refresh", },
	[118] =  { key = 176, name = "Next Track", },
	[119] =  { key = 192, name = "`~", },
	[120] =  { key = 248, name = "ExSel", },
	[121] =  { key = -1, name = "None", },
	[122] =  { key = 129, name = "F18", },
	[123] =  { key = 145, name = "SCROLL LOCK", },
	[124] =  { key = 161, name = "Right SHIFT", },
	[125] =  { key = 169, name = "Browser Stop", },
	[126] =  { key = 177, name = "Previous Track", },
	[127] =  { key = 225, name = "OEM specific", },
	[128] =  { key = 249, name = "Erase EOF", },
	[129] =  { key = 65, name = "A", },
	[130] =  { key = 69, name = "E", },
	[131] =  { key = 73, name = "I", },
	[132] =  { key = 77, name = "M", },
	[133] =  { key = 81, name = "Q", },
	[134] =  { key = 85, name = "U", },
	[135] =  { key = 89, name = "Y", },
	[136] =  { key = 93, name = "Applications key", },
	[137] =  { key = 97, name = "Numpad 1", },
	[138] =  { key = 101, name = "Numpad 5", },
	[139] =  { key = 105, name = "Numpad 9", },
	[140] =  { key = 109, name = "Subtract", },
	[141] =  { key = 113, name = "F2", },
	[142] =  { key = 117, name = "F6", },
	[143] =  { key = 121, name = "F10", },
	[144] =  { key = 125, name = "F14", },
	[145] =  { key = 130, name = "F19", },
	[146] =  { key = 162, name = "Left CONTROL", },
	[147] =  { key = 170, name = "Browser Search", },
	[148] =  { key = 178, name = "Stop Media", },
	[149] =  { key = 186, name = ";:", },
	[150] =  { key = 253, name = "PA1", },
	[151] =  { key = 226, name = "VK_OEM_102", },
	[152] =  { key = 252, name = "VK_NONAME", },
	[153] =  { key = 223, name = "", },
	[154] =  { key = 250, name = "Play", },
	[155] =  { key = 219, name = "[{", },
	[156] =  { key = 191, name = "/?", },
	[157] =  { key = 190, name = ".", },
	[158] =  { key = 189, name = "-_", },
	[159] =  { key = 187, name = "=+", },
	[160] =  { key = 183, name = "Start Application 2", },
	[161] =  { key = 179, name = "Play/Pause Media", },
	[162] =  { key = 175, name = "Volume Up", },
	[163] =  { key = 171, name = "Browser Favorites", },
	[164] =  { key = 167, name = "Browser Forward", },
	[165] =  { key = 163, name = "Right CONTROL", },
	[166] =  { key = 135, name = "F24", },
	[167] =  { key = 131, name = "F20", },
	[168] =  { key = 127, name = "F16", },
	[169] =  { key = 95, name = "Computer Sleep", },
	[170] =  { key = 79, name = "O", },
}


local function IsKeyDown()    --检测按键
	local Key, Shift, Control, Alt, KeyChanged
	for k,v in pairs(MhachBLM.KeyCodes) do
		if GUI:IsKeyDown(v.key) then
			Key = v.key
			KeyName = v.name
			KeyChanged = true
		end
	end
	if Key == nil then Key = -1 KeyName = "None" end
	if KeyChanged == nil then KeyChanged = false end
	if GUI:IsKeyDown(16) then
		Shift = true
	else
		Shift = false
	end
	if GUI:IsKeyDown(17) then
		Control = true
	else
		Control = false
	end
	if GUI:IsKeyDown(18) then
		Alt = true
	else
		Alt = false
	end
	return Key, KeyName, Control, Alt, Shift, KeyChanged
end

local function KeybindsPressed(a)   --检测绑定的按键按下
	if a.keyBind == nil or a.keyC == nil or a.keyA == nil or a.keyS == nil then return false end
	if not GUI:IsKeyPressed(a.keyBind) then return false end
	if not GUI:IsKeyDown(17) and a.keyC == true then return false end
	if not GUI:IsKeyDown(18) and a.keyA == true then return false end
	if not GUI:IsKeyDown(16) and a.keyS == true then return false end
	return true
end

local function AdjustKeyName(a)   --调整按键名称，显示组合按键
	if a.keyBind == nil or a.keyC == nil or a.keyA == nil or a.keyS == nil then return "None" end
	for k,v in pairs(MhachBLM.KeyCodes) do
		if a.keyBind ~= nil and a.keyBind == v.key then
			return v.name
		end
	end
	return "None"
end

local function KeyBinded(a)   --检查是否绑定了按键
	if a.keyC or a.keyS or a.keyA then
		return true
	elseif a.keyBind ~= nil and a.keyBind ~= -1 then
		return true
	end
	return false
end



--n.key, n.keyname, n.modifierC, n.modifierA, n.modifierS, changed = RoseCore.IsKeyDown()


--[[if RoseCore.KeybindsPressed(v) then
	v.bool = not v.bool
	save(true)
end]]


local function splitString(inputStr, delimiter)   --把字符串按分隔符转化为list
    local list = {}
    for match in string.gmatch(inputStr, "[^" .. delimiter .. "]+") do
        table.insert(list, tonumber(match))
    end
    return list
end

local function listToString(list, delimiter)  --把list按分隔符转化为string
	if list == nil then
		return nil
	end
    delimiter = delimiter or ","  -- 默认分隔符为逗号
    local result = {}
    for i, v in ipairs(list) do
        result[i] = tostring(v)  -- 将每个元素转为字符串
    end
    return table.concat(result, delimiter)
end










-------------------------------------------------------本地存储优化性能
local player = nil
local playerid = nil
local incombat = nil
local moving = nil
local fire_ice = nil
local ice_heart = nil
local tongxiao = nil
local beilun = nil
local mp = 0
local lastcast = nil
local alive = nil
local tongxiaoTime = nil
local level = nil

local function SetValue()  --为本地变量赋值
	player = TensorCore.mGetPlayer()
	playerid = player.id
	incombat = player.incombat
	moving = player:IsMoving()
	fire_ice = player.gauge[2]
	ice_heart = player.gauge[1]
	tongxiao = player.gauge[5]
	beilun = player.gauge[3]
	mp = player.mp.current
	lastcast = player.castinginfo.lastcastid
	alive = player.alive
	tongxiaoTime = player.gaugetest[2] --剩余秒数*4
	level = player.level
	target = TensorCore.mGetTarget()
	if player.castinginfo.timesincecast <= 100 then
		if nextAbl ~= nil then
			if lastcast == nextAbl.id then
				lastSkill = nextAbl
				nextAbl = nil
			end
		end
		if nextGCD ~= nil then
			if lastcast == nextGCD.id then
				lastSkill = nextGCD
				nextGCD = nil
			end
		end
	end
end
-------------------------------------------------------


local function IsSkillGCD(SkillID)
	if SkillID == nil then
        return false
    end
    if MhachBLM.Skills[SkillID] == nil then
        return true -- GCD by default
    end
    if MhachBLM.Skills[SkillID].IsGCD then
        return true
    end
    return false
end

local function BurnTime(target)  --检查身上或者目标身上是否有团辅
	for _, buff in pairs(PlayerTuanfu) do
		if TensorCore.hasBuff(player, buff) then return true end
	end

	for _, buff in pairs(TargetTuanfu) do
		if TensorCore.hasBuff(target, buff) then return true end
	end
	return false
end

local function ShunFaBuff()  --检查自己身上有无瞬发buff
	for _, buff in pairs(ShunFa) do
		if TensorCore.hasBuff(player, buff) then return true end
	end
	return false
end
---------------------------------------------------------------------------------------
--[[local function CalHold()  --计算hold时间逻辑
	for _,i in ipairs(HoldList) do
		MhachBLM.Skills[i].holdTime = MhachBLM.Skills[i].holdTime - fpsTime
		--d(MhachBLM.Skills[i].holdTime)
		if MhachBLM.Skills[i].holdTime <= 0 then
			MhachBLM.Skills[i].holdTime = 0
			MhachBLM.MoveHold(i)
		end
	end
end]]

function MhachBLM.HoldAction(id, time)  --hold某个技能一段时间
	if type(id) ~= "number" then
		id = id.id
	end
	MhachBLM.Skills[id].holdTime = time
	MhachBLM.DebugPrint(id.."holdtime:"..time)
end

--[[function MhachBLM.MoveHold(id)  --移除技能的hold时间
	if type(id) ~= "number" then
		id = id.id
	end
	if not HoldSeen[id] then
		return
	end
	for i = #HoldList,1,-1 do
		if HoldList[i] == id then
			table.remove(HoldList, i)  --从后向前移除技能
			HoldSeen[i] = nil  --移除辅助标记
			MhachBLM.DebugPrint(i.."holdtimeEnd")
			break
		end
	end
end]]

function MhachBLM.MoveHold(id)
	if type(id) ~= "number" then
		id = id.id
	end
	MhachBLM.Skills[id].holdTime = 0
	MhachBLM.DebugPrint(id.."holdtimeEnd")
end

function MhachBLM.ResetHoldList()  --重置hold列表
	HoldList = {}
	HoldSeen = {}
	
end

function MhachBLM.PrintHoldList()  --打印hold列表
	MhachBLM.DebugPrint("HoldList: " .. table.concat(HoldList,","))
end

function MhachBLM.NotHold(id)  --检查技能是否没有hold
	if type(id) ~= "number" then
		id = id.id
	end
	return MhachBLM.Skills[id].holdTime <= 0
end
---------------------------------------------------------------------------------------
function MhachBLM.PlayerCombo(list)  --用户自定义循环，输入{152, 154}这种
	for i = 1,#list do
		PlayerSkills:enqueue(list[i])
	end
end

function MhachBLM.PlayerComboClear()  --清空用户自定义循环
	PlayerSkills:clear()
	nextAbl = nil
	nextGCD = nil
end

function MhachBLM.PlayerComboEmpty() --返回用户循环是否为空
	return PlayerSkills:isEmpty()
end
---------------------------------------------------------------------------------------
local function LockFace()  --锁定面向
	if player:GetSpeed().Forward > 0 then
		speed_B = player:GetSpeed().Backward
		speed_F = player:GetSpeed().Forward
		speed_S = player:GetSpeed().Strafe
		speed_W = player:GetSpeed().Walk
	end
	if MhachBLM.Skills[-1].inHotbarList then
		if Fire_4.cd >= 0 and Fire_4.cd <= 0.5 and not (GUI:IsKeyDown(87) or GUI:IsKeyDown(65) or GUI:IsKeyDown(83) or GUI:IsKeyDown(63)) then
			player:SetSpeed(1, 0, 0, 0, 0)
			SendTextCommand("/automove")
		end
		
		if faceX == nil or faceY == nil or faceZ == nil then
			local x = 2 * player.camera.x - player.pos.x
			local y = player.pos.y
			local z = 2 * player.camera.z - player.pos.z
			player:SetFacing(x, y, z)--面向镜头
		else
			player:SetFacing(faceX, faceY, faceZ)  --面向指定坐标
		end
	end
end

function MhachBLM.LockFaceOn()
	MhachBLM.Skills[-1].inHotbarList = true
end

function MhachBLM.LockFaceOff()
	MhachBLM.Skills[-1].inHotbarList = false
	faceX = nil
	faceY = nil
	faceZ = nil
end

function MhachBLM.LockFacePosition(x, y, z)
	MhachBLM.Skills[-1].inHotbarList = true
	faceX = x
	faceY = y
	faceZ = z
end

-----------------------------------------------------------------------------------------
--这段代码是一个名为 MhachBLM.IsReady 的函数，主要功能是判断游戏中某个GCD技能（action）当前是否可以使用。
--[[local function IsReady(action)
    --先过滤掉 “绝对不能释放技能” 的场景
	if (Fire_4.cd/Fire_4.recasttime) >= 0.99 or Fire_4.cd/Fire_4.recasttime == 0 then  --可以使用GCD技能的时间
		if moving and not ShunFaBuff() then
			if action.casttime == 0 then
				return true
			else
				return false
			end
		else
			return true
		end
	else
		return false
	end
end]]

local function IsReady(action)  --检查技能能否可以进入技能队列
	if level < action.level then  --没学会技能肯定不让用
		return false
	end
	if TensorCore.mGetTarget() ~= nil then
		if IsSkillGCD(action.id) then  --是gcd技能
			return (action:IsReady() or action:IsReady(TensorCore.mGetTarget().id)) and MhachBLM.Skills[action.id].holdTime <= 0
		else
			return (action.cd <= 1 or action:IsReady() or action:IsReady(TensorCore.mGetTarget().id)) and MhachBLM.Skills[action.id].holdTime <= 0
		end
	else
		if IsSkillGCD(action.id) then  --是gcd技能
			return action:IsReady() and MhachBLM.Skills[action.id].holdTime <= 0
		else
			return (action.cd <= 1 or action:IsReady()) and MhachBLM.Skills[action.id].holdTime <= 0
		end
	end
end

local function CanCastGCD()  --可以使用gcd技能

	if Fire_4.recasttime - Fire_4.cd <= 200 or (Fire_4.cd/Fire_4.recasttime) == 0 then
		return true
	end

	if not Fire_4.isoncd then
        return true
    end
    return false
end

local function CanCastABL(time_offset)  --可以使用能力技
	local time_offset = time_offset or 0

    local cdmax = Fire_4.cdmax*1000
    local cd = Fire_4.cd*1000
    local a_lock = 610  --动画锁时间
    local cast_time = a_lock - 188 --释放tick 156 157 186 187 188
    -- local can_cast_value = cdmax - 730
    local can_cast_value = cdmax - 730
	

	if(MhachBLM.Settings.FuckAnimation) then  --如果开启了动画锁，在绿玩时循环能力技通过瞬发窗口插入，hotbar能力技强插
		
		if MhachBLM.Settings.RedPlayer then  --红丸循环--添加一个hotbar判定
			if (Fire_4.cd/Fire_4.recasttime) < 0.9 and (Fire_4.cd/Fire_4.recasttime) > 0.1 then
				return true
			end
			return false
		else--绿完循环
			InstantWindow = true
		end
	else--如果没开动画锁，无论是循环中的能力技还是hotbar均通过瞬发窗口插入
		InstantWindow = true
	end--如果瞬发不够的话，还是要强插

    --1.排除不在能力技范围内
    if (not Fire_4.isoncd) and (not ForceAbl) then
        return false
    end

    --2.排除OGCD技能在偏移了后，是否在末尾730ms内
    if cdmax - (cd+time_offset) < 730 and (not ForceAbl) then
        return false
    end

    --3.确保技能释放大于动画锁-188,实现提前缓存输入技能

    if TimeSince(lastABLTime) <= cast_time and (not ForceAbl) then
        return false
    end

    --4.防止重复缓存输入，（ogcdtime成立，但是actionid没有变或者变了但是没更新）
    if TimeSince(ablTickTime) <= 400 and TimeSince(lastABLTime) > 300 and (not ForceAbl) then
        return false
    end

    --防止在咏唱时输入
    if player.castinginfo.channelingid ~= 0 then
        if player.castinginfo.channeltime < player.castinginfo.casttime - 0.5 and (not ForceAbl) then
            return false
        end
    end

	if ForceAbl then
		return true
	end

    return true
end

local function AblCheck(usehotbar)  --这个是检查能否插入能力技的  usehotbar=false 循环中的能力技  usehotbar=true hotbar的能力技
	if(MhachBLM.Settings.FuckAnimation) then  --如果开启了动画锁，在绿玩时循环能力技通过瞬发窗口插入，hotbar能力技强插
		if MhachBLM.Settings.RedPlayer then  --红丸循环
			if (Fire_4.cd/Fire_4.recasttime) <= 0.9 and (Fire_4.cd/Fire_4.recasttime) >= 0.1 then
				return true
			end
		else  --绿完循环
			if usehotbar and (Fire_4.cd/Fire_4.recasttime) <= 0.9 and (Fire_4.cd/Fire_4.recasttime) >= 0.1 then
				return true
			else
				InstantWindow = true
				return false
			end
		end
	else                  --如果没开动画锁，无论是循环中的能力技还是hotbar均通过瞬发窗口插入
		if (Fire_4.cd/Fire_4.recasttime) <= 0.76 and (Fire_4.cd/Fire_4.recasttime) >= 0.24 then
			return true
		else
			InstantWindow = true
			return false
		end
	end  --如果瞬发不够的话，还是要强插
	return false
end

local function CanLockFace()  --检查是否可以锁定面向，避免在释放技能时锁定面向
	
end

local function MOTargetSet()  --mo目标设置
	local allys = TensorCore.getEntityGroupList("Party")
	local pos = GetMouseInWorldPos()
	local minDistSq = math.huge
	local nearestTarget = nil
	if allys then
		for _, v in pairs(allys) do
			local dx = v.pos.x - pos.x
			local dy = v.pos.y - pos.y
			local dz = v.pos.z - pos.z
			local distSq = dx*dx + dy*dy + dz*dz
			if distSq < minDistSq then
				minDistSq = distSq
				nearestTarget = v
			end
		end
		return nearestTarget.id
	end
	return false
end

--这段代码是一个名为MhachBLM.Action的函数，主要功能是执行一个 "动作"(如游戏中的技能、法术等) 并指定目标。它会先验证动作和目标的有效性，检查玩家与目标的距离是否在动作的有效范围内，最后执行这个动作。
function MhachBLM.Action(action, t)
	if type(action) == "number" then  --将传入的动作参数统一格式
        action = ActionList:Get(1, action)  --如果传入的action是数字 (可能是动作 ID)，就通过ActionList:Get(1, action)把它转换为完整的动作对象 (包含动作名称、范围等信息)。
    end
    if (not (IsSkillGCD(action.id) or MhachBLM.Skills[action.id].tag == "Target")) or (not t) then  --设置默认目标
        t = player
    end

	if IsSkillGCD(action.id) then
		nextGCD = action
		gcdTickTime = Now()
	else
		nextAbl = action
		ablTickTime = Now()	
	end
	--SendTextCommand("/ac " .. AutoAttack)
	if t.distance2d <= action.range or t == player then
		if IsSkillGCD(action.id) then   --GCD技能处理
			if CanCastGCD() then
				MhachBLM.DebugPrint("Casting: " .. action.name .. "Target:" .. t.name)
        		return action:Cast(t.id)
			end
		else   --能力技处理
			if CanCastABL() then
				MhachBLM.DebugPrint("Casting: " .. action.name .. "Target:" .. t.name)
				InstantWindow = false
				if ForceAbl or MhachBLM.Settings.RedPlayer then
					if MhachBLM.Skills[action.id].tag == "MO" then
						if MOTargetSet() then
							return action:Cast(MOTargetSet())
						end
						--return SendTextCommand("/ac " .. action.name .. " <mo>")
					else
						return SendTextCommand("/ac " .. action.name)
					end
				else
					if MhachBLM.Skills[action.id].tag == "MO" and MOTargetSet() then
						return action:Cast(MOTargetSet())
					else
						return action:Cast(t.id)
					end
				end
				ForceAbl = false
				--ForceAbl = false
				--SendTextCommand("/ac " .. action.name)
				--return SendTextCommand("/ac " .. action.name)
			end

		end
	end
end
-----------------------------------------------------------------------------------------------------------------
local function UpdateTimer()
	lastTime = nowTime
	nowTime = Now()
	fpsTime = (nowTime - lastTime)/1000
	if fpsTime > 100 then  --去掉初始计算帧
		fpsTime = 0
	end
	for _, id in ipairs(sortedIds) do
		local skill = MhachBLM.Skills[id]
		skill.holdTime = skill.holdTime - fpsTime
		skill.delayTime = skill.delayTime - fpsTime
		if skill.holdTime < 0 then
			skill.holdTime = 0
		end
		if skill.delayTime < 0 then
			skill.delayTime = 0
		end
	end


	if Player.castinginfo.lastcastid ~= lastSkill and not IsSkillGCD(Player.castinginfo.lastcastid) then
		lastGCDTime = Now()
	end
	lastSkill = Player.castinginfo.lastcastid

end
--------------------------------------------------------------------------------------------------------------------
local function FindTargetsNum(e)  --查找目标数量
	local count = 0
	local itarget = TensorCore.mGetTarget()
	for _, enemy in pairs(e) do
		local distance2d = Distance2DT(itarget.pos, enemy.pos)
		if distance2d <= (5 + enemy.hitradius) then count = count + 1 end
	end
	return count
end

local function FindMaxTargetsInRange(targets, r)  --查找最紧凑敌人
    local maxCount = 0
    local bestTarget = nil
    --local center = nil
	--local itarget = nil
    for _, center in pairs(targets) do
        local count = 0
        for _, itarget in pairs(targets) do
            -- 计算两点之间的距离
            local distance2d = Distance2DT(center.pos, itarget.pos)
            -- 检查是否在半径范围内（包括自身）
            if distance2d <= (r +  itarget.hitradius) then
                count = count + 1
            end
        end

        -- 更新最佳目标
        if count > maxCount then
            maxCount = count
            bestTarget = center
        end
    end
    return bestTarget, maxCount
end

local function MissinMhachBLMyBuff(t, buffids) --查询目标身上是否有自己上的buff,没有则返回真
	for _, buff in pairs(t.buffs) do
		if buff.ownerid == playerid then
			if (buffids[buff.id]) and buff.duration <= 3 then
				return true
			elseif (buffids[buff.id]) and buff.duration > 3 then
				return false
			end
		end
	end
	return true
end

local function FindDotTarget(e)  --智能dot目标选择器
	for _, ienemy in pairs(e) do
		if MissinMhachBLMyBuff(ienemy, DotBuffs) then return ienemy end
	end
	return nil
end




local function TargetSet()  --目标设置器
	if MhachBLM.HasTarget() then
		enemys = TensorCore.entityList("alive,attackable,incombat,maxdistance=25")
		if enemys then
			MhachBLM.Target.aoe_num = FindTargetsNum(enemys)
		end
	else
		MhachBLM.Target.aoe_num = 0
	end

end


local function AOE_Combo()  --AOE循环，已适配全等级
	if (not MhachBLM.BLM.Burn) and MhachBLM.BLM.AOE then
		local t = nil
		if MhachBLM.Target.aoe_num >= 2 then
			if MhachBLM.BLM.Smart_Target then
				if enemys then
					t, MhachBLM.Target.aoe_num = FindMaxTargetsInRange(enemys,5)
				end
			else
				t = TensorCore.mGetTarget()
			end
		end

		if level <=100 and level >= 58 and MhachBLM.Target.aoe_num >= 2 then

			if fire_ice >= 0 then  --火阶段
				if Yao_Xing.highlighted == 1 and IsReady(Yao_Xing) then return Yao_Xing, t end
				if mp >= 800 and IsReady(He_Bao) then return He_Bao, t end
				if mp < 800 and IsReady(Xing_Ling) and Xing_Ling:IsReady() and Yao_Xing.highlighted == 0 then return Xing_Ling, player end  --火转冰
			else  --冰阶段
				if MhachBLM.Target.aoe_num >= 3 then  --三目标
					if ice_heart < 3 and IsReady(Ice_AOE) then return Ice_AOE, t end

				else  --双目标
					if ice_heart < 3 and IsReady(Ice_4) then return Ice_4, t end
				end
				if tongxiao >= 1 and ice_heart == 3 and MhachBLM.BLM.Polyglot and IsReady(Hui_Zhuo) and not Xing_Ling:IsReady() then return Hui_Zhuo, t end
				if ice_heart == 3 and Xing_Ling:IsReady() and IsReady(Xing_Ling) then return Xing_Ling, player end
			end



		end

		if level >= 50 and level <= 57 and MhachBLM.Target.aoe_num >= 2 then

			if fire_ice >= 0 then  --火阶段
				if MhachBLM.Target.aoe_num >= 3 then --火阶段三目标
					if mp >= 3800 and IsReady(Fire_2) then return Fire_2, t end
					if mp >= 800 and IsReady(He_Bao) then return He_Bao, t end
					if mp < 800 and IsReady(Xing_Ling) and Xing_Ling:IsReady() then return Xing_Ling, player end  --火转冰
				else  --双目标
					if mp >= 2400 and IsReady(Fire_1) then return Fire_1, t end
					if mp >= 800 and IsReady(He_Bao) then return He_Bao, t end
					if mp < 800 and IsReady(Ice_3) then return Ice_3, t end  --火转冰
				end

			else  --冰阶段
				if MhachBLM.Target.aoe_num >= 3 then  --冰阶段三目标
					if IsReady(Ice_AOE) and not Xing_Ling:IsReady() then return Ice_AOE, t end
					if IsReady(Xing_Ling) and Xing_Ling:IsReady() then return Xing_Ling, player end  --冰转火
				else  --双目标
					if mp < 10000 and IsReady(Ice_AOE) then return Ice_AOE, t end
					if mp >= 10000 and IsReady(Fire_3) then return Fire_3, t end
				end

			end


		end

		if level >= 40 and level <= 49 and MhachBLM.Target.aoe_num >= 2 then

			if MhachBLM.Target.aoe_num >= 4 then  --四目标
				if IsReady(Ice_AOE) then return Ice_AOE, t end
			else  --双目标
				if fire_ice >= 0 then  --火阶段
					if mp >= 1600 and IsReady(Fire_1) then return Fire_1, t end
					if mp < 1600 and IsReady(Ice_3) then return Ice_3, t end
				else  --冰阶段
					if mp < 10000 and IsReady(Ice_AOE) then return Ice_AOE, t end
					if mp >= 10000 and IsReady(Fire_3) then return Fire_3, t end
				end
			end

		end

		if level >= 35 and level <= 40 and MhachBLM.Target.aoe_num >= 4 then

			if fire_ice >= 0 then
				if mp >= 3000 and IsReady(Fire_2) then return Fire_2, t end
				if mp < 3000 and Xing_Ling:IsReady() and IsReady(Xing_Ling) then return Xing_Ling, player end
			else
				if IsReady(Ice_2) and not Xing_Ling:IsReady() then return Ice_2, t end
				if Xing_Ling:IsReady() and IsReady(Xing_Ling) then return Xing_Ling, player end
			end

		end

		if level >= 18 and level <= 34 and MhachBLM.Target.aoe_num >= 3 then
			if fire_ice >= 0 then
				if mp >= 3000 and IsReady(Fire_2) then return Fire_2, t end
				if mp < 3000 and IsReady(Xing_Ling) and Xing_Ling:IsReady() then return Xing_Ling, player end
			else
				if mp < 10000 and IsReady(Ice_2) then return Ice_2, t end
				if mp >= 10000 and IsReady(Xing_Ling) and Xing_Ling:IsReady() then return Xing_Ling, player end
			end
		end

		if level <= 17 and level >= 12 and MhachBLM.Target.aoe_num >= 3 then
			if MhachBLM.Target.aoe_num >= 4 then
				if IsReady(Ice_2) then return Ice_2, t end
			else
				if fire_ice >= 0  then
					if mp >= 1600 and IsReady(Fire_1) then return Fire_1, t end
					if mp < 1600 and IsReady(Xing_Ling) and Xing_Ling:IsReady() then return Xing_Ling, player end
				else
					if mp < 10000 and IsReady(Ice_2) then return Ice_2, t end
					if mp >= 10000 and IsReady(Xing_Ling) and Xing_Ling:IsReady() then return Xing_Ling, player end
				end
			end
		end
		return nil, nil
	end
	return nil, nil
end

local function Polyglot_Combo()  --通晓循环，已适配全等级
	if (not MhachBLM.BLM.Burn) and MhachBLM.BLM.Polyglot then
		if  ((not MhachBLM.BLM.AOE) or MhachBLM.Target.aoe_num <= 1) then
			if level >= 98 then
				if tongxiao >= 3 and tongxiaoTime <= 50 and IsReady(Yi_Yan) then return Yi_Yan, target end
				if tongxiao >= 2 and Xiang_Shu.cd <= 6 and IsReady(Yi_Yan) then return Yi_Yan, target end
				if tongxiao >= 1 and (not MhachBLM.BLM.More_Move) and BurnTime(target) and IsReady(Yi_Yan) then return Yi_Yan, target end  --爆发期打异言
			elseif level >= 86 then
				if tongxiao >= 2 and tongxiaoTime <= 50 and IsReady(Yi_Yan) then return Yi_Yan, target end
				if tongxiao >= 1 and Xiang_Shu.cd <= 6 and IsReady(Yi_Yan) then return Yi_Yan, target end
				if tongxiao >= 1 and (not MhachBLM.BLM.More_Move) and BurnTime(target) and IsReady(Yi_Yan) then return Yi_Yan, target end  --爆发期打异言
			elseif level >= 80 then  --没有详述
				if tongxiao >= 2 and tongxiaoTime <= 50 and IsReady(Yi_Yan) then return Yi_Yan, target end
				if tongxiao >= 1 and (not MhachBLM.BLM.More_Move) and BurnTime(target) and IsReady(Yi_Yan) then return Yi_Yan, target end  --爆发期打异言
			elseif level >= 70 then  --秽浊
				if tongxiao >= 1 and tongxiaoTime <= 50 and IsReady(Hui_Zhuo) then return Hui_Zhuo, target end
				if tongxiao >= 1 and BurnTime(target) and IsReady(Hui_Zhuo) then return Hui_Zhuo, target end  --爆发期
			end
			return nil ,nil
		end
		if MhachBLM.BLM.AOE and MhachBLM.Target.aoe_num >= 2 then
			if level >= 98 then
				if tongxiao >= 3 and tongxiaoTime <= 50 and IsReady(Hui_Zhuo) then return Hui_Zhuo, target end
				if tongxiao >= 2 and Xiang_Shu.cd <= 6 and IsReady(Hui_Zhuo) then return Hui_Zhuo, target end
			elseif level >= 86 then
				if tongxiao >= 2 and tongxiaoTime <= 50 and IsReady(Hui_Zhuo) then return Hui_Zhuo, target end
				if tongxiao >= 1 and Xiang_Shu.cd <= 6 and IsReady(Hui_Zhuo) then return Hui_Zhuo, target end
			elseif level >= 80 then  --没有详述
				if tongxiao >= 2 and tongxiaoTime <= 50 and IsReady(Hui_Zhuo) then return Hui_Zhuo, target end
			elseif level >= 70 then  --秽浊
				if tongxiao >= 1 and tongxiaoTime <= 50 and IsReady(Hui_Zhuo) then return Hui_Zhuo, target end
			end
		end
		return nil ,nil
	end
	return nil ,nil
end

local function DOT_Combo()  --dot循环，已适配全等级
--			if TensorCore.hasBuff(player, 3870) and MhachBLM.BLM.DOT and MissinMhachBLMyBuff(target, DotBuffs) and IsReady(DOT_AOE_3) then return DOT_AOE_3, target end
	--[[if MhachBLM.BLM.DOT and not MhachBLM.BLM.Burn then
		target = TensorCore.mGetTarget()
		if TensorCore.hasBuff(player, 3870) then
			if MissinMhachBLMyBuff(target, DotBuffs) and not MhachBLM.BLM.Smart_Target and (MhachBLM.Target.aoe_num <= 2 or not MhachBLM.BLM.AOE) then return DOT_3, target end
			if (MhachBLM.Target.aoe_num <= 2 or not MhachBLM.BLM.AOE) and MhachBLM.BLM.Smart_Target then
				if MhachBLM.Target.aoe_num >= 2 then
					target = FindDotTarget(enemys)
					if target ~= nil  then
						return DOT_3, target
					end
				end
			end
		end
		return nil ,nil
	end
	return nil ,nil]]
	local t = nil
	if MhachBLM.BLM.Smart_Target then  --智能目标
		t = FindDotTarget(enemys)
	else
		t = TensorCore.mGetTarget()
		if not MissinMhachBLMyBuff(t, DotBuffs) then
			t = nil
		end
	end
	if t ~= nil and not MhachBLM.Settings.DotBlackList[t.id] then
		if MhachBLM.BLM.DOT and not MhachBLM.BLM.Burn and TensorCore.hasBuff(player, 3870) and MhachBLM.Target.aoe_num <= 1 then
			if level >= 92 then
				if IsReady(DOT_3) then return DOT_3, t end
			elseif level >= 45 then
				if IsReady(DOT_2) then return DOT_2, t end
			elseif level >= 6 then
				if IsReady(DOT_1) then return DOT_1, t end
			end
			return nil ,nil
		end

		if MhachBLM.BLM.DOT and not MhachBLM.BLM.Burn and TensorCore.hasBuff(player, 3870) and MhachBLM.Target.aoe_num >= 2 then
			if level >= 92 and fire_ice <= 0 then
				if IsReady(DOT_AOE_3) then return DOT_AOE_3, t end
			elseif level >= 64 and fire_ice <= 0 then
				if IsReady(DOT_AOE_2) then return DOT_AOE_2, t end
			elseif level >= 26 and fire_ice <= 0 then
				if IsReady(DOT_AOE_1) then return DOT_AOE_1, t end
			end
			return nil, nil
		end
	end

	return nil, nil

end

local function Fire_Ice()  --火转冰，已适配全等级
	if ((not MhachBLM.BLM.AOE) or MhachBLM.Target.aoe_num <= 1) and not MhachBLM.BLM.Burn then
		if level >= 72 then
			local canuse = ((Mo_Quan.cd >= 1 and Mo_Quan.cd <= 98) or (MhachBLM.BLM.Manafont == false or MhachBLM.BLM.CD == false) or not IsReady(Mo_Quan)) and IsReady(Ji_Ke) and IsReady(Xing_Ling) and Xing_Ling:IsReady() and fire_ice >= 1 and mp < 800 and Yao_Xing.highlighted == 0
			if Ji_Ke:IsReady() and canuse and beilun < 25 and not ShunFaBuff() then
				return Ji_Ke, player
			end
			--[[if Ji_Ke.cd <= 1.5 and canuse and beilun < 25 and not ShunFaBuff() and tongxiao>= 1 and MhachBLM.BLM.Triplecastnot and not MhachBLM.BLM.More_Move then  --差一点即刻好就给个瞬发但是必须是异言
				InstantWindow =true
			end]]
			--[[if Ji_Ke.cd > 0 and (not ShunFaBuff()) and canuse and beilun < 25 and (not (San_Lian.cd >= 0.1 and San_Lian.cd <= 59.9)) and MhachBLM.NotHold(San_Lian) and MhachBLM.BLM.Triplecast and not MhachBLM.BLM.More_Move then
				MhachBLM.Action(San_Lian, player)
			end]]
			if (ShunFaBuff()) and canuse then
				return Xing_Ling, player
			end
			if Ji_Ke.cd <= 1 and canuse then
				return Xing_Ling, player
			end
			if Ji_Ke:IsReady() and IsReady(Ji_Ke) and mp < 800 and fire_ice <= -1 and Xing_Ling.cd >= 3.2 then
				return Ji_Ke, player
			end
			if mp < 800 and fire_ice >= 1 and ((Mo_Quan.cd >= 1 and Mo_Quan.cd <= 98) or (MhachBLM.BLM.Manafont == false or MhachBLM.BLM.CD == false) or not IsReady(Mo_Quan)) and IsReady(Ice_3) then return Ice_3, target end
			if ShunFaBuff() and fire_ice >= -2 and mp < 800 and IsReady(Ice_3) and ((Mo_Quan.cd >= 1 and Mo_Quan.cd <= 98) or (MhachBLM.BLM.Manafont == false or MhachBLM.BLM.CD == false) or not IsReady(Mo_Quan)) then return Ice_3, target end
		elseif level >= 35 then
			if mp < 800 and fire_ice >= 1 and ((Mo_Quan.cd >= 1 and Mo_Quan.cd <= 98) or (MhachBLM.BLM.Manafont == false or MhachBLM.BLM.CD == false)) and IsReady(Ice_3) then return Ice_3, target end

		elseif level >= 4 then
			if mp < 1600 and fire_ice >= 1 and IsReady(Xing_Ling) and Xing_Ling:IsReady() then return Xing_Ling, player end
		elseif level <= 3 then
			if mp < 1600 and fire_ice >= 1 and IsReady(Ice_1) then return Ice_1, target end
		end
		return nil ,nil
	end
	return nil ,nil
end

local function Ice_Fire()  --冰转火，已适配全等级
	if ((not MhachBLM.BLM.AOE) or MhachBLM.Target.aoe_num <= 1) and not MhachBLM.BLM.Burn then
		if level >= 90 then
			if fire_ice <= -1 and Xing_Ling:IsReady() and Bei_Lun.highlighted == 0 and ice_heart == 3 and mp == 10000 and IsReady(Xing_Ling) then
				return Xing_Ling, player
			end
			if fire_ice <= -1 and ice_heart == 3 and Bei_Lun.highlighted == 0 and (Xing_Ling.cd > 0 or not TensorCore.hasBuff(player, 165)) and IsReady(Fire_3) then
				return Fire_3, target
			end
		elseif level >= 35 then
			if fire_ice <= -1 and (mp >= 10000 or ice_heart == 3) and IsReady(Fire_3) then return Fire_3, target end
		elseif level >= 4 then
			if fire_ice <= -1 and mp >= 10000 and IsReady(Xing_Ling) and Xing_Ling:IsReady() then return Xing_Ling, player end
		elseif level <= 3 then
			if fire_ice <= -1 and mp >= 10000 and IsReady(Fire_1) then return Fire_1, target end
		end
		return nil , nil
	end
	return nil , nil
end

local function LeyLines() --黑魔纹,已适配全等级，需要调gcd优化----------------------------------------------------------------------------
	if MhachBLM.BLM.Ley_Lines and MhachBLM.BLM.CD then
		if level >= 52 then
			if (not TensorCore.hasBuff(player, 737)) and Mo_Wen:IsReady() and (fire_ice >= 3 or MhachBLM.BLM.Burn) and IsReady(Mo_Wen) then
				--if San_Lian:IsReady() and MhachBLM.BLM.Triplecast and MhachBLM.NotHold(San_Lian) and (not MhachBLM.Settings.RedPlayer) and not TensorCore.hasBuff(player, 1211) then return San_Lian, player end
				if ((Fire_4.cd/Fire_4.recasttime) >= 0.5) then return Mo_Wen, player end
			end
		end
		return nil ,nil
	end
	return nil ,nil
end

local function Move_Combo()  --移动循环,已适配全等级
	if nextGCD ~= nil then
		if nextGCD.casttime == 0 then
			return nil ,nil
		end
	end
	if moving then
		if ((not TensorCore.hasBuff(player, 165) and fire_ice >= 1) or (fire_ice <= -1)) and  (not ShunFaBuff()) and ParadoxGauge[beilun] and IsReady(Bei_Lun) then return Bei_Lun, target end
		if tongxiao >= 1 and MhachBLM.BLM.Polyglot and MhachBLM.NotHold(Yi_Yan) and IsReady(Yi_Yan) then return Yi_Yan, target end
		if not ShunFaBuff() and MhachBLM.BLM.Triplecast and tongxiao <= 0 and San_Lian:IsReady() and IsReady(San_Lian) then return San_Lian, player end
		if not ShunFaBuff() and tongxiao <= 0 and (not San_Lian:IsReady()) and IsReady(Ji_Ke) and Ji_Ke:IsReady() then return Ji_Ke, player end
		return nil, nil
	end
	return nil , nil
end

local function BURN()  --燃尽爆发，已适配全等级
	if MhachBLM.BLM.Burn and level >= 50 then
		if fire_ice >= 1 and Yao_Xing.highlighted == 1 and IsReady(Yao_Xing) then return Yao_Xing, target end
		if tongxiao >= 1 and IsReady(Yi_Yan) then return Yi_Yan, target end
		if fire_ice >= 1 and mp >= 800 and IsReady(He_Bao) then return He_Bao, target end
		if fire_ice >= 1 and mp and beilun <25 and IsReady(Xing_Ling) then return Xing_Ling, player end
		if fire_ice <= -1 and ice_heart < 3 and IsReady(Ice_4) then return Ice_4, target end
		if ice_heart == 3 and fire_ice <= -1 and Bei_Lun.highlighted == 1 and IsReady(Bei_Lun) then return Bei_Lun, target end
		if fire_ice <= -1 and ice_heart == 3 and Bei_Lun.highlighted == 0 and IsReady(Xing_Ling) then return Xing_Ling, player end
		return nil ,nil
	end
	if MhachBLM.BLM.Burn and level < 50 then
		MhachBLM.BLM.Burn = false
	end
	return nil ,nil
end

local function Manafont()  --魔泉，已适配全等级，需要对黑魔纹开魔泉进行优化-----------------------------------------------------------------------------------------
	if MhachBLM.BLM.Manafont and MhachBLM.BLM.CD then
		if level >=35 then  --解锁了魔泉和三档火
			if mp <800 and fire_ice == 3 and Mo_Quan:IsReady() and IsReady(Mo_Quan) then
			return Mo_Quan, player end
		elseif level >= 30 then  --解锁了魔泉但是没三档火
			if mp <800 and fire_ice >= 1 and Mo_Quan:IsReady() and IsReady(Mo_Quan) then
			return Mo_Quan, player end
		end
		return nil ,nil
	end
	return nil ,nil
end

local function Amplifier()  --详述，已适配全等级
	if MhachBLM.BLM.Amplifier and MhachBLM.BLM.CD then
		if level >= 98 then  --三档豆子
			if tongxiao <= 2 and Xiang_Shu.cd <= 1.5 and IsReady(Xiang_Shu) then return Xiang_Shu, player end
		elseif level >= 86 then  --二档豆子
			if tongxiao <= 1 and Xiang_Shu.cd <= 1.5 and IsReady(Xiang_Shu) then return Xiang_Shu, player end
		end
	end

	if MhachBLM.BLM.Triplecast and MhachBLM.prepull and IsReady(San_Lian) and not ShunFaBuff() then  --TensorReactions_CurrentTimer
		MhachBLM.prepull = false  --起手三连
		return San_Lian, player
	end
	return nil ,nil
end

local function Fire()  --火循环，已适配全等级
	if fire_ice <=0 then
		return nil, nil
	end
	if ((not MhachBLM.BLM.AOE) or MhachBLM.Target.aoe_num <= 1) and not MhachBLM.BLM.Burn then
		if Yao_Xing.highlighted == 1 and IsReady(Yao_Xing) then return Yao_Xing, target end  --最大优先级，耀星
		if fire_ice == 1 and mp >= 1600 and (not TensorCore.hasBuff(player, 165)) and Bei_Lun.highlighted == 1 and IsReady(Bei_Lun) then return Bei_Lun, target end  --进火打悖论获得火苗
		if fire_ice == 3 and (not TensorCore.hasBuff(player, 165)) and mp>= 1600 and mp <= 3000 and beilun <= 3 and Bei_Lun.highlighted == 1 and IsReady(Bei_Lun) then return Bei_Lun, target end  --可调位置的悖论
		if fire_ice == 1 and TensorCore.hasBuff(player, 165) and IsReady(Fire_3) then return Fire_3, target end  --火苗
		if fire_ice == 3 and mp >= 1600 and IsReady(Fire_4) then return Fire_4, target end  --火4
		if mp >= 800 and mp <1600 and IsReady(Jue_Wang) then return Jue_Wang, target end  --绝望收尾
		if mp >= 800 and mp <1600 and IsReady(He_Bao) then return He_Bao, target end  --低等级核爆收尾
		if fire_ice >= 1 and TensorCore.hasBuff(player, 165) and IsReady(Fire_3) and level >= 35 and level <= 59 then return Fire_3, target end  --低等级有火苗就打火苗
		if fire_ice >= 1 and mp >= 800 and IsReady(Fire_1) then return Fire_1, target end  --低等级打火1
		return nil ,nil
	end
	return nil ,nil
end

local function Ice() --冰循环，已适配全等级
	if fire_ice >=0 then
		return nil, nil
	end
	if ((not MhachBLM.BLM.AOE) or MhachBLM.Target.aoe_num <= 1) and not MhachBLM.BLM.Burn then
		if fire_ice == -3 and mp < 10000 and ice_heart <3 and IsReady(Ice_4) then return Ice_4, target end --冰4
		if fire_ice <= -1 and (ice_heart == 3 or mp == 10000) and Bei_Lun.highlighted == 1 and IsReady(Bei_Lun) then return Bei_Lun, target end  --冰悖论
		if fire_ice <= -1 and mp < 1000 and IsReady(Ice_1) and not IsReady(Ice_4) then return Ice_1, target end  --连冰4都没有那就打冰1吧
		return nil ,nil
	end
	return nil ,nil
end

local function Fix()  --打aoe后对循环进行修补
	if ((not MhachBLM.BLM.AOE) or MhachBLM.Target.aoe_num <= 1) and not MhachBLM.BLM.Burn then
		if beilun >= 25 then return Yao_Xing, target end
		if (fire_ice >= 1 and fire_ice <= 2) then
			if TensorCore.hasBuff(player, 165) and IsReady(Fire_3) then return Fire_3, target end
			if mp >= 4000 and IsReady(Fire_3) then return Fire_3, target end
			if mp > 800 and IsReady(Jue_Wang) then return Jue_Wang, target end
			if mp > 800 and IsReady(He_Bao) then return He_Bao, target end
			if mp > 800 and IsReady(Fire_1) then return Fire_1, target end
			if IsReady(Ice_3) then return Ice_3, target end
			if IsReady(Ice_1) then return Ice_1, target end
		end
		if (fire_ice <= -1 and fire_ice >= -2) then
			if mp >= 10000 and IsReady(Fire_3) then return Fire_3, target end
			if mp < 10000 and IsReady(Ice_4) then return Ice_4, target end
			if mp >=800 or ice_heart == 3 and IsReady(Fire_3) then return Fire_3, target end
			if IsReady(Ice_1) then return Ice_1, target end
		end
		if fire_ice <= -1 and IsReady(Ice_4) then return Ice_4, target end
		if fire_ice <= -1 and IsReady(Ice_1) then return Ice_1, target end
		if fire_ice >= 1 and IsReady(Fire_4) then return Fire_4, target end
		if fire_ice >= 1 and IsReady(Fire_1) then return Fire_1, target end
		if fire_ice == 0 and IsReady(Fire_3) and mp >= 2000 then return Fire_3, target end
		if fire_ice == 0 and IsReady(Fire_1) and mp >= 1600 then return Fire_1, target end
		return nil ,nil
	end
	return nil ,nil
end


local function InstantCast()   --创造瞬发窗口
	if InstantWindow then
		if nextGCD ~= nil then
			if nextGCD.casttime == 0 then
				InstantWindow = false
				return nil ,nil
			end
		end
		if tongxiao >= 1 and MhachBLM.BLM.Polyglot and IsReady(Yi_Yan) and (MhachBLM.Target.aoe_num == 1 or not MhachBLM.BLM.AOE) then
			InstantWindow = false
			return Yi_Yan, target
		elseif tongxiao >= 1 and MhachBLM.BLM.Polyglot and IsReady(Hui_Zhuo) and level >= 80 and MhachBLM.Target.aoe_num >= 2 then
			InstantWindow = false
			return Hui_Zhuo, target
		elseif Bei_Lun.highlighted == 1 and IsReady(Bei_Lun) then
			InstantWindow = false
			return Bei_Lun, target
		--[[elseif TensorCore.hasBuff(player, 3870) and IsReady(DOT_3) and MhachBLM.BLM.DOT then  -------这里要改一下，
			InstantWindow = false
			return DOT_3, target]]
		end
		ForceAbl = true  --没有瞬发窗口，强制插能力技
		return nil, nil
	end
	return nil, nil
end

local function HotbarRotation()
	if not HotbarSkills:isEmpty() then
		if lastcast == HotbarSkills:peek() and player.castinginfo.timesincecast <= 2000 then
			HotbarSkills:removeAll(lastcast)
			MhachBLM.Skills[lastcast].inHotbarList = false
			return nil, nil
		else
			return HotbarSkills:peek(), target
		end
	end
	return nil, nil
end

local RotationList = {
	[1] = HotbarRotation,
	[2] = Move_Combo,
	[3] = InstantCast,
	[4] = Polyglot_Combo,
	[5] = DOT_Combo,
	[6] = AOE_Combo,
	[7] = BURN,
	[8] = LeyLines,
	[9] = Manafont,
	[10] = Amplifier,
	[11] = Fire,
	[12] = Fire_Ice,
	[13] = Ice,
	[14] = Ice_Fire,
	[15] = Fix,
}

local function UserRoatation()
	if MhachBLM.HasTarget() and (not PlayerSkills:isEmpty()) then  --用户自定义循环逻辑

		if lastcast == PlayerSkills:peek() and TensorCore.mGetPlayer().castinginfo.timesincecast <= 2000 then
			PlayerSkills:dequeue()
		end
		return PlayerSkills:peek(), target
	end
	return nil, nil
end



local function MainRotation()  --技能主循环

	local skill , t
	skill , t = UserRoatation()
	if skill == nil and MhachBLM.HasTarget() then
		for i = 1, #RotationList do
			skill , t = RotationList[i]()
			if skill ~= nil then
				break
			end
		end
	end
	return skill , t
end

--技能逻辑----------------------------------------------------------------------------------------------------------------------
function MhachBLM.Cast()
	--[[if MhachBLMRotation ~= nil then
		MhachBLMRotation:Rotation()
	end]]
	if Player.alive and not (Busy() or IsMounting() or IsMounted() or IsDismounting() or MIsLoading() or IsFlying() or IsDiving()) then
		--TensorCore.hasBuff(player, 4410)--无敌buff
		local skill ,t = MainRotation()
		if skill ~= nil then
			MhachBLM.Action(skill ,t)
		end
	end
end


local function JoinHotbarQueue(skill, id)
	MhachBLM.DebugPrint("HotbarSkill:" .. skill.name .. tostring(skill.inHotbarList))
	if id >= 0 then  --真实技能进入技能队列
		if skill.inHotbarList then
			HotbarSkills:enqueueUnic(id)
		else
			HotbarSkills:removeAll(id)
		end
	else
		if not skill.inHotbarList then
			MhachBLM.LockFaceOff()
		end
	end
end

function MhachBLM.Draw()
	if MhachBLM.GUI.open then
		MhachBLM.GUI.visible, MhachBLM.GUI.open = GUI:Begin(MhachBLM.GUI.name, MhachBLM.GUI.open)
        if (MhachBLM.GUI.visible) then
			--[[GUI:Button("Reload Module", 110, 20)
            if GUI:IsItemClicked(0) then
                --重载配置
				MhachBLMRotation = FileLoad(Rotation)
				if MhachBLMRotation ~= nil then
					d("循环模型加载成功！")
				else
					d("模型加载失败，请重新加载或检查文件完整性！")
				end
            end]]
			GUI:Button("主设置", 100, 62)
			if GUI:IsItemClicked(0) then
				settingUI = true
				hotbarUI = false
            end

			GUI:SameLine()
			GUI:Button("HotBar设置", 100, 62)
			if GUI:IsItemClicked(0) then
				settingUI = false
				hotbarUI = true
            end
			if settingUI then     --主设置界面
				GUI:Spacing()
				local value, changed = GUI:Checkbox("Debug Output", MhachBLM.Settings.Debug)
				GUI:Spacing()
				local value2, changed2 = GUI:Checkbox("我开启了动画锁", MhachBLM.Settings.FuckAnimation)
				GUI:Spacing()
				local value3, changed3 = GUI:Checkbox("魔丸循环", MhachBLM.Settings.RedPlayer)
				GUI:Spacing()
				local value4, changed4 = GUI:Checkbox("魔纹步替补以太步", MhachBLM.Settings.Between_the_Aetherial)
				GUI:Spacing()
				local value5, changed5 = GUI:Checkbox("显示接下来的技能", MhachBLM.Settings.ShowNextSkill)
				GUI:Spacing()
				local value6, changed6 = GUI:Checkbox("不知道干啥的就别点", MhachBLM.Settings.NewCombo)
				GUI:Spacing()
				local value7, changed7 = GUI:Checkbox("战斗外禁用热键", MhachBLM.Settings.Lock)
				GUI:Spacing()
				GUI:Text("Dot目标黑名单")
				GUI:SameLine()
				local input, inputChanged = GUI:InputText("##Dot黑名单", listToString(MhachBLM.Settings.DotBlackList, ","), GUI.InputTextFlags_CharsNoBlank)
				if GUI:IsItemHovered() then
					GUI:SetTooltip("输入需要加入黑名单的content id,以逗号分隔")
				end
				if inputChanged then
					if input ~= nil and input ~= '' then
                        local newStr, _ = string.gsub(input, ", ", ",")
                        local blackList = splitString(newStr, ",")
                        MhachBLM.Settings.DotBlackList = {}
                        for _, id in pairs(blackList) do
							MhachBLM.Settings.DotBlackList[tonumber(id)] = true
                            --table.insert(MhachBLM.Settings.DotBlackList, tonumber(id))
                        end
					else
						MhachBLM.Settings.DotBlackList = {}
                    end

					SaveSettings()
				end
				if changed then
					MhachBLM.Settings.Debug = value
					SaveSettings()
				end
				if changed2 then
					MhachBLM.Settings.FuckAnimation = value2
					SaveSettings()
				end
				if changed3 then
					MhachBLM.Settings.RedPlayer = value3
					SaveSettings()
				end
				if changed4 then
					MhachBLM.Settings.Between_the_Aetherial = value4
					SaveSettings()
				end
				if changed5 then
					MhachBLM.Settings.ShowNextSkill = value5
					SaveSettings()
				end
				if changed7 then
					MhachBLM.Settings.Lock = value7
					SaveSettings()
				end
				if changed6 then
					MhachBLM.Settings.NewCombo = value6
					if MhachBLM.Settings.NewCombo then
						MhachBLMTest = FileLoad(Module)
						if MhachBLMTest ~= nil then
							MhachBLM.DebugPrint("新模型已启用.")
							MhachBLM.DebugPrint("测试获取新模型数据:"..MhachBLMTest.SkillsTest[142].Inform.Name)
						else
							MhachBLM.DebugPrint("未成功加载新模型.")
							MhachBLM.Settings.NewCombo = false
						end
					else
						MhachBLM.DebugPrint("新模型已禁用.")
					end
					SaveSettings()
				end
				GUI:End()
			end

			if hotbarUI then   --热键栏设置界面
				GUI:Spacing()
				local value, changed = GUI:Checkbox("显示热键栏", MhachBLM.Settings.ShowHotBar)
				if changed then
					MhachBLM.Settings.ShowHotBar = value
					SaveSettings()
				end
				GUI:Spacing()
				for _, id in ipairs(sortedIds) do
    				local skill = MhachBLM.Skills[id]
					local str = nil
    				GUI:Image(skill.iconPath, 38, 38)
					GUI:SameLine()
					--GUI:BeginChild("##HotBarSettings"..tostring(id), 200, 38, false, GUI.WindowFlags_NoSavedSettings + GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoScrollWithMouse)
					if not skill.keyBinding then
						str = AdjustKeyName(skill)
						GUI:Button(str, 200, 38)
						if GUI:IsItemClicked(0) then
							skill.keyBinding = true
						end
					else
						str = "按下按键以绑定"
						---------------------------绑定按键
						local pressed = false
						skill.keyBind, skill.keyName, skill.keyC, skill.keyA, skill.keyS, pressed = IsKeyDown()
						if pressed then
							skill.keyBinding = false
							str = AdjustKeyName(skill)
							SaveHotBar()
						end
						GUI:Button(str, 200, 38)
						if GUI:IsItemClicked(0) then
							skill.keyBinding = false
						end
					end
					if GUI:IsItemClicked(1) then
						skill.keyBind, skill.keyName, skill.keyC, skill.keyA, skill.keyS = -1, "None", false, false, false
						SaveHotBar()
					end
					if GUI:IsItemHovered() then
						GUI:SetTooltip("Left Click to add.\n".."Right Click to reset.")
					end
					GUI:SameLine()
					--[[if skill.showHotbar then
						GUI:Image(Icons .. "enable.png", 38, 38)
					else
						GUI:Image(Icons .. "disable.png", 38, 38)
					end
					if GUI:IsItemClicked(0) then
						skill.showHotbar = not skill.showHotbar
					end
					if GUI:IsItemHovered() then
						GUI:SetTooltip("Left Click to Enable/Disable.")
					end
					GUI:SameLine()
					GUI:Text(skill.name)]]
					skill.showHotbar, skill.changed = GUI:Checkbox(skill.name .. "##" .. id, skill.showHotbar)
					if skill.changed then
						SaveHotBar()
					end
					if GUI:IsItemHovered() then
						GUI:SetTooltip("Left Click to Enable/Disable.")
					end
					GUI:Spacing()
					--GUI:EndChild()
				end
				GUI:End()
			end
        end
	end
    if MhachBLM ~= nil and MhachBLM.BLMGUI ~= nil then

        if GUI:Begin(MhachBLM.BLMGUI.WindowName, MhachBLM.BLMGUI.IsVisible, MhachBLM.BLMGUI.WindowFlags) then  --qt界面
			local buttonsPerRow = 3  -- 每行显示两个按钮
			local buttonIndex = 0    -- 当前按钮索引

			for _, button in ipairs(MhachBLM.BLMGUI.Buttons) do
				-- 普通按钮绘制
				-- 应用样式
				MhachBLM.BLMGUI.ApplyButtonStyle(button.Enabled, button.Style)

				-- 检查按钮是否有单独设置的宽度和高度
				local buttonWidth = button.Width or MhachBLM.BLMGUI.ButtonWidth
				local buttonHeight = button.Height or MhachBLM.BLMGUI.ButtonHeight

				-- 绘制按钮
				GUI:Button(button.Label, buttonWidth, buttonHeight)

				-- 恢复样式
				GUI:PopStyleColor(button.Style and button.Style.Text and 4 or 3)

				if button.Label == "CD" then
					button.Enabled = MhachBLM.BLM.CD
				elseif button.Label == "DOT" then
					button.Enabled = MhachBLM.BLM.DOT
				elseif button.Label == "AOE" then
					button.Enabled = MhachBLM.BLM.AOE
				elseif button.Label == "爆发药" then
					button.Enabled = MhachBLM.BLM.Potion
				elseif button.Label == "通晓" then
					button.Enabled = MhachBLM.BLM.Polyglot
				elseif button.Label == "黑魔纹" then
					button.Enabled = MhachBLM.BLM.Ley_Lines
				elseif button.Label == "魔泉" then
					button.Enabled = MhachBLM.BLM.Manafont
				elseif button.Label == "详述" then
					button.Enabled = MhachBLM.BLM.Amplifier
				elseif button.Label == "三连咏唱" then
					button.Enabled = MhachBLM.BLM.Triplecast
				elseif button.Label == "Burn" then
					button.Enabled = MhachBLM.BLM.Burn
				elseif button.Label == "智能目标" then
					button.Enabled = MhachBLM.BLM.Smart_Target
				elseif button.Label == "更多移动" then
					button.Enabled = MhachBLM.BLM.More_Move
				end

				-- 检测点击事件
				if button.Clickable and GUI:IsItemClicked() then
					--button.Enabled = not button.Enabled

					if button.Label == "CD" then
						MhachBLM.BLM.CD = not MhachBLM.BLM.CD
						MhachBLM.DebugPrint("CD now is " .. tostring(MhachBLM.BLM.CD))
					elseif button.Label == "DOT" then
						MhachBLM.BLM.DOT = not MhachBLM.BLM.DOT
						MhachBLM.DebugPrint("DOT now is " .. tostring(MhachBLM.BLM.DOT))
					elseif button.Label == "AOE" then
						MhachBLM.BLM.AOE = not MhachBLM.BLM.AOE
						MhachBLM.DebugPrint("AOE now is " .. tostring(MhachBLM.BLM.AOE))
					elseif button.Label == "爆发药" then
						MhachBLM.BLM.Potion = not MhachBLM.BLM.Potion
						MhachBLM.DebugPrint("Potion now is " .. tostring(MhachBLM.BLM.Potion))
					elseif button.Label == "通晓" then
						MhachBLM.BLM.Polyglot = not MhachBLM.BLM.Polyglot
						MhachBLM.DebugPrint("Polyglot now is " .. tostring(MhachBLM.BLM.Polyglot))
					elseif button.Label == "黑魔纹" then
						MhachBLM.BLM.Ley_Lines = not MhachBLM.BLM.Ley_Lines
						MhachBLM.DebugPrint("Ley_Lines now is " .. tostring(MhachBLM.BLM.Ley_Lines))
					elseif button.Label == "魔泉" then
						MhachBLM.BLM.Manafont = not MhachBLM.BLM.Manafont
						MhachBLM.DebugPrint("Manafont now is " .. tostring(MhachBLM.BLM.Manafont))
					elseif button.Label == "详述" then
						MhachBLM.BLM.Amplifier = not MhachBLM.BLM.Amplifier
						MhachBLM.DebugPrint("Amplifier now is " .. tostring(MhachBLM.BLM.Amplifier))
					elseif button.Label == "三连咏唱" then
						MhachBLM.BLM.Triplecast = not MhachBLM.BLM.Triplecast
						MhachBLM.DebugPrint("Triplecast now is " .. tostring(MhachBLM.BLM.Triplecast))
					elseif button.Label == "Burn" then
						MhachBLM.BLM.Burn = not MhachBLM.BLM.Burn
						MhachBLM.DebugPrint("Burn now is " .. tostring(MhachBLM.BLM.Burn))
					elseif button.Label == "智能目标" then
						MhachBLM.BLM.Smart_Target = not MhachBLM.BLM.Smart_Target
						MhachBLM.DebugPrint("Smart_Target now is " .. tostring(MhachBLM.BLM.Smart_Target))
					elseif button.Label == "更多移动" then
						MhachBLM.BLM.More_Move = not MhachBLM.BLM.More_Move
						MhachBLM.DebugPrint("More_Move now is " .. tostring(MhachBLM.BLM.More_Move))
					end
					SaveSettings()
				end

				-- 布局控制：每行两个按钮
				buttonIndex = buttonIndex + 1
				if buttonIndex % buttonsPerRow == 0 then
					GUI:Spacing()  -- 换行
				else
					GUI:SameLine()  -- 同一行显示
				end
			end
			GUI:End()
		end

		if MhachBLM.Settings.ShowNextSkill then   --下一个技能界面
			if GUI:Begin(MhachBLM.NextSkillUI.WindowName, MhachBLM.NextSkillUI.IsVisible, MhachBLM.NextSkillUI.WindowFlags) then
				if nextGCD ~= nil then
					GUI:Image(MhachBLM.Skills[nextGCD.id].iconPath, 50, 50)
				else
					GUI:Image(defultIcon, 50, 50)
				end

				GUI:SameLine()

				if nextAbl ~= nil then
					GUI:Image(MhachBLM.Skills[nextAbl.id].iconPath, 40, 40)
				else
					GUI:Image(defultIcon, 40, 40)
				end
				GUI:End()
			end
		end

		if MhachBLM.Settings.ShowHotBar then   --热键栏界面
			if GUI:Begin(MhachBLM.HotBarUI.WindowName, MhachBLM.HotBarUI.IsVisible, MhachBLM.HotBarUI.WindowFlags) then
				--local icons = FolderList(Icons)
				local arr = 12  --一行的数量
				local index = 0
				local indey = 0
				local X = 5
				local Y = 5
				for _, id in ipairs(sortedIds) do
    				local skill = MhachBLM.Skills[id]
					if skill.showHotbar then
						if index < arr then
							GUI:SetCursorPos(X,Y)
							GUI:Image(skill.iconPath, 43, 43)

							index = index + 1
							X = X + 48
						else
							Y = Y + 48
							indey = indey + 1
							index = 0
							X = 5
							GUI:SetCursorPos(X,Y)
							GUI:Image(skill.iconPath, 43, 43)

						end

						if GUI:IsItemClicked(0) then   --横向+53,纵向+49
							skill.inHotbarList = not skill.inHotbarList
							MhachBLM.DebugPrint("HotbarSkill:" .. skill.name .. tostring(skill.inHotbarList))
							JoinHotbarQueue(skill, id)
							
						end
						if skill.inHotbarList then
							local x = (index - 1) * 48 + 5
							local y = indey * 48 + 3
							GUI:SetCursorPos(x,y)
							GUI:Image(Icons .. "actionlight.png", 45, 45)
						end
						GUI:SetCursorPos((index - 1) * 48 + 4,indey * 48 - 3)
						if skill.keyName ~= "None" then
							GUI:SetWindowFontSize( 1.5)
							GUI:TextColored(1, 1, 1, 1, skill.keyName)
						end

					end

					--检测按键
					if KeybindsPressed(skill) and (not MhachBLM.Settings.Lock) and not skill.keyBinding then
						skill.inHotbarList = not skill.inHotbarList
						JoinHotbarQueue(skill, id)
					elseif MhachBLM.Settings.Lock then  --战斗外禁用快捷键
						if TensorCore.mGetPlayer().incombat and not skill.keyBinding and KeybindsPressed(skill) then
							skill.inHotbarList = not skill.inHotbarList
							JoinHotbarQueue(skill, id)
						end
					end

				end

			end
			GUI:End()
		end
	end
end



-- Adds a customizable header to the top of the ffxivminion task window.
--[[function MhachBLM.DrawHeader()
 
end]]

-- Adds a customizable footer to the top of the ffxivminion task window.
--[[function MhachBLM.DrawFooter()
 
end]]

function MhachBLM.OnOpen()
    MhachBLM.GUI.open = true
end

function MhachBLM.OnLoad()

    --ACR_MyProfile_MySavedVar = ACR.GetSetting("ACR_MyProfile_MySavedVar", false)
	LoadSettings()
	LoadHotBar()
	--[[MhachBLMRotation = FileLoad(Module)
	if MhachBLMRotation ~= nil then
		d(type(MhachBLMRotation))
		d(MhachBLMRotation.test)
		d("循环模型加载成功！")
	else
		d("模型加载失败，请重新加载或检查文件完整性！")
	end]]
end

function MhachBLM.OnUpdate(event, tickcount)
	UpdateTimer()
	SetValue()  --设置本地变量
	TargetSet()
	LockFace()
	if (GUI:IsKeyDown(87) or GUI:IsKeyDown(65) or GUI:IsKeyDown(83) or GUI:IsKeyDown(68)) and player:GetSpeed().Forward == 0 then
		player:SetSpeed(1, speed_F, speed_B, speed_S, speed_W)
	end
end

return MhachBLM