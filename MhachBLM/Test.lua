local MhachBLMTest = {}
local player
local playerid = 0
local playerlevel = 1
local incombat = false
local moving = false
local fire_ice = 0  --冰火状态
local ice_heart = 0  --灵极心
local tongxiao = 0  --通晓量谱
local beilun = 0  --悖论量谱
local mp = 0  --mp值
local lastcast = 0
local alive = true
local tongxiaotime = 0  --通晓条时间
local aoe_num = 1  --范围内敌人数量
local expectation = {}
local ParadoxGauge = {[3] = true, [7] = true, [11] = true, [15] = true, [19] = true, [23] = true, [27] = true}  --悖论量谱快速鉴定






local STATE_FIRE = "fire"
local STATE_ICE = "ice"
local STATE_CHANGETO_FIRE = "iceTofire"
local STATE_CHANGETO_ICE = "fireToice"
local STATE_MOVING = "moving"
local STATE_START = "start"
local NOW_STATE = ""
local function HasBuff(player, id)
    return false
end
local SkillQueue = {}  --技能队列

MhachBLMTest.SkillsTest = {
    [142] = {--冰结
        Inform = {
            Name = "冰结",
            ID = 142,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 1,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 0,  -- 技能半径
            cd = 0, --cd
            ppg = 180,
            attribute = -1, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = -400,
            Ling_JixinChange = 0, --灵极心变化
            Fire_IceChange = -1,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            if fire_ice >= 1 then  --火状态
                self.Inform.ppg = (1 - fire_ice/10) * 180
                self.Cost.MpChange = 0
            elseif fire_ice <= -1 then  --冰状态
                self.Inform.ppg = 180
                self.Cost.MpChange = 1250*2^math.abs(fire_ice)
            else  --无冰火
                self.Inform.ppg = 180
                self.Cost.MpChange = -400
            end
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (NOW_STATE == STATE_CHANGETO_ICE or NOW_STATE == STATE_ICE) and fire_ice > -3 then
                    exp = self.Inform.ppg -10*self.Cost.Fire_IceChange
                else
                    exp = self.Inform.ppg
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [141] = {--火炎
        Inform = {
            Name = "火炎",
            ID = 141,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 2,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 0,  -- 技能半径
            cd = 0, --cd
            ppg = 180,
            attribute = 1, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = -800,
            Ling_JixinChange = -1, --灵极心变化
            Fire_IceChange = 1,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            if fire_ice >= 1 then  --火状态
                self.Inform.ppg = (1.2+0.2*fire_ice) * 180
                if ice_heart <= 0 then
                    self.Cost.MpChange = -1600
                    self.Cost.Ling_JixinChange = 0
                else
                    self.Cost.MpChange = -800
                    self.Cost.Ling_JixinChange = -1
                end
            elseif fire_ice <= -1 then  --冰状态
                self.Inform.ppg = (1 - math.abs(fire_ice)/10) * 180
                self.Cost.MpChange = 0
                self.Cost.Ling_JixinChange = 0
            else  --无冰火
                self.Inform.ppg = 180
                self.Cost.MpChange = -800
                self.Cost.Ling_JixinChange = 0
            end
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (NOW_STATE == STATE_CHANGETO_FIRE or NOW_STATE == STATE_FIRE) and fire_ice < 3 then
                    exp = self.Inform.ppg + 10*self.Cost.Fire_IceChange
                else
                    exp = self.Inform.ppg
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [149] = {--星灵移位
        Inform = {
            Name = "星灵移位",
            ID = 149,  -- 技能id
            IsGCD = false,  -- 是否为gcd技能
            level = 4,  -- 技能等级
            range = 0,  -- 技能距离
            radius = 0,  -- 技能半径
            cd = 5, --cd
            ppg = 0,
            attribute = 0, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = 0,
            Ling_JixinChange = 0, --灵极心变化
            Fire_IceChange = 4,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法-----------------------------------------------------更新cd？
            return true
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if NOW_STATE == STATE_CHANGETO_ICE or NOW_STATE == STATE_CHANGETO_FIRE then
                  ----------------------------------------------------------------------------------------
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 and self.Inform.cd <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [25793] = {--冰冻
        Inform = {
            Name = "冰冻",
            ID = 25793,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 12,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 5,  -- 技能半径
            cd = 0, --cd
            ppg = 80,
            attribute = -1, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = -800,
            Ling_JixinChange = 0, --灵极心变化
            Fire_IceChange = -3,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            if fire_ice >= 1 then  --火状态
                self.Inform.ppg = (1 - fire_ice/10) * 80
                self.Cost.MpChange = 0
            elseif fire_ice <= -1 then  --冰状态
                self.Inform.ppg = 80
                self.Cost.MpChange = 1250*2^math.abs(fire_ice)
            else  --无冰火
                self.Inform.ppg = 80
                self.Cost.MpChange = -800
            end
            
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (NOW_STATE == STATE_CHANGETO_ICE or NOW_STATE == STATE_ICE) and fire_ice > -3 then
                    exp = self.Inform.ppg*aoe_num - 10*self.Cost.Fire_IceChange
                else
                    exp = self.Inform.ppg
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [156] = {
        Inform = {
            Name = "崩溃",
            ID = 156,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 15,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 0,  -- 技能半径
            cd = 0, --cd
            ppg = 100,
            attribute = 0, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = -800,
            Ling_JixinChange = 0, --灵极心变化
            Fire_IceChange = 0,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            return true
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [147] = {
        Inform = {
            Name = "烈炎",
            ID = 147,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 18,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 5,  -- 技能半径
            cd = 0, --cd
            ppg = 80,
            attribute = 1, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = -1500,
            Ling_JixinChange = -1, --灵极心变化
            Fire_IceChange = 3,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            if fire_ice >= 1 then  --火状态
                self.Inform.ppg = (1.2+0.2*fire_ice) * 80
                if ice_heart <= 0 then
                    self.Cost.MpChange = -3000
                    self.Cost.Ling_JixinChange = 0
                else
                    self.Cost.MpChange = -1500
                    self.Cost.Ling_JixinChange = -1
                end
            elseif fire_ice <= -1 then  --冰状态
                self.Inform.ppg = (1 - math.abs(fire_ice)/10) * 80
                self.Cost.MpChange = 0
                self.Cost.Ling_JixinChange = 0
            else  --无冰火
                self.Inform.ppg = 80
                self.Cost.MpChange = -1500
                self.Cost.Ling_JixinChange = 0
            end
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (NOW_STATE == STATE_CHANGETO_FIRE or NOW_STATE == STATE_FIRE) and fire_ice < 3 then
                    exp = self.Inform.ppg*aoe_num
                else
                    exp = self.Inform.ppg
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [152] = {
        Inform = {
            Name = "爆炎",
            ID = 152,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 35,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 0,  -- 技能半径
            cd = 0, --cd
            ppg = 290,
            attribute = 1, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = -2000,
            Ling_JixinChange = -1, --灵极心变化
            Fire_IceChange = 3,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            if fire_ice >= 1 then  --火状态
                self.Inform.ppg = (1.2+0.2*fire_ice) * 290
                if HasBuff(player, 165) then
                    self.Cost.MpChange = 0
                    self.Cost.Ling_JixinChange = 0
                elseif ice_heart <= 0 then
                    self.Cost.MpChange = -4000
                    self.Cost.Ling_JixinChange = 0
                else
                    self.Cost.MpChange = -2000
                    self.Cost.Ling_JixinChange = -1
                end
            elseif fire_ice <= -1 then  --冰状态
                self.Inform.ppg = (1 - math.abs(fire_ice)/10) * 290
                self.Cost.MpChange = 0
                self.Cost.Ling_JixinChange = 0
            else  --无冰火
                self.Inform.ppg = 290
                self.Cost.MpChange = -2000
                self.Cost.Ling_JixinChange = 0
            end
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (NOW_STATE == STATE_CHANGETO_FIRE or NOW_STATE == STATE_FIRE) and fire_ice < 3 then
                    exp = self.Inform.ppg + 10*self.Cost.Fire_IceChange
                else
                    exp = self.Inform.ppg
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [158] = {
        Inform = {
            Name = "魔泉",
            ID = 158,  -- 技能id
            IsGCD = false,  -- 是否为gcd技能
            level = 30,  -- 技能等级
            range = 0,  -- 技能距离
            radius = 0,  -- 技能半径
            cd = 100, --cd
            ppg = 0,
            attribute = 0, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = 10000,
            Ling_JixinChange = 3, --灵极心变化
            Fire_IceChange = 0,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 1,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            return true
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 and self.Inform.cd <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [154] = {
        Inform = {
            Name = "冰封",
            ID = 154,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 35,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 0,  -- 技能半径
            cd = 0, --cd
            ppg = 290,
            attribute = -1, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = -800,
            Ling_JixinChange = 0, --灵极心变化
            Fire_IceChange = -3,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            if fire_ice >= 1 then  --火状态
                self.Inform.ppg = (1 - fire_ice/10) * 290
                self.Cost.MpChange = 0
            elseif fire_ice <= -1 then  --冰状态
                self.Inform.ppg = 290
                self.Cost.MpChange = 1250*2^math.abs(fire_ice)
            else  --无冰火
                self.Inform.ppg = 290
                self.Cost.MpChange = -800
            end
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (NOW_STATE == STATE_CHANGETO_ICE or NOW_STATE == STATE_ICE) and fire_ice > -3 then
                    exp = self.Inform.ppg - 10*self.Cost.Fire_IceChange
                else
                    exp = self.Inform.ppg
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [16506] = {
        Inform = {
            Name = "灵极魂",
            ID = 16506,  -- 技能id
            IsGCD = false,  -- 是否为gcd技能
            level = 35,  -- 技能等级
            range = 0,  -- 技能距离
            radius = 0,  -- 技能半径
            cd = 0, --cd
            ppg = 0,
            attribute = -1, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = 0,
            Ling_JixinChange = 1, --灵极心变化
            Fire_IceChange = -1,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (NOW_STATE == STATE_CHANGETO_ICE or NOW_STATE == STATE_ICE) and fire_ice > -3 then
                    exp = 100*self.Cost.Ling_JixinChange - 10*self.Cost.Fire_IceChange
                else
                    exp = self.Inform.ppg
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [159] = {
        Inform = {
            Name = "玄冰",
            ID = 159,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 40,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 5,  -- 技能半径
            cd = 0, --cd
            ppg = 120,
            attribute = -1, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = -1000,
            Ling_JixinChange = 3, --灵极心变化
            Fire_IceChange = 0,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            if fire_ice >= 1 then  --火状态
                self.Inform.ppg = 0
                self.Cost.MpChange = 0
            elseif fire_ice <= -1 then  --冰状态
                self.Inform.ppg = 120
                self.Cost.MpChange = 1250*2^math.abs(fire_ice)
            else  --无冰火
                self.Inform.ppg = 0
                self.Cost.MpChange = 0
            end
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (NOW_STATE == STATE_ICE) then
                    exp = self.Inform.ppg*aoe_num + (3-ice_heart)*100+(10000-mp)/40
                else
                    exp = self.Inform.ppg
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [162] = {
        Inform = {
            Name = "核爆",
            ID = 162,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 50,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 5,  -- 技能半径
            cd = 0, --cd
            ppg = 240,
            attribute = 1, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = -10000,
            Ling_JixinChange = -3, --灵极心变化
            Fire_IceChange = 3,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 3,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            if fire_ice >= 1 then  --火状态
                self.Inform.ppg = (1.2+0.2*fire_ice) * 240
                if ice_heart <= 0 then
                    self.Cost.MpChange = -800
                    self.Cost.Ling_JixinChange = 0
                else
                    self.Cost.MpChange = -6600
                    self.Cost.Ling_JixinChange = -3
                end
            elseif fire_ice <= -1 then  --冰状态
                self.Inform.ppg = 0
                self.Cost.MpChange = 0
                self.Cost.Ling_JixinChange = 0
            else  --无冰火
                self.Inform.ppg = 0
                self.Cost.MpChange = 0
                self.Cost.Ling_JixinChange = 0
            end
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (NOW_STATE == STATE_FIRE) and fire_ice < 3 then
                    exp = self.Inform.ppg*aoe_num
                else
                    exp = self.Inform.ppg
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [3576] = {
        Inform = {
            Name = "冰澈",
            ID = 3576,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 58,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 0,  -- 技能半径
            cd = 0, --cd
            ppg = 300,
            attribute = -1, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = -800,
            Ling_JixinChange = 3, --灵极心变化
            Fire_IceChange = 0,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            if fire_ice >= 1 then  --火状态
                self.Inform.ppg = 0
                self.Cost.MpChange = 0
            elseif fire_ice <= -1 then  --冰状态
                self.Inform.ppg = 300
                self.Cost.MpChange = 1250*2^math.abs(fire_ice)
            else  --无冰火
                self.Inform.ppg = 0
                self.Cost.MpChange = 0
            end
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (NOW_STATE == STATE_ICE) then
                    exp = self.Inform.ppg + (3-ice_heart)*100+(10000-mp)/40
                else
                    exp = self.Inform.ppg
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [3577] = {
        Inform = {
            Name = "炽炎",
            ID = 3577,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 60,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 0,  -- 技能半径
            cd = 0, --cd
            ppg = 300,
            attribute = 1, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = -800,
            Ling_JixinChange = -1, --灵极心变化
            Fire_IceChange = 0,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 1,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            if fire_ice >= 1 then  --火状态
                self.Inform.ppg = (1.2+0.2*fire_ice) * 300
                if ice_heart <= 0 then
                    self.Cost.MpChange = -1600
                    self.Cost.Ling_JixinChange = 0
                else
                    self.Cost.MpChange = -800
                    self.Cost.Ling_JixinChange = -1
                end
            elseif fire_ice <= -1 then  --冰状态
                self.Inform.ppg = 0
                self.Cost.MpChange = 0
                self.Cost.Ling_JixinChange = 0
            else  --无冰火
                self.Inform.ppg = 0
                self.Cost.MpChange = 0
                self.Cost.Ling_JixinChange = 0
            end
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (NOW_STATE == STATE_FIRE) then
                    exp = self.Inform.ppg + 150
                else
                    exp = 0
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [7422] = {
        Inform = {
            Name = "秽浊",
            ID = 7422,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 70,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 5,  -- 技能半径
            cd = 0, --cd
            ppg = 600,
            attribute = 0, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = 0,
            Ling_JixinChange = 0, --灵极心变化
            Fire_IceChange = 0,  --冰火状态变化
            Tong_XiaoChange = -1,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            return true
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (tongxiao >= 3) then
                    exp = self.Inform.ppg*aoe_num
                else
                    exp = self.Inform.ppg
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 and tongxiao >= 3 and tongxiaotime <= 40 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [16505] = {
        Inform = {
            Name = "绝望",
            ID = 16505,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 72,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 0,  -- 技能半径
            cd = 0, --cd
            ppg = 350,
            attribute = 1, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = -800,
            Ling_JixinChange = 0, --灵极心变化
            Fire_IceChange = 3,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            if fire_ice >= 1 then  --火状态
                self.Inform.ppg = (1.2+0.2*fire_ice) * 350
            elseif fire_ice <= -1 then  --冰状态
                self.Inform.ppg = 0
            else  --无冰火
                self.Inform.ppg = 0
            end
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (NOW_STATE == STATE_FIRE) then
                    exp = self.Inform.ppg - (10000 - mp)/50
                else
                    exp = self.Inform.ppg
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [16507] = {
        Inform = {
            Name = "异言",
            ID = 16507,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 80,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 0,  -- 技能半径
            cd = 0, --cd
            ppg = 890,
            attribute = 0, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = 0,
            Ling_JixinChange = 0, --灵极心变化
            Fire_IceChange = 0,  --冰火状态变化
            Tong_XiaoChange = -1,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            return true
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (tongxiao >= 3) then
                    exp = self.Inform.ppg
                else
                    exp = self.Inform.ppg
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 and tongxiao >= 3 and tongxiaotime <= 40 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [25794] = {
        Inform = {
            Name = "高烈炎",
            ID = 25794,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 82,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 5,  -- 技能半径
            cd = 0, --cd
            ppg = 100,
            attribute = 1, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = -1500,
            Ling_JixinChange = -1, --灵极心变化
            Fire_IceChange = 3,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            if fire_ice >= 1 then  --火状态
                self.Inform.ppg = (1.2+0.2*fire_ice) * 100
                if ice_heart <= 0 then
                    self.Cost.MpChange = -3000
                    self.Cost.Ling_JixinChange = 0
                else
                    self.Cost.MpChange = -1500
                    self.Cost.Ling_JixinChange = -1
                end
            elseif fire_ice <= -1 then  --冰状态
                self.Inform.ppg = (1 - math.abs(fire_ice)/10) * 100
                self.Cost.MpChange = 0
                self.Cost.Ling_JixinChange = 0
            else  --无冰火
                self.Inform.ppg = 100
                self.Cost.MpChange = -1500
                self.Cost.Ling_JixinChange = 0
            end
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (NOW_STATE == STATE_CHANGETO_FIRE or NOW_STATE == STATE_FIRE) and fire_ice < 3 then
                    exp = self.Inform.ppg*aoe_num + 10*self.Cost.Fire_IceChange
                else
                    exp = self.Inform.ppg
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [25795] = {
        Inform = {
            Name = "高冰冻",
            ID = 25795,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 82,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 5,  -- 技能半径
            cd = 0, --cd
            ppg = 100,
            attribute = -1, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = -1500,
            Ling_JixinChange = 0, --灵极心变化
            Fire_IceChange = -3,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            if fire_ice >= 1 then  --火状态
                self.Inform.ppg = (1 - fire_ice/10) * 100
                self.Cost.MpChange = 0
            elseif fire_ice <= -1 then  --冰状态
                self.Inform.ppg = 100
                self.Cost.MpChange = 1250*2^math.abs(fire_ice)
            else  --无冰火
                self.Inform.ppg = 100
                self.Cost.MpChange = -1500
            end
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (NOW_STATE == STATE_CHANGETO_ICE or NOW_STATE == STATE_ICE) and fire_ice > -3 then
                    exp = self.Inform.ppg*aoe_num - 10*self.Cost.Fire_IceChange
                else
                    exp = self.Inform.ppg
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [36989] = {
        Inform = {
            Name = "耀星",
            ID = 36989,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 100,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 0,  -- 技能半径
            cd = 0, --cd
            ppg = 500,
            attribute = 1, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = 0,
            Ling_JixinChange = 0, --灵极心变化
            Fire_IceChange = 0,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = 0,  --悖论变化
            Xing_JiChange = -6,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            if fire_ice >= 1 then  --火状态
                self.Inform.ppg = (1.2+0.2*fire_ice) * 500
            elseif fire_ice <= -1 then  --冰状态
                self.Inform.ppg = 0
                self.Cost.MpChange = 0
                self.Cost.Ling_JixinChange = 0
            else  --无冰火
                self.Inform.ppg = 0
                self.Cost.MpChange = 0
                self.Cost.Ling_JixinChange = 0
            end
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (NOW_STATE == STATE_FIRE) then
                    exp = self.Inform.ppg + 600
                else
                    exp = 0
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and self.holdTime <= 0 and beilun >= 25 then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

    [25797] = {
        Inform = {
            Name = "悖论",
            ID = 25797,  -- 技能id
            IsGCD = true,  -- 是否为gcd技能
            level = 90,  -- 技能等级
            range = 25,  -- 技能距离
            radius = 0,  -- 技能半径
            cd = 0, --cd
            ppg = 540,
            attribute = 0, --1火，-1冰，0无属性
        },
        Cost = {
            MpChange = 0,
            Ling_JixinChange = 0, --灵极心变化
            Fire_IceChange = 0,  --冰火状态变化
            Tong_XiaoChange = 0,  --通晓变化
            Bei_LunChange = -1,  --悖论变化
            Xing_JiChange = 0,  --星级变化
        },
        holdTime = 0,  --延后时间
        Canuse = true,
        Update = function (self)
            --更新数值方法
            if NOW_STATE == STATE_FIRE then
                self.Cost.MpChange = -1600
            elseif NOW_STATE == STATE_ICE then
                self.Cost.MpChange = 0
            else
                self.Cost.MpChange = 0
            end
            return true
        end,
        Cal = function (self)
            --计算优先级方法
            local exp = 0
            if self:Check() then
                if (NOW_STATE == STATE_ICE) and (ice_heart == 3 or mp == 10000) then
                    exp = self.Inform.ppg
                elseif NOW_STATE == STATE_FIRE and fire_ice == 1 and (not HasBuff(player, 165)) then
                    exp = self.Inform.ppg + 300
                elseif  NOW_STATE == STATE_FIRE and fire_ice == 3 and (not HasBuff(player, 165)) and mp <= 3000 and beilun <= 3 then
                    exp = self.Inform.ppg + 200
                end
                expectation[self.Inform.ID] = exp
            else
                expectation[self.Inform.ID] = 0
            end

        end,

        Check = function (self)  --检查技能是否可用
            if playerlevel >= self.Inform.level and (mp + self.Cost.MpChange) >= 0 and self.holdTime <= 0  and ParadoxGauge[beilun] then
                self.Canuse = true
                return true
            else
                self.Canuse = false
                return false
            end
        end
    },

}



MhachBLMTest.SetValue = function (Player, num) --为本地变量赋值
    player = Player
    playerlevel = player.level
	fire_ice = player.gauge[2]
	ice_heart = player.gauge[1]
	tongxiao = player.gauge[5]
	beilun = player.gauge[3]
	mp = player.mp.current
    aoe_num = num
    tongxiaotime = player.gaugetest[2] --剩余秒数*4
end

local UpdateData = function ()
    for i, data in pairs(MhachBLMTest.SkillsTest) do
        if data.Canuse then
            data:Update()
            data:Cal()
        end
     end
end

local FindBest = function (list)
    local maxValue = nil
    local maxKey = nil
    for key, value in pairs(list) do
        if maxValue == nil or value > maxValue then
            maxValue = value
            maxKey = key
        end
    end

    return maxKey
end

MhachBLMTest.ChangeState = function (state)
    NOW_STATE = state
end

MhachBLMTest.StateDo = function ()
    if NOW_STATE == STATE_CHANGETO_FIRE then

    elseif NOW_STATE == STATE_CHANGETO_ICE then

    elseif NOW_STATE == STATE_FIRE then
        UpdateData()
        return FindBest(expectation)
    elseif NOW_STATE == STATE_ICE then
        UpdateData()
        return FindBest(expectation)
    elseif NOW_STATE == STATE_MOVING then

    elseif NOW_STATE == STATE_START then

    end
end
MhachBLMTest.test = 2
--TensorCore.hasBuff(v, 1038)

-- 全局资源定义 (根据您的实际系统调整)
local ResourceLimits = {
    MP_MAX = 10000,
    MP_MIN = 0,
    LING_JIXIN_MAX = 3,    -- 灵极心上限
    LING_JIXIN_MIN = 0,
    FIRE_ICE_MAX = 3,      -- 冰火状态范围 [-3, 3]
    FIRE_ICE_MIN = -3,
    TONG_XIAO_MAX = 3,     -- 通晓上限
    TONG_XIAO_MIN = 0,
    BEI_LUN_MAX = 8,       -- 悖论上限
    BEI_LUN_MIN = 0,
    XING_JI_MAX = 6,       -- 星级上限
    XING_JI_MIN = 0,
}

-- 技能序列规划函数 (多资源约束版本)
function planSkillSequence(
    playerLevel,          -- 玩家等级
    currentResources,     -- 当前资源表 {mp, ling_jixin, fire_ice, tong_xiao, bei_lun, xing_ji}
    targetSkillCount,     -- 需要规划的技能数量
    skillTable            -- 技能表 MhachBLMTest.SkillsTest
)
    -- 参数检查
    if targetSkillCount <= 0 then 
        return {skillQueue = {}, resourceAtEachSkill = {}}
    end
    
    -- 步骤1: 资源状态离散化函数
    local function discretizeResources(resources)
        -- 将连续资源离散化为状态ID，减少状态空间
        -- 这里需要根据实际资源重要性调整离散化粒度
        local stateId = 
            math.floor(resources.mp / 500) * 1000000 +  -- MP每500一个bin
            resources.ling_jixin * 100000 +
            (resources.fire_ice + 3) * 10000 +  -- fire_ice范围[-3,3]映射到[0,6]
            resources.tong_xiao * 1000 +
            math.min(resources.bei_lun, 8) * 100 +
            math.min(resources.xing_ji, 6)
        return stateId
    end
    
    -- 步骤2: 构建可用技能列表
    local availableSkills = {}
    for skillID, skillData in pairs(skillTable) do
        if skillData.Inform and skillData.Inform.level <= playerLevel then
            -- 预处理技能数据
            local skill = {
                id = skillData.Inform.ID,
                name = skillData.Inform.Name,
                level = skillData.Inform.level,
                isGCD = skillData.Inform.IsGCD or false,
                priority = skillData.Inform.ppg or 0,
                cost = skillData.Cost or {},
                canUse = skillData.Canuse ~= false,
                checkFunc = skillData.Check,    -- 保存检查函数
                updateFunc = skillData.Update,  -- 保存更新函数
                calFunc = skillData.Cal         -- 保存计算函数
            }
            table.insert(availableSkills, skill)
        end
    end
    
    if #availableSkills == 0 then
        return {skillQueue = {}, resourceAtEachSkill = {}}
    end
    
    -- 步骤3: 检查技能是否可用的函数
    local function canUseSkill(skill, resources, step)
        -- 基本可用性检查
        if not skill.canUse then return false end
        
        -- 检查资源是否足够
        local cost = skill.cost
        local newMP = resources.mp + (cost.MpChange or 0)
        local newLingJixin = resources.ling_jixin + (cost.Ling_JixinChange or 0)
        local newFireIce = resources.fire_ice + (cost.Fire_IceChange or 0)
        local newTongXiao = resources.tong_xiao + (cost.Tong_XiaoChange or 0)
        local newBeiLun = resources.bei_lun + (cost.Bei_LunChange or 0)
        local newXingJi = resources.xing_ji + (cost.Xing_JiChange or 0)
        
        -- 检查资源边界
        if newMP < ResourceLimits.MP_MIN or newMP > ResourceLimits.MP_MAX then
            return false
        end
        if newLingJixin < ResourceLimits.LING_JIXIN_MIN or 
           newLingJixin > ResourceLimits.LING_JIXIN_MAX then
            return false
        end
        if newFireIce < ResourceLimits.FIRE_ICE_MIN or 
           newFireIce > ResourceLimits.FIRE_ICE_MAX then
            return false
        end
        if newTongXiao < ResourceLimits.TONG_XIAO_MIN or 
           newTongXiao > ResourceLimits.TONG_XIAO_MAX then
            return false
        end
        if newBeiLun < ResourceLimits.BEI_LUN_MIN or 
           newBeiLun > ResourceLimits.BEI_LUN_MAX then
            return false
        end
        if newXingJi < ResourceLimits.XING_JI_MIN or 
           newXingJi > ResourceLimits.XING_JI_MAX then
            return false
        end
        
        -- 调用技能的Check函数（如果存在）
        if skill.checkFunc then
            -- 这里需要设置全局状态变量供Check函数使用
            -- 假设全局变量名为: mp, ling_jixin, fire_ice, tong_xiao, bei_lun, xing_ji
            mp, ling_jixin, fire_ice, tong_xiao, bei_lun, xing_ji = 
                resources.mp, resources.ling_jixin, resources.fire_ice, 
                resources.tong_xiao, resources.bei_lun, resources.xing_ji
                
            if not skill.checkFunc() then
                return false
            end
        end
        
        return true
    end
    
    -- 步骤4: 应用技能消耗的函数
    local function applySkillCost(skill, resources)
        local newResources = {
            mp = resources.mp + (skill.cost.MpChange or 0),
            ling_jixin = resources.ling_jixin + (skill.cost.Ling_JixinChange or 0),
            fire_ice = resources.fire_ice + (skill.cost.Fire_IceChange or 0),
            tong_xiao = resources.tong_xiao + (skill.cost.Tong_XiaoChange or 0),
            bei_lun = resources.bei_lun + (skill.cost.Bei_LunChange or 0),
            xing_ji = resources.xing_ji + (skill.cost.Xing_JiChange or 0)
        }
        
        -- 边界截断
        newResources.mp = math.max(ResourceLimits.MP_MIN, 
                                  math.min(ResourceLimits.MP_MAX, newResources.mp))
        newResources.ling_jixin = math.max(ResourceLimits.LING_JIXIN_MIN,
                                         math.min(ResourceLimits.LING_JIXIN_MAX, newResources.ling_jixin))
        newResources.fire_ice = math.max(ResourceLimits.FIRE_ICE_MIN,
                                       math.min(ResourceLimits.FIRE_ICE_MAX, newResources.fire_ice))
        newResources.tong_xiao = math.max(ResourceLimits.TONG_XIAO_MIN,
                                        math.min(ResourceLimits.TONG_XIAO_MAX, newResources.tong_xiao))
        newResources.bei_lun = math.max(ResourceLimits.BEI_LUN_MIN,
                                      math.min(ResourceLimits.BEI_LUN_MAX, newResources.bei_lun))
        newResources.xing_ji = math.max(ResourceLimits.XING_JI_MIN,
                                      math.min(ResourceLimits.XING_JI_MAX, newResources.xing_ji))
        
        return newResources
    end
    
    -- 步骤5: 计算技能优先级的函数
    local function calculateSkillPriority(skill, resources, step)
        -- 如果有Cal函数，调用它
        if skill.calFunc then
            -- 设置全局状态
            mp, ling_jixin, fire_ice, tong_xiao, bei_lun, xing_ji = 
                resources.mp, resources.ling_jixin, resources.fire_ice, 
                resources.tong_xiao, resources.bei_lun, resources.xing_ji
            
            skill.calFunc()
            
            -- 从全局的expectation表中获取优先级
            -- 假设有一个全局的expectation表，如您的代码所示
            if expectation and expectation[skill.id] then
                return expectation[skill.id]
            end
        end
        
        -- 否则使用默认优先级
        return skill.priority or 0
    end
    
    -- 步骤6: 动态规划主算法
    local dp = {}  -- dp[step][stateId] = {skillSequence, totalPriority, resources}
    local stateMap = {}  -- stateId -> 资源状态映射
    
    -- 初始化第0步
    dp[0] = {}
    local initialStateId = discretizeResources(currentResources)
    dp[0][initialStateId] = {
        skillSequence = {},
        totalPriority = 0,
        resources = currentResources
    }
    stateMap[initialStateId] = currentResources
    
    -- 递推
    for step = 0, targetSkillCount - 1 do
        dp[step + 1] = {}
        
        for stateId, stateData in pairs(dp[step]) do
            local currentResources = stateData.resources
            local currentSequence = stateData.skillSequence
            local currentPriority = stateData.totalPriority
            
            -- 尝试所有可用技能
            for _, skill in ipairs(availableSkills) do
                if canUseSkill(skill, currentResources, step) then
                    -- 计算新资源
                    local newResources = applySkillCost(skill, currentResources)
                    
                    -- 计算技能优先级
                    local skillPriority = calculateSkillPriority(skill, currentResources, step)
                    
                    -- 计算新状态ID
                    local newStateId = discretizeResources(newResources)
                    
                    -- 新序列
                    local newSequence = {}
                    for _, s in ipairs(currentSequence) do
                        table.insert(newSequence, s)
                    end
                    table.insert(newSequence, {
                        id = skill.id,
                        name = skill.name,
                        priority = skillPriority
                    })
                    
                    local newTotalPriority = currentPriority + skillPriority
                    
                    -- 更新DP表
                    if not dp[step + 1][newStateId] or 
                       newTotalPriority > dp[step + 1][newStateId].totalPriority then
                        dp[step + 1][newStateId] = {
                            skillSequence = newSequence,
                            totalPriority = newTotalPriority,
                            resources = newResources
                        }
                        stateMap[newStateId] = newResources
                    end
                end
            end
        end
        
        -- 状态剪枝：如果状态太多，只保留每个step的前K个最优状态
        local MAX_STATES_PER_STEP = 1000
        if step > 0 and step < targetSkillCount - 1 then
            local states = {}
            for stateId, stateData in pairs(dp[step]) do
                table.insert(states, {
                    stateId = stateId,
                    totalPriority = stateData.totalPriority,
                    resources = stateData.resources
                })
            end
            
            if #states > MAX_STATES_PER_STEP then
                table.sort(states, function(a, b) 
                    return a.totalPriority > b.totalPriority 
                end)
                
                local newDpStep = {}
                for i = 1, math.min(MAX_STATES_PER_STEP, #states) do
                    local state = states[i]
                    newDpStep[state.stateId] = dp[step][state.stateId]
                end
                dp[step] = newDpStep
            end
        end
    end
    
    -- 步骤7: 查找最优序列
    local bestSequence = nil
    local bestResources = nil
    local bestPriority = -math.huge
    
    for stateId, stateData in pairs(dp[targetSkillCount] or {}) do
        if stateData.totalPriority > bestPriority then
            bestPriority = stateData.totalPriority
            bestSequence = stateData.skillSequence
            bestResources = {stateData.resources}
            
            -- 记录每一步的资源状态
            for step = targetSkillCount - 1, 0, -1 do
                -- 回溯找到路径
                -- 这里简化处理，实际需要完整的回溯
                table.insert(bestResources, 1, stateData.resources)
            end
        end
    end
    
    -- 步骤8: 格式化输出
    local result = {
        skillQueue = {},
        resourceAtEachSkill = {}
    }
    
    if bestSequence then
        -- 注意：由于我们只记录了最终状态，这里简化输出
        -- 实际应用中需要记录每一步的资源状态
        for i, skillCast in ipairs(bestSequence) do
            table.insert(result.skillQueue, {
                skillID = skillCast.id,
                skillName = skillCast.name,
                priority = skillCast.priority
            })
            
            -- 资源状态（这里需要根据实际回溯得到）
            table.insert(result.resourceAtEachSkill, {
                mp = 0,  -- 需要实际计算
                ling_jixin = 0,
                fire_ice = 0,
                tong_xiao = 0,
                bei_lun = 0,
                xing_ji = 0
            })
        end
    end
    
    return result
end

-- 使用示例
local currentResources = {
   mp = 10000,
    ling_jixin = 3,
    fire_ice = 3,
    tong_xiao = 1,
    bei_lun = 0,
    xing_ji = 0
}

local result = planSkillSequence(100, currentResources, 5, MhachBLMTest.SkillsTest)
print("技能队列:", table.concat(result.skillQueue, " -> "))
print("MP序列:", table.concat(result.resourceAtEachSkill, ", "))
--return MhachBLMTest



