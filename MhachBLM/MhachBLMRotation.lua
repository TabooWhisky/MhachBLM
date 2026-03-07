local MhachBLMRotation = {
}
MhachBLMRotation.ParadoxGauge = {[3] = true, [7] = true, [11] = true, [15] = true, [19] = true, [23] = true, [27] = true}  --悖论量谱快速鉴定
MhachBLMRotation.DotBuffs = {[161] = true, [162] = true, [163] = true, [1210] = true, [3871] = true, [3872] = true }
MhachBLMRotation.enemys = nil
MhachBLMRotation.target = nil
MhachBLMRotation.TargetTuanfu = {3849, 1221} --目标团辅
MhachBLMRotation.PlayerTuanfu = {1878, 3889, 786, 1185, 2599, 2964, 141, 1822, 1825, 2703, 1297, 3685}  --角色团辅
MhachBLMRotation.ShunFa = {167, 1211}  --瞬发buff
MhachBLMRotation.PlayerSkills = Queue:new()  --用户自定义循环列表
MhachBLMRotation.HoldList = {}  --hold技能列表
MhachBLMRotation.HoldSeen = {}  --hold辅助列表，用来记录已经在hold中的技能，键为数字，值为true
MhachBLMRotation.lastTime = 0
MhachBLMRotation.nowTime = 0
MhachBLMRotation.fpsTime = 0
MhachBLMRotation.aoeNum = 0

MhachBLMRotation.player = nil
MhachBLMRotation.playerid = nil
MhachBLMRotation.incombat = nil
MhachBLMRotation.moving = nil
MhachBLMRotation.fire_ice = nil
MhachBLMRotation.ice_heart = nil
MhachBLMRotation.tongxiao = nil
MhachBLMRotation.beilun = nil
MhachBLMRotation.mp = 0
MhachBLMRotation.lastcast = nil
MhachBLMRotation.alive = nil
MhachBLMRotation.tongxiaoTime = nil

MhachBLMRotation.STATE_FIRE = "fire"
MhachBLMRotation.STATE_ICE = "ice"
MhachBLMRotation.STATE_AOE = "aoe"
MhachBLMRotation.STATE_CHANGETO_FIRE = "iceTofire"
MhachBLMRotation.STATE_CHANGETO_ICE = "fireToice"
MhachBLMRotation.STATE_MOVING = "moving"
MhachBLMRotation.STATE_START = "start"
MhachBLMRotation.STATE_FIX = "fix"
MhachBLMRotation.NOW_STATE = ""

MhachBLMRotation.Skills = {}
MhachBLMRotation.HoldSeen = {}
MhachBLMRotation.HoldList = {}

MhachBLMRotation.LuaPath = GetLuaModsPath()
MhachBLMRotation.ModulePath = LuaPath .. [[ACR\CombatRoutines\MhachBLM\]]
MhachBLMRotation.Settings = ModulePath .. [[Settings.lua]]

MhachBLMRotation.DebugPrint = function(...)
    if MhachBLM.Settings.Debug then
        d("[MhachBLM] " .. ...)
    end
end
-------------------------------------------------------------------------------------------------------------------------------
MhachBLMRotation.RegisterSkill = function(action, isgcd)
    if action then
        MhachBLMRotation.Skills[action.id] = {
			IsGCD = isgcd,
			holdTime = 0,  --延后时间
        }
        DebugPrint("Registered Skill: " .. action.name .. " (" .. action.id .. ")")
    else
        DebugPrint("Action with ID " .. action.id .. " could not be find, is it valid ? Report to a dev.")
    end
end


-----技能id和是否为gcd
MhachBLMRotation.Ice_1 = ActionList:Get(1, 142)
MhachBLMRotation.RegisterSkill(Ice_1, true)  --冰结

MhachBLMRotation.Fire_1 = ActionList:Get(1, 141)
MhachBLMRotation.RegisterSkill(Fire_1, true)  --火炎

MhachBLMRotation.Xing_Ling = ActionList:Get(1, 149)
MhachBLMRotation.RegisterSkill(Xing_Ling, false) --星灵移位

MhachBLMRotation.DOT_1 = ActionList:Get(1, 144)
MhachBLMRotation.RegisterSkill(DOT_1, true) --闪雷

MhachBLMRotation.Ice_2 = ActionList:Get(1, 25793)
MhachBLMRotation.RegisterSkill(Ice_2, true) --冰冻

MhachBLMRotation.Beng_Kui = ActionList:Get(1, 156)
MhachBLMRotation.RegisterSkill(Beng_Kui, true) --崩溃

MhachBLMRotation.Fire_2 = ActionList:Get(1, 147)
MhachBLMRotation.RegisterSkill(Fire_2, true) --烈炎

MhachBLMRotation.DOTAOE_1 = ActionList:Get(1, 7447)
MhachBLMRotation.RegisterSkill(DOTAOE_1, true) --震雷

MhachBLMRotation.Mo_Zhao = ActionList:Get(1, 157)
MhachBLMRotation.RegisterSkill(Mo_Zhao, false) --魔罩

MhachBLMRotation.Fire_3 = ActionList:Get(1, 152)
MhachBLMRotation.RegisterSkill(Fire_3, true) --爆炎

MhachBLMRotation.Yi_Tai = ActionList:Get(1, 155)
MhachBLMRotation.RegisterSkill(Yi_Tai, false) --以太步

MhachBLMRotation.Mo_Quan = ActionList:Get(1, 158)
MhachBLMRotation.RegisterSkill(Mo_Quan, false) --魔泉

