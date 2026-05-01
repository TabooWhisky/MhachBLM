local tbl =
{
    ["QT"] =
    {
        [1] =
        {
            ["CN"] = "CD",
            ["EN"] = "CD",
            ["JP"] = "CD",
        },
        [2] =
        {
            ["CN"] = "DOT",
            ["EN"] = "DOT",
            ["JP"] = "DOT",
        },
        [3] =
        {
            ["CN"] = "AOE",
            ["EN"] = "AOE",
            ["JP"] = "AOE",
        },
        [4] =
        {
            ["CN"] = "爆发药",
            ["EN"] = "Potion",
            ["JP"] = "爆発薬",
        },
        [5] =
        {
            ["CN"] = "通晓",
            ["EN"] = "Polyglot",
            ["JP"] = "ポリグロット",
        },
        [6] =
        {
            ["CN"] = "黑魔纹",
            ["EN"] = "Ley Lines",
            ["JP"] = "黒魔紋",
        },
        [7] =
        {
            ["CN"] = "魔泉",
            ["EN"] = "Manafont",
            ["JP"] = "マナフォント",
        },
        [8] =
        {
            ["CN"] = "详述",
            ["EN"] = "Amplifier",
            ["JP"] = "アンプリファイア",
        },
        [9] =
        {
            ["CN"] = "三连咏唱",
            ["EN"] = "Triplecast",
            ["JP"] = "三連魔",
        },
        [10] =
        {
            ["CN"] = "燃尽爆发",
            ["EN"] = "Burn",
            ["JP"] = "燃え尽き爆発",
        },
        [11] =
        {
            ["CN"] = "智能目标",
            ["EN"] = "Smart Target",
            ["JP"] = "スマート目標",
        },
        [12] =
        {
            ["CN"] = "更多移动",
            ["EN"] = "More Move",
            ["JP"] = "もっと移動",
        },
        [13] =
        {
            ["CN"] = "自动爆发药",
            ["EN"] = "Auto Potion",
            ["JP"] = "自動発動薬",
        },
        [14] =
        {
            ["CN"] = "短循环",
            ["EN"] = "Short Rotation",
            ["JP"] = "短期循環",
        },
        [15] =
        {
            ["CN"] = "打完豆子",
            ["EN"] = "Burn Polyglot",
            ["JP"] = "ポリグロットを打ち終える",
        },
    },

    ["MSet"] =
    {
        [1] =
        {
            ["CN"] = "主设置",
            ["EN"] = "MainSetting",
            ["JP"] = "主設定",
        },
        [2] =
        {
            ["CN"] = "调试输出",
            ["EN"] = "Debug Output",
            ["JP"] = "デバッグ出力",
        },
        [3] =
        {
            ["CN"] = "我开启了动画锁",
            ["EN"] = "I turned on animation lock",
            ["JP"] = "私はアニメーションロックをオンにしました",
        },
        [4] =
        {
            ["CN"] = "强插能力技",
            ["EN"] = "Force OGCD",
            ["JP"] = "強制挿入能力技",
        },
        [5] =
        {
            ["CN"] = "魔纹步替补以太步",
            ["EN"] = "Between the Lines Switch to Aetherial Manipulation",
            ["JP"] = "ラインズステップ to エーテリアルステップ",
        },
        [6] =
        {
            ["CN"] = "显示接下来的技能",
            ["EN"] = "Ley Show the next skill",
            ["JP"] = "次のスキルを表示する",
        },
        [7] =
        {
            ["CN"] = "不知道干啥的就别点",
            ["EN"] = "If you don't know what it does, don't click it.",
            ["JP"] = "何をするか分からないなら、クリックしないで",
        },
        [8] =
        {
            ["CN"] = "战斗外禁用热键",
            ["EN"] = "Disable hotkeys outside of combat",
            ["JP"] = "戦闘外でホットキーを無効化",
        },
        [9] =
        {
            ["CN"] = "Dot目标黑名单",
            ["EN"] = "Dot Target Blacklist",
            ["JP"] = "Dotターゲットブラックリスト",
        },
        [10] =
        {
            ["CN"] = "输入需要加入黑名单的content id,以逗号分隔",
            ["EN"] = "Enter the content IDs to be added to the blacklist, separated by commas",
            ["JP"] = "ブラックリストに追加するコンテンツIDを入力してください。コンマで区切ってください。",
        },
        [11] =
        {
            ["CN"] = "/ac输入能力技(确保能力技输入)",
            ["EN"] = "/ac input ability skill(ensure ability skill input)",
            ["JP"] = "/ac能力技を入力(能力技の入力を確実にする)",
        },
        [12] =
        {
            ["CN"] = "滑板鞋(滑步速度变快)",
            ["EN"] = "Skate shoes (faster sliding speed)",
            ["JP"] = "スケートシューズ（滑る速度が速くなる）",
        },
        [13] =
        {
            ["CN"] = "灵魂漂移",
            ["EN"] = "Soul Drift",
            ["JP"] = "魂の漂流",
        },
    },

    ["HSet"] =
    {
        [1] =
        {
            ["CN"] = "HotBar设置",
            ["EN"] = "HotBarSetting",
            ["JP"] = "ホットバー設定",
        },
        [2] =
        {
            ["CN"] = "显示热键栏",
            ["EN"] = "Show hotbar Output",
            ["JP"] = "ホットキー バーを表示",
        },
        [3] =
        {
            ["CN"] = "按下按键以绑定",
            ["EN"] = "Press the button to bind",
            ["JP"] = "キーを押してバインドする",
        },
        [4] =
        {
            ["CN"] = "左键点击绑定/取消绑定.\n".."右键点击重置.",
            ["EN"] = "Left Click to bind/unbind.\n".."Right Click to reset.",
            ["JP"] = "左クリックでバインド/解除.\n".."右クリックでリセット.",
        },
        [5] =
        {
            ["CN"] = "左键点击以启用/禁用.",
            ["EN"] = "Left Click to Enable/Disable.",
            ["JP"] = "左クリックで有効化/無効化.",
        },
    },

    ["QSet"] =
    {
        [0] =
        {
            ["CN"] = {"CD        ","DOT       ","AOE       ","爆发药    ","通晓      ","黑魔纹    ","魔泉      ","详述      ","三连咏唱  ","燃尽爆发  ","智能目标  ","更多移动  ","自动爆发药","短循环    ","打完豆子  "},
            ["EN"] = {"CD            ","DOT           ","AOE           ","Potion        ","Polyglot      ","Ley Lines     ","Manafont      ","Amplifier     ","Triplecast    ","Burn          ","Smart Target  ","More Move     ","Auto Potion   ","Short Rotation","Burn Polyglot "},
            ["JP"] = {"CD                      ","DOT                     ","AOE                     ","爆発薬                  ","ポリグロット            ","黒魔紋                  ","マナフォント            ","アンプリファイア        ","三連魔                  ","燃え尽き爆発            ","スマート目標            ","もっと移動              ","自動発動薬              ","短期循環                ","ポリグロットを打ち終える"},
        },

        [1] =
        {
            ["CN"] = "Qt设置",
            ["EN"] = "QtSetting",
            ["JP"] = "Qt設定",
        },
        [2] =
        {
            ["CN"] = "每行数量",
            ["EN"] = "QT per line",
            ["JP"] = "各行の数量",
        },
        [3] =
        {
            ["CN"] = "显示",
            ["EN"] = "Display",
            ["JP"] = "表示する",
        },
    },
}

return tbl
