土制黑魔ACR   `MhachBLM`：
v1.98A更新

	1.智能目标优化，现在会优先选择集群中血量最高的敌人
	2.添加了自动灵极魂hotbar，一键切换冰回蓝
	3.修复了开场魔泉前不打异言
	4.整合了lb为autolb的hotbar
	5.acr设置中爆发药全系可选，优先使用你选择的爆发药，没有则自动从高到低选择爆发药
	6.添加了滑板鞋和灵魂漂移选项，为互斥选项，灵魂漂移因与tensordrift存在冲突故只做测试
	7.添加了自动替换升级降级技能，比如你使用火1的hotbar会在条件允许时变成悖论
	8.修复dot黑名单问题
	9.最新全局

v1.98更新

	1.优化能力技
	2.增加自动爆发药qt，支持最新版本的4种爆发药，自动从高到低使用
	3.增加短循环qt
	4.增加打完豆子qt
	5.增加爆发药qt

v1.93更新：

	1.添加了新的acr设置
	2.修复了在开场爆发把悖论打入循环导致无法打出耀星的问题
	3.修复了开场循环的黑魔纹延后

v1.9更新：

	1.优化能力技输入，和正常玩家一样创造瞬发窗口来插入能力技
	2.优化能力技队列
	3.多语言支持
	4.修复bug

v1.6更新：

	1.增加hotbar
	2.增加acr设置选项
	3.优化aoe循环
	4.全等级适配
	5.锁定面向测试版
	6.以太步hotbar为世界<mo>，无法对小队列表使用，自动吸附鼠标附近队友无须严格将鼠标对准队友

**重要：前置TensorCore，推荐开启动画锁但不强需**

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

智能目标：开启就检测敌人集群数量，群体技能释放到最优敌人以尽可能覆盖所有敌人，关闭技能就打当前目标

更多移动：在爆发期留一颗豆子

***ACR Options：***

debug：控制台打印使用的技能

动画锁：你开了动画锁就勾上

强插能力技：无论是否有瞬发窗口，直接在咏唱后的0.5s内插入能力技

魔纹步替代以太步：预留功能，没用

显示接下来的技能：字面意思，用处并不是很大

战斗外禁用热键：战斗外不使用hotbar热键


循环逻辑：标准改循环，切换冰状态优先即刻星灵打冰3，目标身上有增伤团辅，自身有团辅会打完豆子，不想打豆子就把通晓qt关掉或者开启更多移动qt
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


全局预设：
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

新建一个全局配置，然后继承anyone的配置，关闭anyone的prepull，复制我的全局预设，右键从剪切板导入
如果你使用我的起手，那么开局会使用一个三连咏唱，并开始打5+7标准起手，记得一定要关闭anyone默认的prepull