MhachBLMRotation.Ice_3 = ActionList:Get(1, 154)
MhachBLMRotation.RegisterSkill(Ice_3, true) --冰封

MhachBLMRotation.Ling_Ji_Hun = ActionList:Get(1, 16506)
MhachBLMRotation.RegisterSkill(Ling_Ji_Hun, true) --灵极魂

MhachBLMRotation.Ice_AOE = ActionList:Get(1, 159)
MhachBLMRotation.RegisterSkill(Ice_AOE, true) --玄冰

MhachBLMRotation.DOT_2 = ActionList:Get(1, 153)
MhachBLMRotation.RegisterSkill(DOT_2, true) --暴雷

MhachBLMRotation.He_Bao = ActionList:Get(1, 162)
MhachBLMRotation.RegisterSkill(He_Bao, true) --核爆

MhachBLMRotation.Mo_Wen = ActionList:Get(1, 3573)
MhachBLMRotation.RegisterSkill(Mo_Wen, false) --黑魔纹

MhachBLMRotation.Ice_4 = ActionList:Get(1, 3576)
MhachBLMRotation.RegisterSkill(Ice_4, true) --冰澈

MhachBLMRotation.Fire_4 = ActionList:Get(1, 3577)
MhachBLMRotation.RegisterSkill(Fire_4, true) --炽炎

MhachBLMRotation.Mo_Wen_Bu = ActionList:Get(1, 7419)
MhachBLMRotation.RegisterSkill(Mo_Wen_Bu, false) --魔纹步

MhachBLMRotation.DOT_AOE_2 = ActionList:Get(1, 7420)
MhachBLMRotation.RegisterSkill(DOT_AOE_2, true) --霹雷

MhachBLMRotation.San_Lian = ActionList:Get(1, 7421)
MhachBLMRotation.RegisterSkill(San_Lian, false) --三连咏唱

MhachBLMRotation.Hui_Zhuo = ActionList:Get(1, 7422)
MhachBLMRotation.RegisterSkill(Hui_Zhuo, true) --秽浊

MhachBLMRotation.Jue_Wang = ActionList:Get(1, 16505)
MhachBLMRotation.RegisterSkill(Jue_Wang, true) --绝望

MhachBLMRotation.Yi_Yan = ActionList:Get(1, 16507)
MhachBLMRotation.RegisterSkill(Yi_Yan, true) --异言

MhachBLMRotation.Fire_5 = ActionList:Get(1, 25794)
MhachBLMRotation.RegisterSkill(Fire_5, true) --高烈炎

MhachBLMRotation.Ice_5 = ActionList:Get(1, 25795)
MhachBLMRotation.RegisterSkill(Ice_5, true) --高冰冻

MhachBLMRotation.Xiang_Shu = ActionList:Get(1, 25796)
MhachBLMRotation.RegisterSkill(Xiang_Shu, false) --详述

MhachBLMRotation.DOT_3 = ActionList:Get(1, 36986)
MhachBLMRotation.RegisterSkill(DOT_3, true) --高闪雷

MhachBLMRotation.DOT_AOE_3 = ActionList:Get(1, 36987)
MhachBLMRotation.RegisterSkill(DOT_AOE_3, true) --高震雷

MhachBLMRotation.Mo_Wen_Reset = ActionList:Get(1, 36988)
MhachBLMRotation.RegisterSkill(Mo_Wen_Reset, false) --魔纹重置

MhachBLMRotation.Yao_Xing = ActionList:Get(1, 36989)
MhachBLMRotation.RegisterSkill(Yao_Xing, true) --耀星

MhachBLMRotation.Bei_Lun = ActionList:Get(1, 25797)
MhachBLMRotation.RegisterSkill(Bei_Lun, true) --悖论

MhachBLMRotation.Hun_Luan = ActionList:Get(1, 7560)
MhachBLMRotation.RegisterSkill(Hun_Luan, false) --昏乱

MhachBLMRotation.Cui_Mian = ActionList:Get(1, 25880)
MhachBLMRotation.RegisterSkill(Cui_Mian, true) --催眠

MhachBLMRotation.Xing_Meng = ActionList:Get(1, 7562)
MhachBLMRotation.RegisterSkill(Xing_Meng, false) --醒梦

MhachBLMRotation.Ji_Ke = ActionList:Get(1, 7561)
MhachBLMRotation.RegisterSkill(Ji_Ke, false) --即刻咏唱

MhachBLMRotation.Chen_Wen = ActionList:Get(1, 7559)
MhachBLMRotation.RegisterSkill(Chen_Wen, false) --沉稳咏唱

MhachBLMRotation.LB = ActionList:Get(1, 3)
MhachBLMRotation.RegisterSkill(LB, false) --极限技

MhachBLMRotation.Sprint = ActionList:Get(1, 4)
MhachBLMRotation.RegisterSkill(Sprint, false) -- 冲刺
------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------
MhachBLMRotation.Queue = {}
MhachBLMRotation.Queue.__index = MhachBLMRotation.Queue

--初始化队列
MhachBLMRotation.Queue.new = function()
	return setmetatable({
		items = {}, --存储元素
		head = 1,  --队首指针，指向第一个元素
		tail = 1  --队尾指针，指向下一个入队元素
	},MhachBLMRotation.Queue)
end

--入队
MhachBLMRotation.Queue.enqueue = function(self,value)
	self.items[self.tail] = value
	self.tail = self.tail + 1
end

