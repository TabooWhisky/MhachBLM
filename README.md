土制黑魔ACR   `MhachBLM`：

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

**重要：前置TensorCore**
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

魔丸循环：红玩强插能力技打法

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
H4sIAAAAAAAACuVXzXIbRRAOzn/wkQdwOTaRTcbM7OzP7AGQ/0JS2NjlmISbq2emx1lY7YrVKqArB4oTxY0Db8ALUFTxCPAO3FJ5CCq0dpW1YkuJkkoqB1QlVWmmZ+brr7/unpm/cHVuyUIJVy+t4EPMysNBFy+fqz6L7VWTZzYpkzzrXVnKoIPv72X3ky7eeIhFj0ZHhufaN8BUVvNzV9+pt7u4DMOtru/0oVq5XGAPy2bh338NP+faK/VCsvrn1u4DMA82dnbXht/NrYWPFsqij9eeGd7aO5w4vr63PXF8P08Hx2leTpzcwcHRTpJhb+LsLmTg8mzy0vVON01cgsXE2cMi6aZooDd58Ua/yGjCQdrDaz1M3Vq/h3ZkutTvJ3bLcQsu8B0LPM8yPwTNFBcBQ+urMPKssjqoLWUcuJhLn6HCkDkNnMWgDQtCHStpQhWgaJm8OxiGo3WANeHTo750Nuo39rIthPLBDGG/cBL258QaGzr2UxhgsZl3dL6ZIhStlROqDoaKuZ2ndifplTQxmSnwrBPaeiyy1rE4CiMGRsTMhkLERJbU0tWWYeD5HsTEZCSJSYlkCaFkBp1SJjS+4NEkps6OTeOOj3M3f6nJhZvNKDn/cYHlUAC3bn15594Rud7Js6ONvDzoZ1mSHVeMf6BJskU9cIr1K+2WgRKP82JQJVflmg5M7DmuWaxCjxnpAyOPfCa4ikQIBqXnnqK5xBo0Y9BX262vcn0P0j6ubOysb362u/7p9vSjl+5SMCqo12lZDUJIYWIexxQEEq4DZxlgJJk03IPIBFI7aEAQUZ0uFFDmRSOn2nUKM5pyoUw6p+vM2PnL20PqR85bTj7GwAKOlAaGK6ZQSwZeKGTgxZZz8KpQbeb9rLT5t9khbT7a9L32izGt9r5O0vRlICmnKGcFC1UUMenQstg5ST/Kxk5EodbeJEh/PHnyiZTvNpAuToXUwsy+BKBQKEf0WGbCgDOfY8y0Iba0UoTEN2Air9p3bb/Abp+cvY1pF4vpKX+5oe0k5cfVf37+/EyynCO7WZQzd6aeVHgXvynHesjPMxWW/1V/Ob5bQlEOiYCyGWzMu6NoP78beUIoaakRRbEVTERGMJAamQAKGljBNTdP5XB5lc47xqosLm9n2BmMq+LC61bFcL8Zku2selaouRxWSOdqAS/tJj1T+0t1xDruC8YdnacFtVMlqLsENjKKAFrtTH0fqotV4ztPjrO8wPsID/Ggn2Jv7lWdn8mpV06dsRitbfaLgurEQk3GSTJ9fpdKzCF+N9ROBzLbWvwQzMKjH3949P1Pi9O6ceR8j3ouwUYvYjYgYFrziDnloQ9aRr6OWvURd7ZGRcW03wB/sxS8t8Hf419+e/zr71P543SutdJjgeTIrCeAQSAd/VjjSHbgYnGaP93wd+VNp9pMrJ5QcHtCnanK1WnnT1rIWQWsUfPrJGa/SPIiKQcT+kDFXCC4xyV5CcMrsENFl0FrDYsCPzDcBTIITivv3z/bL2hib43Ds+WKxHTHfUGUjfELp4r7s61geHVer0xbMojkzQU5NWuFR+8KqjOCngxUcQDpZsw5Q219ekbEvpHRqBOYwBj6zwRdrZiUdNtWnnP0LpEa6AVCl2r1HypRR6hUDgAA

如果你使用我的起手，那么开局会使用一个三连咏唱，并开始打5+7标准起手，如果你开场不想使用三连咏唱，可以将起手中的MhachBLM.prepull = true改为false

