土制黑魔ACR   `MhachBLM`：

v1.98B更新
	
	1.dot黑名单优化，现在你可以将名字或者contentid其中之一添加为dot黑名单，至少需要填写名字和contentid其中一项，其他自动补全，当血量小于等于你设定的hp百分比时就不会对黑名单的目标使用dot
	2.Hotbar自适应，就像游戏里的变换技能一样！
	3.添加风险项：瞬移以太步和魔纹步，读条时使用会在读条完时直接瞬移，瞬发时正常使用技能，风险自负，被绿玩塔塔开了别找我

v1.98A更新

	1.智能目标优化，现在会优先选择集群中血量最高的敌人
	2.添加了自动灵极魂hotbar，一键切换冰回蓝
	3.修复了开场魔泉前不打异言
	4.整合了lb为autolb的hotbar
	5.acr设置中爆发药全系可选，优先使用你选择的爆发药，没有则自动从高到低选择爆发药
	6.添加了滑板鞋和灵魂漂移选项，为互斥选项，灵魂漂移因与tensordrift存在冲突故只做测试
	7.添加了自动替换升级降级技能，比如你使用火1的hotbar会在条件允许时变成悖论(目前仅支持代码调用自动替换，手动点击hotbar不支持)
	8.修复dot黑名单问题
	9.最新全局
	10.支持qt界面按键绑定，移动到qt上查看绑定的按键
	11.部分界面透明化

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