--出队
MhachBLMRotation.Queue.dequeue = function(self)
	if MhachBLMRotation.isEmpty() then return nil end
	MhachBLMRotation.value = self.items[self.head]
	self.items[self.head] = nil  --释放内存
	self.head = self.head + 1
	return MhachBLMRotation.value
end

--查看队首元素（不移除）
MhachBLMRotation.Queue.peek = function(self)
	return self.items[self.head]
end

--获取队列元素数量
MhachBLMRotation.Queue.size = function(self)
	return self.tail - self.head
end

--检查队列是否为空
MhachBLMRotation.Queue.isEmpty = function(self)
	return self.head >= self.tail
end

--清空队列
MhachBLMRotation.Queue.clear = function(self)
	self.items = {}
	self.head = 1
	self.tail = 1
end
----------------------------------------------------------------------------------------------------------------





MhachBLMRotation.NotHold = function(id)  --检查技能是否没有hold
	if type(id) ~= "number" then
		id = id.id
	end
	return MhachBLMRotation.Skills[id].holdTime <= 0
end

MhachBLMRotation.MoveHold = function(id)  --移除技能的hold时间
	if type(id) ~= "number" then
		id = id.id
	end
	if not MhachBLMRotation.HoldSeen[id] then
		return
	end
	for i = #MhachBLMRotation.HoldList,1,-1 do
		if MhachBLMRotation.HoldList[i] == id then
			table.remove(MhachBLMRotation.HoldList, i)  --从后向前移除技能
			MhachBLMRotation.HoldSeen[i] = nil  --移除辅助标记
			break
		end
	end
end

MhachBLMRotation.ResetHoldList = function()  --重置hold列表
	MhachBLMRotation.HoldList = {}
	MhachBLMRotation.HoldSeen = {}
end

MhachBLMRotation.PrintHoldList = function()  --打印hold列表
	d("HoldList: " .. table.concat(MhachBLMRotation.HoldList,","))
end


MhachBLMRotation.SetValue = function()  --为本地变量赋值
    MhachBLMRotation.player = TensorCore.mGetPlayer()
	MhachBLMRotation.playerid = MhachBLMRotation.player.id
	MhachBLMRotation.incombat = MhachBLMRotation.player.incombat
	MhachBLMRotation.moving = MhachBLMRotation.player:IsMoving()
	MhachBLMRotation.fire_ice = MhachBLMRotation.player.gauge[2]
	MhachBLMRotation.ice_heart = MhachBLMRotation.player.gauge[1]
	MhachBLMRotation.tongxiao = MhachBLMRotation.player.gauge[5]
	MhachBLMRotation.beilun = MhachBLMRotation.player.gauge[3]
	MhachBLMRotation.mp = MhachBLMRotation.player.mp.current
	MhachBLMRotation.lastcast = MhachBLMRotation.player.castinginfo.lastcastid
	MhachBLMRotation.alive = MhachBLMRotation.player.alive
	MhachBLMRotation.tongxiaoTime = MhachBLMRotation.player.gaugetest[2] --剩余秒数*4
end

---------------------------------------------------------------------------------------
MhachBLMRotation.PlayerCombo = function(list)  --用户自定义循环，输入{152, 154}这种
	for i = 1,#list do
		MhachBLMRotation.PlayerSkills:enqueue(list[i])
	end
end

MhachBLMRotation.PlayerComboClear = function()  --清空用户自定义循环
	MhachBLMRotation.PlayerSkills:clear()
end

MhachBLMRotation.PlayerComboEmpty = function() --返回用户循环是否为空
	return MhachBLMRotation.PlayerSkills:isEmpty()
end
---------------------------------------------------------------------------------------




MhachBLMRotation.GetSkill = function(SkillID)
    if not SkillID then
        return nil
    end
    if not MhachBLMRotation.Skills[SkillID] then
        d("Skill not found: " .. tostring(SkillID))
    else
        return MhachBLMRotation.Skills[SkillID]
    end
end

MhachBLMRotation.IsSkillGCD = function(SkillID)  --检查是否为gcd技能
	if SkillID == nil then
        return false
    end
    if MhachBLMRotation.Skills[SkillID] == nil then
        return true -- GCD by default
    end
    if MhachBLMRotation.Skills[SkillID].IsGCD then
        return true
    end
    return false
end

MhachBLMRotation.HasTarget = function()  --检查是否有合法目标
	if TensorCore.mGetTarget()~=nil and TensorCore.mGetTarget().attackable then
		return true
	else
		return false
	end
end

MhachBLMRotation.CalHold = function()  --计算hold时间逻辑
	for _,i in ipairs(MhachBLMRotation.HoldList) do
		MhachBLMRotation.Skills[i].holdTime = MhachBLMRotation.Skills[i].holdTime - fpsTime
		--d(MhachBLM.Skills[i].holdTime)
		if MhachBLMRotation.Skills[i].holdTime <= 0 then
			MhachBLMRotation.Skills[i].holdTime = 0
			MhachBLMRotation.MoveHold(i)
		end
	end
end

MhachBLMRotation.BurnTime = function(target)  --检查身上或者目标身上是否有团辅
	for _, buff in pairs(MhachBLMRotation.PlayerTuanfu) do
		if TensorCore.hasBuff(MhachBLMRotation.player, buff) then return true end
	end

	for _, buff in pairs(MhachBLMRotation.TargetTuanfu) do
		if TensorCore.hasBuff(target, buff) then return true end
	end
	return false
end

