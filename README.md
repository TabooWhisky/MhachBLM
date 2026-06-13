土制黑魔ACR   `MhachBLM`：

v2.2更新

	1.使锁定面向的API与TensorCore的相同(TensorCore.API.TensorACR.setLockFaceHeading(angle)等),这意味着对TensorACR生效的锁面向也同样对MhachBLM生效,Anyone的轴也能直接控制MhachBLM的面向了!
	2.增加了新的API: MhachBLM.SetAoeNum(num, seconds),你可以让ACR在一定时间内认为敌人数量为你输入的值.AOE开启和智能目标关闭时生效

v1.99.9更新

	1.增加短绝望HotBar,开启后会使用醒梦星灵切换冰火,冰状态使用冰悖论,回蓝够了后切火使用绝望,以此往复，醒梦没了自动关闭HotBar,代码调用为 MhachBLM.UseHotbarSkill(-4)  MhachBLM.CancelHotbarSkill(-4)

v1.99更新

	1.Hotbar显示技能名字
	2.自动灵极魂优化,代码调用为 MhachBLM.UseHotbarSkill(-1)  MhachBLM.CancelHotbarSkill(-1)
	3.添加自动更新，更新时会卡一下，卡多久取决于你的网络环境，更不了就手动替换
	4.尝试优化数据结构

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
	10.支持qt界面按键绑定，鼠标移动到qt上查看绑定的按键
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
H4sIAAAAAAAACuVYy3IcSRX1tMcvQgsWfIDCI1stj1PkszJzAUiWbOxAwg5J89gpbr7khuqqprraoNVEEAHBChbs+AV+Bf5hdhPBik/gVpfcaqu7cQE2YwJFSBGqrMy8ee65556stRt3ehsBarhzc/NVrMaDsrh1rf3Z2YqvYlGfnI/ixaO7O5vga3xlvNa781E77cY9aN745GACG5PJIOwnGiApmYjiPBCZgSOGMkVikCbTPJjg1EYBw3iviuNYb7Ur4vSvvzp8Cf7lo4PD7eZ3b3/9B+t1NYnfeePx/vOTpc93nz9e+vxFmZ+f5WW9dPAgnp8eDIo4Xjp6CAWkslg+dXc4ygdpEKuloyfVYJRHD+Plkx9NqgIHEuTjuZE9KHzMd/P8aVk7qI5/Psjz/tbl+FGD19MyDweDcY0D45in7ck4hos9Zgn861+an2s7bUIoOKM5UBJcZggNmSRgMD9WUw4meOdCeODLIgymqb09Tc7958UXg1Hs+3J03uS3fxTbRP0LdNlYQpePr9IFeEjMBU50CE1MmSbgmSUhY8wiY4QT6ZIjv5mB8SKH81jtlUNX7uURqn8G1NsQ7gik89IZSRPRPouEKouhSqqJNuBEVIIzZxaA3Hxe7EeoX/5HSNJLJG++RvLmVSQ5Y0YErDltAyNMe0ZAuEgYUGshMOqonwtv7fra9X2nvOWJOmJNxokXEojxSBBGjWYZ+Ch46uF7TDBvcRlMEDInQQoEohZEeOSQ9kq4BL3pee/+Yr6k/9QpX/8P5X46F9mVul9QhLPjGqq6wQouX38rSV8T41ZLjI3DwdhfKECUIVHJCE2YM8ecJ4ZhtamgvcEkB5feYMaNd82MZj2TDPYCRjKjNREpBmJTEvjHBJuYzpzj0/U4B8aUJCrFSKyyjBgkMAmgTNLBoBzoj7awvk+gOot1S7r7CE709YN6+qw5/b3HRRyer8aIDs6KsopfRHgVjyZ5HPdaqHSSHEUHw4xck6DwYM5hjSfDo8Qy19LpfxeqzhB0hLQbVLNi/OlxLMJJ/FVDrCEUoX/3++DXv/ndb7/59e/vLorgApj9dqVn+xei5HdWwnvncteTGc0/G8d52RUZwvWw2Wlx70tpm8f64/dAS9sYEp81emkj4Y4ihtRkmCIH2lAKQmW9bajL4cC/qAZlNajPe6vIQ3H1EAQnStBIAmdAQImEf4JPWGSQLJuDdXtvUlUo9Ostla/i61bju6D9mnG0V8gqZo3A4CESAEpJdEFmzlrphd7C9D9LmIXQe9+oZswkRZHfPlOUSBqxinyUxBnjOJcevOa9S458dUXw3lTQK7zRkrO53tG0+d3pQn2htHi4Ljr3c2F0ilQZkqwS2MWpIU5zj7WeqPdY+1rGeaRuzzzvlY59+7VB6ADjw9mCePAfVrFuhP/Jky+ffX7a1GVZnD4q66NJUQyKs76HOp6V1fk00Y3QfeqwgVTt6IwM/Z+V7nPIsZAeHezu/eRw98eP23i6pGu2x8YxokZm0c25jwc7i+dtgvkE950FwaeeZa+cFHUof1mcDIavp39vyfQWrkARFQsEqSJJ9Ii/iU4Q4BkTituA5Yf4D0dQYQFWM3s0C/ne42bP1nYQ1SGU764MpYM0dw9Fdgjl7z9aEUoXReoeCptxdtmcFSF0Kd9l2/VRYdZrPOPs/Cs26NK5tvPSQ34Io2f7jY1fu96u8eUfdy4W+8NOB+72W6pupmqyPoTR9J/tF1UcTfJ8/WnMR7F658580YCBlRT9V0aiFZZQIwyx0XIStAzUGCGyQK+6iixEzmhSDf545aBoQsDqRJhHoy8E4IWj1WQpBY/GotZnglAdFRZQ4sRYylKWghbCNO8BqJiUQl2KFjPLfJqyG5fPmIuCUiun6yncVmkUDeCoZDxTaBYp9hMt8VrPonSoHks64H3U2xdl3dsclfP4XFvdxG6saqNJJ2usNQQPCkTgTRA7qIwkOSrxCos3GW3/p9C60tn/9ufVoCxyxyrmsFoEkSiOhLLm5h4gkZhRk1LEQJX8UNAQxnhK8XpBJfa+DLgjQPFlVK3MRpBBCOz77828ZwoVUllKOFUZScwH4iT2l0xAMCLxLISFe86HDdW3Yd4XvuhJz2ySRhIIqilKo4mRqNZoa7x3PiUJHwyskCnFVMJ+IiVuyZIkWCWaKLzlWmps4kHNwfr1p2/cwo+HaENPW3Iu/0aAtDs9LF/F5R8JJnWJ9/xm7eW3/OOXJa5/VNaw+p0OHwtmW6z6LtLxi8FFei2PVFLA5gRAXPKOOOoUCclpa5JFM6zm03vrbd29S+7fS3d/mz/vQrb/pj/vQupv0Z936W3v1p/fXhVKF7XsHoroEMpKc9xFYbqHwlvaPDn6bP3ClS7a0X8AQNt+BqQZAAA=

新建一个全局配置，然后继承anyone的配置，关闭anyone的prepull，复制我的全局预设，右键从剪切板导入
如果你使用我的起手，那么开局会使用一个三连咏唱，并开始打5+7标准起手，记得一定要关闭anyone默认的prepull


