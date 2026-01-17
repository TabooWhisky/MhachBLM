土制黑魔ACR   `MhachBLM`：

**重要：请启用动画锁，本acr所有循环基于开了动画锁硬插能力技**
***QT***：
CD：控制黑魔纹，详述，魔泉
DOT：dot开关
AOE：aoe开关
爆发药：为轴使用，开关均不会使用爆发药
通晓：异言、秽浊开关
黑魔纹：黑魔纹开关
魔泉：魔泉开关
详述：详述开关
三连咏唱：三连咏唱开关，在循环中不会主动开启三连，因为新版黑魔三连没有威力上的收益
Burn：燃尽爆发
智能目标：开启就检测敌人集群数量，群体技能释放到最优敌人以尽可能覆盖所有敌人，关闭技能就打当前目标，**目前智能目标会出现不打aoe的情况等我修**
更多移动：在爆发期留一颗豆子

***ACR Options：***
debug：控制台打印使用的技能
new combo：使用新模型循环，不要启用，我还未完成

循环逻辑：标准改循环，切换冰状态优先即刻星灵打冰3，目标身上有增伤团辅，自身有团辅会打完豆子，不想打豆子就把通晓qt关掉
        主要为高难优化，打了aoe或者进行了某些抽象操作可能会打出抽象的循环以调整到正常循环

主要API：

    MhachBLM.BLM.CD = true
	MhachBLM.BLM.DOT = true
	MhachBLM.BLM.AOE = true
	MhachBLM.BLM.Potion = true
	MhachBLM.BLM.Polyglot = true
	MhachBLM.BLM.Ley_Lines = true
	MhachBLM.BLM.Manafont = true
	MhachBLM.BLM.Amplifier = true
	MhachBLM.BLM.Triplecast = true
	MhachBLM.BLM.Burn = true
	MhachBLM.BLM.Smart_Target = true
	MhachBLM.BLM.More_Move = true
	MhachBLM.Settings.Debug = true
	MhachBLM.Settings.NewCombo = true
 
    MhachBLM.HoldAction(id, time)  --hold技能
    MhachBLM.MoveHold(id)  --移除技能的hold
    MhachBLM.ResetHoldList()  --重置hold列表
    MhachBLM.PrintHoldList()  --打印hold列表

    MhachBLM.PlayerCombo(list)  --用户自定义循环，输入{152, 154}这种
    MhachBLM.PlayerComboClear()  --清空用户自定义循环