MhachBLMRotation.ShunFaBuff = function()  --检查自己身上有无瞬发buff
	for _, buff in pairs(MhachBLMRotation.ShunFa) do
		if TensorCore.hasBuff(MhachBLMRotation.player, buff) then return true end
	end
	return false
end

MhachBLMRotation.FindTargetsNum = function(enemys)  --查找目标数量
	local count = 0
	MhachBLMRotation.itarget = TensorCore.mGetTarget()
	for _, enemy in pairs(enemys) do
		MhachBLMRotation.distance2d = Distance2DT(MhachBLMRotation.itarget.pos, enemy.pos)
		if MhachBLMRotation.distance2d <= (5 + enemy.hitradius) then 
			count = count + 1 
		end
	end
	return count
end

MhachBLMRotation.FindMaxTargetsInRange = function(targets, r)  --查找最紧凑敌人
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

MhachBLMRotation.MissinMhachBLMyBuff = function(target, buffids) --查询目标身上是否有自己上的buff,没有则返回真
	for _, buff in pairs(target.buffs) do
		if buff.ownerid == MhachBLMRotation.playerid then
			if (buffids[buff.id]) and buff.duration <= 3 then
				return true
			elseif (buffids[buff.id]) and buff.duration > 3 then
				return false
			end
		end
	end
	return true
end

MhachBLMRotation.FindDotTarget = function(enemys)  --智能dot目标选择器
	for _, ienemy in pairs(enemys) do
		if MhachBLMRotation.MissinMhachBLMyBuff(ienemy, MhachBLMRotation.DotBuffs) then return ienemy end
	end
	return nil
end




MhachBLMRotation.TargetSet = function()  --目标设置器
	if MhachBLMRotation.HasTarget() then
		MhachBLMRotation.enemys = TensorCore.entityList("alive,attackable,incombat,maxdistance=25")
		if MhachBLMRotation.enemys then
			MhachBLMRotation.aoeNum = MhachBLMRotation.FindTargetsNum(MhachBLMRotation.enemys)
		end
	end

end


--这段代码是一个名为 MhachBLM.IsReady 的函数，主要功能是判断游戏中某个技能（action）当前是否可以使用。
MhachBLMRotation.IsReady = function(action)
    --先过滤掉 “绝对不能释放技能” 的场景
	if (MhachBLMRotation.Fire_4.cd/MhachBLMRotation.Fire_4.recasttime) >= 0.99 or MhachBLMRotation.Fire_4.cd/MhachBLMRotation.Fire_4.recasttime == 0 then  --瞬发逻辑与时间逻辑
		if MhachBLMRotation.moving and not MhachBLMRotation.ShunFaBuff() then
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
end

--这段代码是一个名为MhachBLM.Action的函数，主要功能是执行一个 "动作"(如游戏中的技能、法术等) 并指定目标。它会先验证动作和目标的有效性，检查玩家与目标的距离是否在动作的有效范围内，最后执行这个动作。
MhachBLMRotation.Action = function(action, target)
	if type(action) == "number" then  --将传入的动作参数统一格式
        action = MhachBLMRotation.ActionList:Get(1, action)  --如果传入的action是数字 (可能是动作 ID)，就通过ActionList:Get(1, action)把它转换为完整的动作对象 (包含动作名称、范围等信息)。
    end
    if (not MhachBLMRotation.IsSkillGCD(action.id)) or (not target) then  --设置默认目标
        target = MhachBLMRotation.player
    end

	if target.distance2d <= action.range or target == MhachBLMRotation.player then
		if MhachBLMRotation.IsSkillGCD(action.id) then
			if MhachBLMRotation.IsReady(action) then
				MhachBLMRotation.DebugPrint("Casting: " .. action.name)
        		return action:Cast(target.id)
			end
		else
			if ((MhachBLMRotation.Fire_4.cd/MhachBLMRotation.Fire_4.recasttime) <= 0.9) then   --能力技使用相关
				MhachBLMRotation.DebugPrint("Casting: " .. action.name)
				--return action:Cast(target.id)
				return SendTextCommand("/ac " .. action.name)
			end

		end
	end
