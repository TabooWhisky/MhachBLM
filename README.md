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

更多移动：存豆子，关掉则在团辅期间打完豆子

自动爆发药：打开后如果同时打开了爆发药qt，则会自动在爆发期使用爆发药

短循环：使用核爆短循环

打完豆子：打完通晓

***ACR Options：***

debug：控制台打印使用的技能

动画锁：你开了动画锁就勾上

强插能力技：无论是否有瞬发窗口，直接在咏唱后的0.5s内插入能力技

魔纹步替代以太步：预留功能，没用

显示接下来的技能：字面意思，用处并不是很大

战斗外禁用热键：战斗外不使用hotbar热键

滑板鞋：让你的滑步速度更快，不会影响你的正常移动速度和使用瞬发技能的速度

灵魂漂移：冲突，在我找到适配办法前请不要打开

dot黑名单：以英文逗号分隔需要加入黑名单的content id

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
	MhachBLM.BLM.Auto_Potion = true,
	MhachBLM.BLM.Short_Rotation = true,
	MhachBLM.BLM.Burn_Polyglot = true,
	
 
    MhachBLM.HoldAction(id, time)  --hold技能
    MhachBLM.MoveHold(id)  --移除技能的hold
    MhachBLM.ResetHoldList()  --重置hold列表
    MhachBLM.PrintHoldList()  --打印hold列表

    MhachBLM.UseHotbarSkill(id, upgrade)  --使用hotbar技能将技能加入队列，是否升级降级替换


全局预设：
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

新建一个全局配置，然后继承anyone的配置，关闭anyone的prepull，复制我的全局预设，右键从剪切板导入
如果你使用我的起手，那么开局会使用一个三连咏唱，并开始打5+7标准起手，记得一定要关闭anyone默认的prepull