end
----------------------------------------------------------------------------------------------------------
MhachBLMRotation.AOE_Combo = function()--AOE循环
    if MhachBLMRotation.aoeNum >= 2 then
        if MhachBLM.BLM.Smart_Target then
            if MhachBLMRotation.enemys then
                MhachBLMRotation.target, MhachBLMRotation.aoeNum = MhachBLMRotation.FindMaxTargetsInRange(enemys,5)
            end
        else
            MhachBLMRotation.target = TensorCore.mGetTarget()
        end
    end

    if MhachBLMRotation.beilun >=25 and MhachBLMRotation.NotHold(MhachBLMRotation.Yao_Xing) then return MhachBLMRotation.Action(MhachBLMRotation.Yao_Xing, target) end
    if MhachBLMRotation.mp >= 800 and MhachBLMRotation.aoeNum >= 2 and MhachBLMRotation.fire_ice >= 1 and MhachBLMRotation.NotHold(MhachBLMRotation.He_Bao) then return MhachBLMRotation.Action(MhachBLMRotation.He_Bao, MhachBLMRotation.target) end
    if MhachBLMRotation.mp < 800 and MhachBLMRotation.aoeNum >= 2 and MhachBLMRotation.beilun <= 24 and MhachBLMRotation.fire_ice >= 1 and MhachBLMRotation.NotHold(MhachBLMRotation.Xing_Ling) then MhachBLMRotation.Action(MhachBLMRotation.Xing_Ling, MhachBLMRotation.player) end
    if MhachBLMRotation.aoeNum >= 2 and MhachBLMRotation.fire_ice <= -1 and MhachBLMRotation.ice_heart < 3 and MhachBLMRotation.NotHold(MhachBLMRotation.Ice_4) then return MhachBLMRotation.Action(MhachBLMRotation.Ice_4, target) end
    if MhachBLMRotation.aoeNum >= 3 and MhachBLMRotation.fire_ice <= -1 and MhachBLMRotation.ice_heart < 3 and MhachBLMRotation.NotHold(MhachBLMRotation.Ice_AOE) then return MhachBLMRotation.Action(MhachBLMRotation.Ice_AOE, target) end
    if MhachBLMRotation.aoeNum >= 2 and MhachBLMRotation.tongxiao >= 1 and MhachBLMRotation.fire_ice <= -1 and MhachBLMRotation.ice_heart == 3 and MhachBLM.BLM.Polyglot and MhachBLMRotation.NotHold(MhachBLMRotation.Hui_Zhuo) then return MhachBLMRotation.Action(MhachBLMRotation.Hui_Zhuo, target) end
    if MhachBLMRotation.aoeNum >= 2 and MhachBLMRotation.fire_ice <= -1 and MhachBLMRotation.ice_heart == 3 and MhachBLMRotation.NotHold(MhachBLMRotation.Xing_Ling) then MhachBLMRotation.Action(MhachBLMRotation.Xing_Ling, MhachBLMRotation.player) end
    if MhachBLMRotation.aoeNum >= 2 and MhachBLMRotation.fire_ice <= -1 and MhachBLMRotation.ice_heart == 3 and MhachBLMRotation.tongxiao < 1 and MhachBLMRotation.NotHold(MhachBLMRotation.Bei_Lun) then return MhachBLMRotation.Action(MhachBLMRotation.Bei_Lun, target) end
    if MhachBLMRotation.aoeNum >= 3 and MhachBLMRotation.fire_ice <= -1 and MhachBLMRotation.ice_heart == 3 and MhachBLMRotation.tongxiao < 1 and MhachBLMRotation.NotHold(MhachBLMRotation.Fire_5) then return MhachBLMRotation.Action(MhachBLMRotation.Fire_5, target) end
    if MhachBLMRotation.aoeNum >= 3 and TensorCore.hasBuff(MhachBLMRotation.player, 3870) and MhachBLM.BLM.DOT and MhachBLMRotation.MissinMhachBLMyBuff(target, MhachBLMRotation.DotBuffs) and MhachBLMRotation.NotHold(MhachBLMRotation.DOT_AOE_3) then return MhachBLMRotation.Action(MhachBLMRotation.DOT_AOE_3, target) end
end

MhachBLMRotation.Polyglot_Combo = function()--通晓循环
    MhachBLMRotation.target = TensorCore.mGetTarget()
	if  ((not MhachBLM.BLM.AOE) or aoeNum <= 1) then
		if MhachBLMRotation.tongxiao >= 3 and MhachBLMRotation.tongxiaoTime <= 50 and MhachBLMRotation.NotHold(MhachBLMRotation.Yi_Yan) then return MhachBLMRotation.Action(MhachBLMRotation.Yi_Yan, target) end
		if MhachBLMRotation.tongxiao >= 2 and MhachBLMRotation.Xiang_Shu.cd <= 6 and MhachBLMRotation.NotHold(MhachBLMRotation.Yi_Yan) then return MhachBLMRotation.Action(MhachBLMRotation.Yi_Yan, target) end
		if MhachBLMRotation.tongxiao >= 1 and not MhachBLM.BLM.More_Move and MhachBLMRotation.BurnTime(target) and MhachBLMRotation.NotHold(MhachBLMRotation.Yi_Yan) then return MhachBLMRotation.Action(MhachBLMRotation.Yi_Yan, target) end
	end
end

MhachBLMRotation.DOT_Combo = function()--dot循环
    MhachBLMRotation.target = TensorCore.mGetTarget()
	if TensorCore.hasBuff(MhachBLMRotation.player, 3870) and MhachBLMRotation.NotHold(MhachBLMRotation.DOT_3) then
		if MhachBLMRotation.MissinMhachBLMyBuff(target, MhachBLMRotation.DotBuffs) and not MhachBLM.BLM.Smart_Target and (MhachBLMRotation.aoeNum <= 2 or not MhachBLM.BLM.AOE) then return MhachBLMRotation.Action(MhachBLMRotation.DOT_3, target) end
		if (MhachBLMRotation.aoeNum <= 2 or not MhachBLM.BLM.AOE) and MhachBLM.BLM.Smart_Target then
			if MhachBLMRotation.aoeNum >= 2 then
				MhachBLMRotation.target = MhachBLMRotation.FindDotTarget(MhachBLMRotation.enemys)
				if target ~= nil  then
					return MhachBLMRotation.Action(MhachBLMRotation.DOT_3, target)
				end
	        end
		end
	end
end

MhachBLMRotation.Fire_Ice = function()--火转冰
    local canuse = MhachBLMRotation.Xing_Ling.cd <= 0 and MhachBLMRotation.NotHold(MhachBLMRotation.Ji_Ke) and MhachBLMRotation.NotHold(MhachBLMRotation.Xing_Ling)
	if MhachBLMRotation.Ji_Ke.cd <= 0 and canuse and MhachBLMRotation.beilun < 25 then
		MhachBLMRotation.Action(MhachBLMRotation.Ji_Ke, MhachBLMRotation.player)
	end
	if (MhachBLMRotation.ShunFaBuff()) and canuse then
		MhachBLMRotation.Action(MhachBLMRotation.Xing_Ling, MhachBLMRotation.player)
	end
	if MhachBLMRotation.NotHold(MhachBLMRotation.Ice_3) then return MhachBLMRotation.Action(MhachBLMRotation.Ice_3, MhachBLMRotation.target) end
end

MhachBLMRotation.Ice_Fire = function()--冰转火
	if ((MhachBLMRotation.Fire_4.cd/MhachBLMRotation.Fire_4.recasttime) >= 0.6) then return MhachBLMRotation.Action(MhachBLMRotation.Mo_Wen, MhachBLMRotation.player) end
end

MhachBLMRotation.LeyLines = function()--黑魔纹
    if (not TensorCore.hasBuff(MhachBLMRotation.player, 737)) and MhachBLMRotation.Mo_Wen:IsReady() and (MhachBLMRotation.fire_ice >= 3 or MhachBLM.BLM.Burn) and MhachBLMRotation.NotHold(MhachBLMRotation.Mo_Wen) then
		if ((MhachBLMRotation.Fire_4.cd/MhachBLMRotation.Fire_4.recasttime) >= 0.6) then return MhachBLMRotation.Action(MhachBLMRotation.Mo_Wen, MhachBLMRotation.player) end
	end
end

MhachBLMRotation.Move_Combo = function()--移动循环
    if ((not TensorCore.hasBuff(MhachBLMRotation.player, 165) and MhachBLMRotation.fire_ice >= 1) or (MhachBLMRotation.fire_ice <= -1)) and  (not MhachBLMRotation.ShunFaBuff()) and MhachBLMRotation.ParadoxGauge[MhachBLMRotation.beilun] and MhachBLMRotation.NotHold(MhachBLMRotation.Bei_Lun) then return MhachBLMRotation.Action(MhachBLMRotation.Bei_Lun, target) end
    if MhachBLMRotation.tongxiao >= 1 and MhachBLM.BLM.Polyglot and MhachBLMRotation.NotHold(MhachBLMRotation.Yi_Yan) then return MhachBLMRotation.Action(MhachBLMRotation.Yi_Yan, MhachBLMRotation.target) end
    if not MhachBLMRotation.ShunFaBuff() and MhachBLM.BLM.Triplecast and MhachBLMRotation.tongxiao <= 0 and MhachBLMRotation.San_Lian:IsReady() and MhachBLMRotation.NotHold(MhachBLMRotation.San_Lian) then
        if ((MhachBLMRotation.Fire_4.cd/MhachBLMRotation.Fire_4.recasttime) >= 0.7) then
            return MhachBLMRotation.Action(MhachBLMRotation.San_Lian, MhachBLMRotation.player)
        end	
    end
    if not MhachBLMRotation.ShunFaBuff() and MhachBLMRotation.tongxiao <= 0 and (not MhachBLMRotation.San_Lian:IsReady()) and MhachBLMRotation.NotHold(MhachBLMRotation.Ji_Ke) and MhachBLMRotation.Ji_Ke:IsReady() then
        if ((MhachBLMRotation.Fire_4.cd/MhachBLMRotation.Fire_4.recasttime) >= 0.7) then
            return MhachBLMRotation.Action(MhachBLMRotation.Ji_Ke, MhachBLMRotation.player)
        end
    end
end

MhachBLMRotation.BURN = function()--燃尽爆发
    if MhachBLMRotation.fire_ice >= 1 and MhachBLMRotation.beilun >= 25 and MhachBLMRotation.NotHold(MhachBLMRotation.Yao_Xing) then return MhachBLMRotation.Action(MhachBLMRotation.Yao_Xing, MhachBLMRotation.target) end
    if MhachBLMRotation.tongxiao >= 1 and MhachBLMRotation.NotHold(MhachBLMRotation.Yi_Yan) then return MhachBLMRotation.Action(MhachBLMRotation.Yi_Yan, MhachBLMRotation.target) end
    if MhachBLMRotation.fire_ice >= 1 and MhachBLMRotation.mp >= 800 and MhachBLMRotation.NotHold(MhachBLMRotation.He_Bao) then return MhachBLMRotation.Action(MhachBLMRotation.He_Bao, MhachBLMRotation.target) end
    if MhachBLMRotation.fire_ice >= 1 and MhachBLMRotation.mp and MhachBLMRotation.beilun <25 and MhachBLMRotation.NotHold(MhachBLMRotation.Xing_Ling) then MhachBLMRotation.Action(MhachBLMRotation.Xing_Ling, MhachBLMRotation.player) end
    if MhachBLMRotation.fire_ice <= -1 and MhachBLMRotation.ice_heart < 3 and MhachBLMRotation.NotHold(MhachBLMRotation.Ice_4) then return MhachBLMRotation.Action(MhachBLMRotation.Ice_4, target) end
    if MhachBLMRotation.ice_heart == 3 and MhachBLMRotation.fire_ice <= -1 and MhachBLMRotation.ParadoxGauge[MhachBLMRotation.beilun] and MhachBLMRotation.NotHold(MhachBLMRotation.Bei_Lun) then return MhachBLMRotation.Action(MhachBLMRotation.Bei_Lun, MhachBLMRotation.target) end
    if MhachBLMRotation.fire_ice <= -1 and MhachBLMRotation.ice_heart == 3 and (not MhachBLMRotation.ParadoxGauge[MhachBLMRotation.beilun]) and MhachBLMRotation.NotHold(MhachBLMRotation.Xing_Ling) then MhachBLMRotation.Action(MhachBLMRotation.Xing_Ling, MhachBLMRotation.player) end
end

MhachBLMRotation.Manafont = function()--魔泉
	if MhachBLMRotation.mp <800 and MhachBLMRotation.fire_ice == 3 and MhachBLMRotation.Mo_Quan:IsReady() and MhachBLMRotation.NotHold(MhachBLMRotation.Mo_Quan) then
		MhachBLMRotation.Action(MhachBLMRotation.Mo_Quan, MhachBLMRotation.player)
	end
end

MhachBLMRotation.Amplifier = function()--详述
    if MhachBLMRotation.tongxiao <= 2 and MhachBLMRotation.Xiang_Shu:IsReady() and MhachBLMRotation.NotHold(MhachBLMRotation.Xiang_Shu) then MhachBLMRotation.Action(MhachBLMRotation.Xiang_Shu, MhachBLMRotation.player) end
end

MhachBLMRotation.Fire = function()--火循环
    if MhachBLMRotation.fire_ice == 3 and MhachBLMRotation.beilun >= 25 and MhachBLMRotation.NotHold(MhachBLMRotation.Yao_Xing) then return MhachBLMRotation.Action(MhachBLMRotation.Yao_Xing, MhachBLMRotation.target) end
	if MhachBLMRotation.fire_ice == 1 and MhachBLMRotation.mp >= 1600 and (not TensorCore.hasBuff(MhachBLMRotation.player, 165)) and MhachBLMRotation.ParadoxGauge[MhachBLMRotation.beilun] and MhachBLMRotation.NotHold(MhachBLMRotation.Bei_Lun) then return MhachBLMRotation.Action(MhachBLMRotation.Bei_Lun, target) end
	if MhachBLMRotation.fire_ice == 3 and (not TensorCore.hasBuff(player, 165)) and MhachBLMRotation.mp>= 1600 and mp <= 3000 and MhachBLMRotation.beilun <= 3 and MhachBLMRotation.ParadoxGauge[MhachBLMRotation.beilun] and MhachBLMRotation.NotHold(MhachBLMRotation.Bei_Lun) then return MhachBLMRotation.Action(MhachBLMRotation.Bei_Lun, target) end
	if MhachBLMRotation.fire_ice == 1 and TensorCore.hasBuff(player, 165) and MhachBLMRotation.NotHold(MhachBLMRotation.Fire_3) then return MhachBLMRotation.Action(MhachBLMRotation.Fire_3, MhachBLMRotation.target) end
	if MhachBLMRotation.fire_ice == 3 and MhachBLMRotation.mp >= 1600 and MhachBLMRotation.NotHold(MhachBLMRotation.Fire_4) then return MhachBLMRotation.Action(MhachBLMRotation.Fire_4, target) end
	if MhachBLMRotation.mp >= 800 and MhachBLMRotation.mp <1600 and MhachBLMRotation.NotHold(MhachBLMRotation.Jue_Wang) then return MhachBLMRotation.Action(MhachBLMRotation.Jue_Wang, target) end
end

MhachBLMRotation.Ice = function()--冰循环
    if MhachBLMRotation.fire_ice == -3 and MhachBLMRotation.mp < 10000 and MhachBLMRotation.ice_heart <3 and MhachBLMRotation.NotHold(MhachBLMRotation.Ice_4) then return MhachBLMRotation.Action(MhachBLMRotation.Ice_4, target) end
	if MhachBLMRotation.fire_ice <= -1 and (MhachBLMRotation.ice_heart == 3 or MhachBLMRotation.mp == 10000) and MhachBLMRotation.ParadoxGauge[MhachBLMRotation.beilun] and MhachBLMRotation.NotHold(MhachBLMRotation.Bei_Lun) then return MhachBLMRotation.Action(MhachBLMRotation.Bei_Lun, target) end
end

MhachBLMRotation.Fix = function()--打aoe后对循环进行修补
    if MhachBLMRotation.beilun >= 25 and MhachBLMRotation.NotHold(MhachBLMRotation.Yao_Xing) then return MhachBLMRotation.Action(MhachBLMRotation.Yao_Xing, target) end
    if MhachBLMRotation.ShunFaBuff() and (MhachBLMRotation.fire_ice == -2 or MhachBLMRotation.fire_ice == -1) and MhachBLMRotation.NotHold(MhachBLMRotation.Ice_3) then return MhachBLMRotation.Action(MhachBLMRotation.Ice_3, target) end
	if (MhachBLMRotation.fire_ice == 1 or MhachBLMRotation.fire_ice == 2) then
		if MhachBLMRotation.Ji_Ke.cd <= 0 and MhachBLMRotation.NotHold(MhachBLMRotation.Ji_Ke) and (not TensorCore.hasBuff(MhachBLMRotation.player, 165)) and (not MhachBLMRotation.ParadoxGauge[MhachBLMRotation.beilun]) then return MhachBLMRotation.Action(MhachBLMRotation.Ji_Ke, MhachBLMRotation.player) end
		if (TensorCore.hasBuff(player, 165) or TensorCore.hasBuff(player, 167) or TensorCore.hasBuff(MhachBLMRotation.player, 1211)) and MhachBLMRotation.mp >= 2000 and MhachBLMRotation.ShunFaBuff() and MhachBLMRotation.NotHold(MhachBLMRotation.Fire_3) then return MhachBLMRotation.Action(MhachBLMRotation.Fire_3, target) end
		if MhachBLMRotation.NotHold(Ice_3) then return MhachBLMRotation.Action(MhachBLMRotation.Ice_3, target) end
	end
	if (MhachBLMRotation.fire_ice == -1 or MhachBLMRotation.fire_ice == -2) then
		if MhachBLMRotation.Ji_Ke.cd <= 0 and MhachBLMRotation.NotHold(MhachBLMRotation.Ji_Ke) then return MhachBLMRotation.Action(MhachBLMRotation.Ji_Ke, MhachBLMRotation.player) end
		if (TensorCore.hasBuff(MhachBLMRotation.player, 167) or TensorCore.hasBuff(MhachBLMRotation.player, 1211)) and MhachBLMRotation.mp < 10000 and MhachBLMRotation.ShunFaBuff() and MhachBLMRotation.NotHold(MhachBLMRotation.Ice_3) then return MhachBLMRotation.Action(MhachBLMRotation.Ice_3, target) end
		if MhachBLMRotation.mp >=800 or MhachBLMRotation.ice_heart == 3 and MhachBLMRotation.NotHold(MhachBLMRotation.Fire_3) then return MhachBLMRotation.Action(MhachBLMRotation.Fire_3, target) end
		if MhachBLMRotation.NotHold(MhachBLMRotation.Ice_4) then return MhachBLMRotation.Action(MhachBLMRotation.Ice_4, target) end
	end
	if MhachBLMRotation.fire_ice == 0 and MhachBLMRotation.NotHold(MhachBLMRotation.Fire_3) then return MhachBLMRotation.Action(MhachBLMRotation.Fire_3, target) end
end


MhachBLMRotation.test = 2

MhachBLMRotation.Rotation = function()--循环逻辑
    if Player.alive and not (Busy() or IsMounting() or IsMounted() or IsDismounting() or MIsLoading() or IsFlying() or IsDiving()) then
		MhachBLMRotation.SetValue()  --设置本地变量
		if #MhachBLMRotation.HoldList ~= 0 then  --hold技能逻辑
			MhachBLMRotation.lastTime = MhachBLMRotation.nowTime
			MhachBLMRotation.nowTime = Now()
			MhachBLMRotation.fpsTime = (MhachBLMRotation.nowTime - MhachBLMRotation.lastTime)/1000
			if MhachBLMRotation.fpsTime > 3 then  --去掉初始计算帧
				MhachBLMRotation.fpsTime = 0
			end
			--d(fpsTime)   --优化前 0.063，4.438，6.312，1.766
			MhachBLMRotation.CalHold()
		end

		if MhachBLMRotation.HasTarget() and (not MhachBLMRotation.PlayerSkills:isEmpty()) then  --用户自定义循环逻辑
			MhachBLMRotation.Action(MhachBLMRotation.PlayerSkills:peek(), target)
			if MhachBLMRotation.lastcast == MhachBLMRotation.PlayerSkills:peek() then
				MhachBLMRotation.PlayerSkills:dequeue()
			end
		end

		if MhachBLMRotation.HasTarget() and MhachBLMRotation.PlayerSkills:isEmpty() then
			MhachBLMRotation.TargetSet()
			if MhachBLMRotation.moving then
				MhachBLMRotation.Move_Combo()
			end
			if not MhachBLM.BLM.Burn then
				if MhachBLM.BLM.AOE then MhachBLMRotation.AOE_Combo() end
				if MhachBLM.BLM.Polyglot then MhachBLMRotation.Polyglot_Combo() end
				if MhachBLM.BLM.DOT then MhachBLMRotation.DOT_Combo() end
			end
			MhachBLMRotation.target = TensorCore.mGetTarget()
			
			if MhachBLM.BLM.Burn then MhachBLMRotation.BURN() end
			if MhachBLM.BLM.Ley_Lines and MhachBLM.BLM.CD then MhachBLMRotation.LeyLines() end
			if MhachBLM.BLM.Manafont and MhachBLM.BLM.CD then MhachBLMRotation.Manafont() end
			if MhachBLM.BLM.Amplifier and MhachBLM.BLM.CD then MhachBLMRotation.Amplifier() end
			
			if ((not MhachBLM.BLM.AOE) or MhachBLM.Target.aoe_num <= 1) and not MhachBLM.BLM.Burn then
				MhachBLMRotation.Fire_Ice()
				MhachBLMRotation.Ice_Fire()
				if MhachBLMRotation.fire_ice >= 1 then
					MhachBLMRotation.Fire()
				end
				if MhachBLMRotation.fire_ice <= -1 then
					MhachBLMRotation.Ice()
				end
				MhachBLMRotation.Fix()
			end
		elseif (not MhachBLMRotation.incombat) and (not MhachBLMRotation.HasTarget()) and MhachBLM.Target.aoe_num ~= 0 and MhachBLMRotation.PlayerSkills:isEmpty() then
			MhachBLM.Target.aoe_num = 0
		elseif (not MhachBLMRotation.incombat) and MhachBLMRotation.player.gauge[2] == 0 and MhachBLMRotation.player.castinginfo.lastcastid == 152 and MhachBLMRotation.PlayerSkills:isEmpty() then
			return MhachBLMRotation.Action(MhachBLMRotation.DOT_3, TensorCore.mGetTarget())
		end
	end
end

return MhachBLMRotation