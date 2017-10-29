-- /**
--  * @Author:	  fzw
--  * @DateTime:	2016-05-30 14:04:20
--  * @Description: 全局配置性文件
--					最大值、价格等没有配表的数据，必须统一在这里配置，
-- 					减少出错机会，方便修改数据，增强可配置性。
--  */
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
GlobalConfig = {}
local winsize = cc.Director:getInstance():getWinSize()
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
GlobalConfig.isOpenTestState = false        --是否开启测试模式(true=开启，false=关闭)

-------------------------------------------------------------------------------
GlobalConfig.fontName = "ui/fonts/DroidSansFallback.ttf"

GlobalConfig.FinalizeCD = 30 -- module释放时间

-------------------------------------------------------------------------------
GlobalConfig.moduleJumpAnimationName = "rgb-guochangyun2"  --过场切换特效
GlobalConfig.moduleJumpAnimationDelay = 580  		--过场特效到达全屏的时间：毫秒

-------------------------------------------------------------------------------
-- UITeamDetailPanel 通用布阵UI的坑位缩放参数
GlobalConfig.UITeamDetailScale = 1  --整个坑位的全部东西缩放大小
GlobalConfig.UITeamDetailSoldierScale = 0.8  --坑位的佣兵单独缩放大小
GlobalConfig.UISoldierAnchorPoint = cc.p(0.5,0.42)  --坑位的佣兵图片锚点设置
-------------------------------------------------------------------------------
-- 副本地图的宝箱和匕首特效参数（region模块）
GlobalConfig.RegionBoxPos = cc.p(60, -20)   --宝箱坐标
GlobalConfig.RegionKnifePos = cc.p(58, 70)  --匕首坐标
GlobalConfig.RegionBoxScale = 0.75			--宝箱缩放
GlobalConfig.RegionKnifeScale = 1			--匕首缩放
-------------------------------------------------------------------------------
-- UI统一布局自适应的相关参数

GlobalConfig.downHeight = 20  --距离下边界高度
GlobalConfig.topTabsHeight = 0  --listview高度修正(大于0：高度减小，小于0：高度增加)
GlobalConfig.tabsHeight = 153  --界面顶部标签高度165左右
GlobalConfig.tabsMaxHeight = 814  --标签的世界坐标高度
GlobalConfig.topHeight = 886  --距离上边界高度（界面顶部高度74左右）无标签的最高高度
-- topHeight 替换成这个BasicPanel:topAdaptivePanel()
GlobalConfig.topHeight2 = 960-50  --标题下面 顶着标题的位置
GlobalConfig.topHeight3 = 960-87  --标题下面 线条的横条
GlobalConfig.topHeight4 = 960-114  
GlobalConfig.topHeight5 = winsize.height-50  --标题下面 顶着标题的位置
GlobalConfig.topHeight6 = winsize.height-100  --模拟tabcontrol位置

GlobalConfig.tabsAdaptive = 60  --tabsPanel标签自适应的修正高度
GlobalConfig.topAdaptive = 60  --无标签panel自适应的修正高度
GlobalConfig.topAdaptive1 = 100  --无标签panel自适应的修正高度
-------------------------------------------------------------------------------
GlobalConfig.scrollViewRowSpace = 10  --scrollview行间距
GlobalConfig.scrollViewColSpace = 10  --scrollview列间距
-------------------------------------------------------------------------------
GlobalConfig.listViewRowSpace = 10  --listview行间距
-------------------------------------------------------------------------------
GlobalConfig.ResIconScale = 0.6  --资源icon缩放大小
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
GlobalConfig.playerMaxLv = 80 				--主公最高等级
GlobalConfig.commandMaxLv = 80 				--统率最高等级
GlobalConfig.boomMaxLv = 80 				--繁荣最高等级
GlobalConfig.prestigeMaxLv = 80 			--声望最高等级
GlobalConfig.skillResetPrice = 58 			--战法重置价格（元宝）
GlobalConfig.chatMinLv = 10 				--聊天和写信的最低等级限制

GlobalConfig.autoBuildPrice = 238 			--自动升级购买价格（元宝）
GlobalConfig.autoBuildTime = 4 			    --自动升级有效时长（小时）

GlobalConfig.partWarehouseMaxCount = 75+4*8	--军械最大数量=军械仓库最大值+可装备槽位最大值
GlobalConfig.pieceWarehouseMaxCount = 75	--军械仓库-碎片最大数量

GlobalConfig.dailyTaskRefreshPrice = 5 		--刷新日常任务价格（元宝）
GlobalConfig.dailyTaskResetPrice = 25		--重置日常任务次数价格（元宝）

GlobalConfig.LegionWelfareMaxLV = 30		--军团福利所最高等级
GlobalConfig.BlessEnergyMaxCount = 10		--每日可以领取好友祝福军令上限

GlobalConfig.maxRefreshPrice = 20           --民心刷新需要元宝最大值
GlobalConfig.maxCrusadeEnergy = 15          --讨伐令上限数值
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- 首冲礼包数据配置
GlobalConfig.FirstRechargeReward = {
    {typeid = 24, num = 1, power = 409, isShowNum = true},    --貂蝉
    {typeid = 3311, num = 1, power = 401, isShowNum = true},  --迁城令
    {typeid = 403, num = 18, power = 406, isShowNum = true},  --3阶弓18
    {typeid = 104, num = 28, power = 406, isShowNum = true},  --4阶刀28
}
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
GlobalConfig.worldMapScale = 0.9   		--世界地图缩放大小
GlobalConfig.worldMapBuildScale = 0.68  --世界地图玩家基地缩放大小
GlobalConfig.worldMapFontScale = 1      --世界地图标题缩放大小 


GlobalConfig.worldMapResScaleConf = {     --世界地图资源点缩放大小
	-- {01,19,0.9}
	-- 参数：01=资源点等级下限
	-- 		 19=资源点等级上限
	-- 		 0.9=缩放大小

	{01,29,0.85}, {30,60,0.95}
}


GlobalConfig.WorldResTitlePos =  cc.p(0, 55)   	--资源点标题坐标
GlobalConfig.WorldPlayerTitlePos =  cc.p(0, 70)  --玩家基地标题坐标

GlobalConfig.TileMoveX = 2  --X坐标移动距离
GlobalConfig.TileMoveY = 2  --Y坐标移动距离
GlobalConfig.TileDT = 4  --地图数据采集区域  = (TileDT * 2 +1 ) * 2

--[[
	世界地图装饰物参数（控制空地显示装饰图和透明图）
	公式： resId = math.fmod(x * 99 + y * 77, GlobalConfig.EmptyDiv) + 1
	装饰图取值：1 < resId < EmptyMod
	透明图取值：EmptyMod < resId < EmptyDiv
]]
GlobalConfig.EmptyDiv = 8  --除数：求余用 （最大值是8，因为只有8张装饰图）
GlobalConfig.EmptyMod = 3  --
-------------------------------------------------------------------------------
GlobalConfig.hitBuildColor = {178,178,178} --点击(主城/军团)建筑RGB颜色

-------------------------------------------------------------------------------
--主城未开启的功能建筑提示 (建筑类型)
GlobalConfig.mainSceneBuildLocked = {
	-- 12,  --大军基地
	--15,  --军师府
	18,
	--19,
	-- 20,-- 军工所
}

--隐藏等级的建筑类型
GlobalConfig.hideLevelList = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20} 

--隐藏建筑标题+等级（type）
GlobalConfig.hideTitle = {19}

--隐藏可建造锤子（type）
-- GlobalConfig.hideHammer = {19,21,22}


GlobalConfig.mainSceneTouchBegan = true    --显示主城建筑标题+等级
GlobalConfig.mainSceneTouchEnd = false     --隐藏主城建筑标题+等级
GlobalConfig.mainSceneInit = false         --初始化是否显示主城建筑标题+等级
GlobalConfig.mainSceneisShowLevel = true   --是否显示建筑等级

-------------------------------------------------------------------------------
GlobalConfig.mainSceneResTitlePos = cc.p(-50,0)  --主城野外建筑等级坐标偏移

-------------------------------------------------------------------------------

GlobalConfig.centerPos  = cc.p(240, 550)    --主城初始位置坐标(像素)
-- 主城场景地图和军团场景地图共用以下配置参数
GlobalConfig.fromScale  = 2.0    			--缩放起始的值
GlobalConfig.toScale  = 0.62   			    --缩放结束的值(最终显示的缩放大小)
GlobalConfig.delay  = 0.5    				--缩放动画时长(秒)


GlobalConfig.sunshineScale  = 1.5    		--主城阳光特效缩放大小
GlobalConfig.sunshineIsShow = false   	    --主城阳光特效显示开关(true=显示，false=隐藏)
GlobalConfig.isSunshineImgShow = false       --主城阳光图片显示开关(true=显示，false=隐藏)
-------------------------------------------------------------------------------
-- 光晕
GlobalConfig.sunshine2Url  = "images/common/sunshine.png"    		--主城光晕资源
GlobalConfig.sunshine2Scale0  = 1    		--主城光晕起始缩放大小
GlobalConfig.sunshine2Scale1  = 1.1  	    --主城光晕结束缩放大小
GlobalConfig.sunshine2Delay  = 25    		--主城光晕缩放时长(从sunshine2Scale0到sunshine2Scale1)
GlobalConfig.sunshine2IsShow  = true    	--主城光晕显示开关(true=显示，false=隐藏)
GlobalConfig.sunshine2MaxR  = 2    	        --主城光晕顺时针旋转最大角度(度)

GlobalConfig.sunshine2Fade0  = 200    		--主城光晕起始透明度
GlobalConfig.sunshine2Fade1  = 255  	    --主城光晕结束透明度
GlobalConfig.sunshine2Delay2  = 5    		--主城光晕渐变时长(从sunshine2Fade0到sunshine2Fade1)
GlobalConfig.sunshine2Pos = cc.p(890, 180)  --光晕坐标
GlobalConfig.ancPoint = cc.p(1, 1)    		--光晕锚点

--登陆按钮点击的间隔时间
GlobalConfig.LoginBtnTouchTime = 2

-------------------------------------------------------------------------------
-- 老鹰配置参数
GlobalConfig.birdScale  = 2.0    				--主城老鹰特效缩放大小
GlobalConfig.birdWaitDelay  = 3000   			--进入主城老鹰出现前等待时间(毫秒)
GlobalConfig.birdEffect1 = "rpg-the-eagle"   	--主城老鹰特效文件名
GlobalConfig.birdEffect2 = "rpg-the-eagles"   	--主城老鹰特效文件名 滑翔
GlobalConfig.birdAudio = "yx_bird"          	--主城老鹰音效文件名

GlobalConfig.birdMaxCount = 1					--主城老鹰最大数量(最小值1)
GlobalConfig.birdBeginRandomY = {000,480}		--主城老鹰起飞Y坐标随机范围
GlobalConfig.birdEndPosX  = {2200, 3000}    	--主城老鹰终点X坐标随机范围
GlobalConfig.birdEndPosY  = {1200, 2300}    	--主城老鹰终点Y坐标随机范围
GlobalConfig.birdBeginRandomWait = {120000,150000}	--主城老鹰起飞间隔时间随机范围(毫秒)
GlobalConfig.birdFlyDelay = {20,25}    		    --主城老鹰飞行时长随机范围(秒)
GlobalConfig.birdFlyCount1 = {1,10}    		    --主城老鹰拍翅膀循环次数随机范围
GlobalConfig.birdFlyCount2 = {40,200}    		--主城老鹰滑翔循环次数随机范围


GlobalConfig.bezierPos1  = cc.p(200, 000)   	--曲线控制点1坐标
GlobalConfig.bezierPos2  = cc.p(200, 000)   	--曲线控制点2坐标

-------------------------------------------------------------------------------
-- 资源建筑特效参数
GlobalConfig.FieldBuildEffectConf = {scale = 1.0, effectName = 'rpg-the-particle'}

GlobalConfig.fieldEffPos = cc.p(00, 20)		--整体坐标值(特效+图标)
GlobalConfig.fieldEffEndDelay = 3			--播放结束间隔时间

GlobalConfig.fieldEffRotateAncle = 6		--图标晃动角度
GlobalConfig.fieldEffRotateDelay = 0.3		--图标一次晃动时间
GlobalConfig.fieldEffDelay = 0.04*40		--图标上升时间
GlobalConfig.fieldEffSca = {0, 1.5}			--图标缩放大小（起始值，终点值）

-- (先快后慢)
GlobalConfig.fieldEffMov = {-50, 20, 50}				--图标上升距离（起始Y坐标，临界点Y坐标，终点Y坐标）
GlobalConfig.fieldEffMovDelay = {0.04*20, 0.04*20}		--图标上升时间(第一段，第二段)
GlobalConfig.fieldEffMovRate = 1						--图标上升的速率


-------------------------------------------------------------------------------
-- 建筑动画 
-- buildAction[type] ： type = 22 船
GlobalConfig.buildAction = {}
GlobalConfig.buildAction[22] = {
								movY = {-5, 00}, 	--{最低点Y坐标，最高点Y坐标}
								movT = {1.5,1.5}, 	--{下降时间，上升时间}秒
								rate = 1			--速率
							}

-------------------------------------------------------------------------------
-- 世界地图资源点特效配置
-- 示例：
-- GlobalConfig.worldMapEffects[1] = {"rpg-green", cc.p(0,0)}
-- 参数：
-- worldMapEffects[1] = 资源点type=1
-- "rpg-green" = 特效文件名
-- cc.p(0,0) = 偏移坐标

GlobalConfig.worldMapEffects = {}
GlobalConfig.worldMapEffects[1] = {effectName = "rgb-yinkuang",  pos = cc.p(0,0)}  	--资源点type=1银矿
GlobalConfig.worldMapEffects[2] = {effectName = "rgb-tiekuang",   pos = cc.p(0,0)}		--资源点type=2铁
GlobalConfig.worldMapEffects[3] = {effectName = "rgb-muchang", pos = cc.p(0,0)}		--资源点type=3木
GlobalConfig.worldMapEffects[4] = {effectName = "rgb-shikuang",  pos = cc.p(0,0)}		--资源点type=4石头
GlobalConfig.worldMapEffects[5] = {effectName = "rgb-daotian", pos = cc.p(0,0)}		--资源点type=5农田


--二级弹窗tag
GlobalConfig.uitopWin = {}
GlobalConfig.uitopWin.UIRecharge = "UIRecharge"
GlobalConfig.uitopWin.UISoldierInfo = "UISoldierInfo"
GlobalConfig.uitopWin.UICommand = "UICommand"


GlobalConfig.uipopWin = {}
GlobalConfig.uipopWin.UIMessageBox = "UIMessageBox"




-------------------------------------------------------------------------------
-- 主城巡逻兵参数
-- (GlobalConfig.moveDelay + GlobalConfig.standDelay) / 0.32 最好能整除

-- 主城巡逻兵特效配表
-- 参数：
-- pos = 'pos1'  						UI对应位置(目录：mainPanel\)
-- count = 6							巡逻兵数量
-- moveDelay = 6                  		从头走到尾的时间(暂定最大值为10秒)
-- standDelay = 0.4               		走到尾站立的时间，然后隐藏
-- standScale = 1.2						缩放大小
-- effectName = 'rpg-Running water'		特效文件名

GlobalConfig.MainSceneSoldierEff = {}
GlobalConfig.MainSceneSoldierEff[1] = {pos = 'movPos1', count = 1, moveDelay = 6.08, standDelay = 0.4, standScale = 1.2, effectName = {"rpg-the-soldiers", "rpg-the-marines"}}
GlobalConfig.MainSceneSoldierEff[2] = {pos = 'movPos2', count = 1, moveDelay = 0.32*40 -0.4, standDelay = 0.4, standScale = 1.2, effectName = {"rpg-the-soldiers", "rpg-the-marines"}}


-------------------------------------------------------------------------------
-- 主城建筑信息坐标：标题OR生产图标OR升级图标的坐标
-- （即相对于建筑图锚点的偏移坐标）

-- 示例
-- GlobalConfig.buildingInfoPos["1-1"] = {title = {-30,70}, icon = {-30,70}, iconScale = 3.0}
-- ["1-1"] = 建筑类型-建筑ID
-- title = {-30,70} : 标题坐标
-- icon = {-30,70} :  图标坐标(升级/生产共用)
-- iconScale = 3 :  图标缩放大小(升级/生产共用)

GlobalConfig.keyTitle = "title"
GlobalConfig.keyIcon = "icon"
GlobalConfig.keyIconScale = "iconScale"

GlobalConfig.defIconScale = 1.0  --图标默认缩放大小，如果有配iconScale，就用iconScale大小
GlobalConfig.defTitleScale = 1.0  --建筑标题默认缩放大小
GlobalConfig.nameShowScale = 0.7  -- 建筑缩小到这个值时名称不显示

GlobalConfig.buildingInfoPos = {} 
GlobalConfig.buildingInfoPos["1-1"] = {title = {0,200}, icon = {0,200}, iconScale = 1.2}	--官邸
GlobalConfig.buildingInfoPos["9-2"] = {title = {0,110}, icon = {0,110}, iconScale = 1.1}	--兵营1
GlobalConfig.buildingInfoPos["9-3"] = {title = {0,110}, icon = {0,110}, iconScale = 1.1}    --兵营2
GlobalConfig.buildingInfoPos["12-5"] = {title = {0,120}}	--大军基地
GlobalConfig.buildingInfoPos["19-16"] = {title = {0,120}}   --皇帝雕像
GlobalConfig.buildingInfoPos["13-6"] = {title = {0,115}, icon = {0,115}}	--将军府
GlobalConfig.buildingInfoPos["10-4"] = {title = {0,110}, icon = {0,110}, iconScale = 1.1}  --校场
GlobalConfig.buildingInfoPos["17-14"] = {title = {15,125},icon = {15,125}, iconScale = 1.4} --军团大厅
GlobalConfig.buildingInfoPos["20-17"] = {title = {0,120}} --军工所
GlobalConfig.buildingInfoPos["8-12"] = {title = {0,110}, icon = {0,110}}  --太学院
GlobalConfig.buildingInfoPos["18-15"] = {title = {0,120}}  --军制所
GlobalConfig.buildingInfoPos["16-13"] = {title = {0,120}}  --演武场
GlobalConfig.buildingInfoPos["15-8"] = {title = {0,110}, icon = {0,110}}  --军师府
GlobalConfig.buildingInfoPos["14-7"] = {title = {0,120}}  --军械坊
GlobalConfig.buildingInfoPos["7-10"] = {title = {10,120},icon = {10,120}}   --仓库
GlobalConfig.buildingInfoPos["7-9"] = {title = {10,120},icon = {10,120}}   --仓库
GlobalConfig.buildingInfoPos["11-11"] = {title = {0,120}, iconScale = 1.1}   --工匠坊
GlobalConfig.buildingInfoPos["2-1"] = {title = {0,120}}   --铸币所


-------------------------------------------------------------------------------
-- 登陆游戏预加载特效配表
-- 要在这里配一下主城的特效文件名
GlobalConfig.ScenePreEffects = {}
GlobalConfig.ScenePreEffects[1] = "rpg-levelup"
--GlobalConfig.ScenePreEffects[2] = "rpg-time"   --VipBoxPanel.lua
--GlobalConfig.ScenePreEffects[3] = "rpg-Criticalpoint"
-- GlobalConfig.ScenePreEffects[4] = "rpg-sidelight"
-- GlobalConfig.ScenePreEffects[5] = "rpg-Positivelight"  --已废弃
GlobalConfig.ScenePreEffects[6] = "rpg-Running-water"
--GlobalConfig.ScenePreEffects[7] = "rpg-horizontal"
GlobalConfig.ScenePreEffects[8] = "rpg-drainage"
GlobalConfig.ScenePreEffects[9] = "rpg-a-horizontal-plane"
--GlobalConfig.ScenePreEffects[10] = "rpg-horizontal-plane"
GlobalConfig.ScenePreEffects[11] = "rpg-the-sun"     --roleInfo模块
--GlobalConfig.ScenePreEffects[12] = "rpg-marines"
--GlobalConfig.ScenePreEffects[13] = "rpg-generals"
GlobalConfig.ScenePreEffects[13] = "rpg-general"
GlobalConfig.ScenePreEffects[14] = "rpg-gear"
GlobalConfig.ScenePreEffects[15] = "rpg-tap"
GlobalConfig.ScenePreEffects[16] = "rpg-gears"
GlobalConfig.ScenePreEffects[17] = "rpg-light"
GlobalConfig.ScenePreEffects[18] = "rpg-the-fire"
GlobalConfig.ScenePreEffects[19] = "rpg-the-ball"
GlobalConfig.ScenePreEffects[20] = "rpg-water-wheel"
GlobalConfig.ScenePreEffects[21] = "rpg-gossip"
GlobalConfig.ScenePreEffects[22] = "rpg-lava"
GlobalConfig.ScenePreEffects[23] = "rpg-the-flags"
--GlobalConfig.ScenePreEffects[24] = "rpg-flow-time"
--GlobalConfig.ScenePreEffects[25] = "rpg-flags"
GlobalConfig.ScenePreEffects[26] = "rpg-smoke"
GlobalConfig.ScenePreEffects[27] = "rpg-the-flagss"
GlobalConfig.ScenePreEffects[28] = "rpg-the-eagle"
GlobalConfig.ScenePreEffects[29] = "rpg-the-eagles"
GlobalConfig.ScenePreEffects[30] = "rpg-marinesxil"
--GlobalConfig.ScenePreEffects[31] = "rpg-blasting"  --equipUp
-- GlobalConfig.ScenePreEffects[32] = "rpg-small-fire"
GlobalConfig.ScenePreEffects[33] = "rpg-green"
GlobalConfig.ScenePreEffects[34] = "rpg-orange"
GlobalConfig.ScenePreEffects[35] = "rpg-blue"
GlobalConfig.ScenePreEffects[36] = "rpg-purple"
GlobalConfig.ScenePreEffects[37] = "rpg-Acompass"
GlobalConfig.ScenePreEffects[38] = "rpg-the-marines"
GlobalConfig.ScenePreEffects[39] = "rpg-the-soldiers"
GlobalConfig.ScenePreEffects[40] = "rpg-The-waterfall"

-------------------------------------------------------------------------------
-- 主城流水特效配表
-- 参数：
-- pos = 'pos1'  						UI对应位置(目录：mainPanel\movieChipPos_water\rpg-Running_water\)
-- scale = '2.0'  						缩放大小
-- effectName = 'rpg-Running water'		特效文件名
GlobalConfig.isTrueWaterPos = true
GlobalConfig.MainSceneEffectPos = {}
--GlobalConfig.MainSceneEffectPos[0] = {pos = 'pos0', scale = '2.0', effectName = 'rpg-Running-water'}
--GlobalConfig.MainSceneEffectPos[1] = {pos = 'pos1', scale = '2.0', effectName = 'rpg-Running-water'}
--GlobalConfig.MainSceneEffectPos[2] = {pos = 'pos2', scale = '2.0', effectName = 'rpg-Running-water'}
--GlobalConfig.MainSceneEffectPos[3] = {pos = 'pos3', scale = '2.0', effectName = 'rpg-Running-water'}
--GlobalConfig.MainSceneEffectPos[4] = {pos = 'pos4', scale = '2.0', effectName = 'rpg-Running-water'}
--GlobalConfig.MainSceneEffectPos[5] = {pos = 'pos5', scale = '2.0', effectName = 'rpg-Running-water'}
--GlobalConfig.MainSceneEffectPos[6] = {pos = 'pos6', scale = '2.0', effectName = 'rpg-Running-water'}
--GlobalConfig.MainSceneEffectPos[7] = {pos = 'pos7', scale = '2.0', effectName = 'rpg-Running-water'}
--GlobalConfig.MainSceneEffectPos[8] = {pos = 'pos8', scale = '2.0', effectName = 'rpg-Running-water'}
--GlobalConfig.MainSceneEffectPos[9] = {pos = 'pos9', scale = '2.0', effectName = 'rpg-Running-water'}
--GlobalConfig.MainSceneEffectPos[10] = {pos = 'pos10', scale = '2.0', effectName = 'rpg-horizontal'}
--GlobalConfig.MainSceneEffectPos[11] = {pos = 'pos11', scale = '2.0', effectName = 'rpg-drainage'}
--GlobalConfig.MainSceneEffectPos[12] = {pos = 'pos12', scale = '2.0', effectName = 'rpg-drainage'}
--GlobalConfig.MainSceneEffectPos[13] = {pos = 'pos13', scale = '2.0', effectName = 'rpg-drainage'}
--GlobalConfig.MainSceneEffectPos[14] = {pos = 'pos14', scale = '2.0', effectName = 'rpg-drainage'}
--GlobalConfig.MainSceneEffectPos[15] = {pos = 'pos15', scale = '2.0', effectName = 'rpg-a-horizontal-plane'}
-- GlobalConfig.MainSceneEffectPos[16] = {pos = 'pos16', scale = '2.0', effectName = 'rpg-a-horizontal-plane'} -- 水波纹
--GlobalConfig.MainSceneEffectPos[17] = {pos = 'pos17', scale = '2.0', effectName = 'rpg-a-horizontal-plane'}
--GlobalConfig.MainSceneEffectPos[18] = {pos = 'pos18', scale = '2.0', effectName = 'rpg-a-horizontal-plane'}
--GlobalConfig.MainSceneEffectPos[19] = {pos = 'pos19', scale = '2.0', effectName = 'rpg-horizontal-plane'}
--GlobalConfig.MainSceneEffectPos[20] = {pos = 'pos20', scale = '2.0', effectName = 'rpg-horizontal-planes'}
GlobalConfig.MainSceneEffectPos[21] = {pos = 'pos21', scale = '1.2', effectName = 'rpg-marinesxi'}
--GlobalConfig.MainSceneEffectPos[22] = {pos = 'pos22', scale = '1.2', effectName = 'rpg-Running-water'}
GlobalConfig.MainSceneEffectPos[23] = {pos = 'pos23', scale = '1.2', effectName = 'rpg-marinesxi'}
GlobalConfig.MainSceneEffectPos[24] = {pos = 'pos24', scale = '1.2', effectName = 'rpg-marinesxi'}
--GlobalConfig.MainSceneEffectPos[25] = {pos = 'pos25', scale = '1.2', effectName = 'rpg-marinesxi'}
GlobalConfig.MainSceneEffectPos[26] = {pos = 'pos26', scale = '1.2', effectName = 'rpg-marinesxi'}
GlobalConfig.MainSceneEffectPos[27] = {pos = 'pos27', scale = '1.2', effectName = 'rpg-marinesxi'}
GlobalConfig.MainSceneEffectPos[28] = {pos = 'pos28', scale = '1.2', effectName = 'rpg-marinesxi'}
GlobalConfig.MainSceneEffectPos[29] = {pos = 'pos29', scale = '1.2', effectName = 'rpg-marinesxi'}
--GlobalConfig.MainSceneEffectPos[30] = {pos = 'pos30', scale = '1.2', effectName = 'rpg-marinesxi'}
GlobalConfig.MainSceneEffectPos[31] = {pos = 'pos31', scale = '1.2', effectName = 'rpg-marinesxi'}
GlobalConfig.MainSceneEffectPos[32] = {pos = 'pos32', scale = '1.2', effectName = 'rpg-marinesxi'}
--GlobalConfig.MainSceneEffectPos[33] = {pos = 'pos33', scale = '1', effectName = 'rpg-Runningwaters'} --瀑布效果1
--GlobalConfig.MainSceneEffectPos[34] = {pos = 'pos34', scale = '1', effectName = 'rpg-The-waterfall'} --瀑布效果2



-------------------------------------------------------------------------------
-- 真·流水特效信息配置表
-- 参数：
-- pos = 'pos1'  						UI对应位置
-- scale = '2.0'  						缩放大小
-- effectName = 'rpg-Running water'		特效文件名
GlobalConfig.MainSceneWaterPos = {}
-- 城门的四个，位置从左到右
--GlobalConfig.MainSceneWaterPos[1] = {pos = 'pos1', scale = '1.0', effectName = 'rgb-city-flow'}
--GlobalConfig.MainSceneWaterPos[3] = {pos = 'pos3', scale = '1.0', effectName = 'rgb-city-flow'}
--GlobalConfig.MainSceneWaterPos[5] = {pos = 'pos5', scale = '1.0', effectName = 'rgb-city-flow'}
--GlobalConfig.MainSceneWaterPos[6] = {pos = 'pos6', scale = '1.0', effectName = 'rgb-city-flow'}
-- 中间的两个，位置从左到右
GlobalConfig.MainSceneWaterPos[11] = {pos = 'pos11', scale = '1.0', effectName = 'rgb-city-flow'}
GlobalConfig.MainSceneWaterPos[12] = {pos = 'pos12', scale = '1.0', effectName = 'rgb-city-tivers'}
GlobalConfig.MainSceneWaterPos[13] = {pos = 'pos13', scale = '1.0', effectName = 'rgb-city-tivers'}
GlobalConfig.MainSceneWaterPos[14] = {pos = 'pos14', scale = '1.0', effectName = 'rgb-city-tivers'}
--最大的瀑布
-- GlobalConfig.MainSceneWaterPos[34] = {pos = 'pos34', scale = '1', effectName = 'rgb-fall'} --瀑布效果2
-- GlobalConfig.MainSceneWaterPos[34] = {pos = 'pos34', scale = '1', effectName = 'rgb-zc-xiaopubu'} --瀑布效果2



GlobalConfig.MainSceneWaterPos[35] = {pos = 'pos35', scale = '1.0', effectName = 'rgb-zc-shuimiana'} -- 水波纹a
GlobalConfig.MainSceneWaterPos[36] = {pos = 'pos36', scale = '1.0', effectName = 'rgb-zc-shuimianb'} -- 水波纹b
GlobalConfig.MainSceneWaterPos[37] = {pos = 'pos37', scale = '1.0', effectName = 'rgb-zc-shuimianc'} -- 水波纹c
GlobalConfig.MainSceneWaterPos[38] = {pos = 'pos38', scale = '1.0', effectName = 'rgb-zc-shuimiand'} -- 水波纹d
-- GlobalConfig.MainSceneWaterPos[39] = {pos = 'pos39', scale = '1.0', effectName = 'rgb-zc-shuimiane'} -- 水波纹e


--主城气氛特效(比较建筑高)
GlobalConfig.MainSceneTopEffect = {}
GlobalConfig.MainSceneTopEffect[1] = {pos = 'pos1', scale = '1.0', effectName = 'rgb-zc-yun'}
GlobalConfig.MainSceneTopEffect[2] = {pos = 'pos2', scale = '1.0', effectName = 'rgb-zc-shuimiane'} -- 水波纹e


--rgb-zc-xiaopubu
GlobalConfig.MainSceneLowEffect = {}
GlobalConfig.MainSceneLowEffect[1] = {pos = 'pos1', scale = '1.0', effectName = 'rgb-fall',offset = cc.p(-1,-18)}
-- GlobalConfig.MainSceneLowEffect[1] = {pos = 'pos1', scale = '1.0', effectName = 'rgb-zc-pubu'}

--功能:创建固定在屏幕上的特效
GlobalConfig.MainSceneFixEffect = {}


--雨特效配置
GlobalConfig.MainSceneRainEffect = {
										pos = 'pos3', 
										scale = '1.0', 
										effectName = 'rgb-zc-yu', 
										effectOffset = cc.p(winsize.width/2,winsize.height/2),
										zOrder = 1000000,
										fadeInTime = 2;--渐变时间
										rainTime = 2*60;--下雨时间
										opacity = 30,--阴影透明度
										delayTime = 20*1000;--延时播放时间 == 阳光

										--下面是测试数据
										-- pos = 'pos3', 
										-- scale = '1.0', 
										-- effectName = 'rgb-zc-yu', 
										-- effectOffset = cc.p(winsize.width/2,winsize.height/2),
										-- zOrder = 1000000,
										-- fadeInTime = 2;--渐变时间
										-- fadeOutTime = 5;--渐变时间
										-- rainTime = 10;--下雨时间
										-- opacity = 150,--阴影透明度
										-- delayTime = 10;--延时播放时间 == 阳光
									} -- 雨

--阳光
GlobalConfig.MainSceneSunEffect = {
										pos = 'pos3', 
										scale = '1.0', 
										effectName = 'rgb-zc-guang', 
										effectOffset = cc.p(winsize.width/2,winsize.height/2),
										zOrder = 1000000,
										sunTime = 5*60;--非下雨时间 == 阳光


										--测试数据
										-- pos = 'pos3', 
										-- scale = '1.0', 
										-- effectName = 'rgb-zc-guang', 
										-- effectOffset = cc.p(winsize.width/2,winsize.height/2),
										-- zOrder = 1000000,
										-- sunTime = 2*60;--非下雨时间 == 阳光
									} -- 阳光


--[[
	##功能:获取地图上的季节特效配置
	##param season:季节SeasonsProxy.SeasonEnum 或者服务器发过来的
	##原因:在初始化GlobalConfig的时候,SeasonsProxy还没有初始化
]]
function GlobalConfig:getMapSeasonEffectConf(season)
	if GlobalConfig.MapSeasonEffect == nil then

		GlobalConfig.MapSeasonEffect = {}
		GlobalConfig.MapSeasonEffect[SeasonsProxy.SeasonEnum.Spring] = {
																		effectName = nil, 
																		effectBg = nil,}
		GlobalConfig.MapSeasonEffect[SeasonsProxy.SeasonEnum.Summer] = {
																		effectName = "rgb-sj-xia", 
																		effectBg = nil,}
		GlobalConfig.MapSeasonEffect[SeasonsProxy.SeasonEnum.Autumn] = {
																		effectName = "rgb-sj-qiu", 
																		effectBg = "images/newOriginal/S9Season_3.png",
																		S9Rect = cc.rect(3,0,3,222);
																		effectBgSize = winsize}
		GlobalConfig.MapSeasonEffect[SeasonsProxy.SeasonEnum.Winter] = {
																		effectName = "rgb-sj_xiaxue", 
																		effectBg = "images/newOriginal/S9Season_4.png",
																		S9Rect = cc.rect(3,0,3,222);}
	end
	return GlobalConfig.MapSeasonEffect[season]
end


-------------------------------------------------------------------------------
-- 主城建筑特效配表
-- 参数：
-- pos = 'pos1'  						UI对应位置(目录：mainPanel\buildingPanelx_x)
-- scale = '2.0'  						缩放大小
-- effectName = 'rpg-Running water'		特效文件名

GlobalConfig.MainSceneBuildEffectPos = {}
--GlobalConfig.MainSceneBuildEffectPos["13-6"] = { {pos = 'pos1', scale = 1.0, effectName = 'rpg-generals'}}
GlobalConfig.MainSceneBuildEffectPos["13-6"] = { {pos = 'pos1', scale = 1.0, effectName = 'rpg-general'}}
GlobalConfig.MainSceneBuildEffectPos["20-17"] = { {pos = 'pos1', scale = 1.0, effectName = 'rpg-gear'},
                                                {pos = 'pos2', scale = 1.0, effectName = 'rpg-tap'}}
GlobalConfig.MainSceneBuildEffectPos["11-11"] = { {pos = 'pos1', scale = 1.0, effectName = 'rpg-gears'},
                                                {pos = 'pos2', scale = 1.0, effectName = 'rpg-light'}}
GlobalConfig.MainSceneBuildEffectPos["17-14"] = { {pos = 'pos1', scale = 1.0, effectName = 'rpg-the-fire'}}
GlobalConfig.MainSceneBuildEffectPos["8-12"] = { {pos = 'pos1', scale = 1.0, effectName = 'rpg-the-ball'},
                                                {pos = 'pos2', scale = 1.0, effectName = 'rpg-water-wheel'}}
GlobalConfig.MainSceneBuildEffectPos["15-8"] = { {pos = 'pos1', scale = 1.0, effectName = 'rpg-gossip'}}
GlobalConfig.MainSceneBuildEffectPos["14-7"] = { {pos = 'pos1', scale = 1.0, effectName = 'rpg-lava'},
                                                 {pos = 'pos2', scale = 1.0, effectName = 'rpg-the-flags'}}
--GlobalConfig.MainSceneBuildEffectPos["18-15"] = { {pos = 'pos1', scale = 1.0, effectName = 'rpg-flow-time'},
                                                 --{pos = 'pos2', scale = 1.0, effectName = 'rpg-flags'}}
GlobalConfig.MainSceneBuildEffectPos["10-4"] = { {pos = 'pos1', scale = 1.0, effectName = 'rpg-smoke'}}
GlobalConfig.MainSceneBuildEffectPos["10-4"] = { {pos = 'pos1', scale = 1.0, effectName = 'rpg-the-flagss'}}


-- GlobalConfig.MainSceneBuildEffectPos["3-8"] = { {pos = 'pos1', scale = 2.0, effectName = 'rpg-the-flagss'},
-- 												{pos = 'pos2', scale = 2.0, effectName = 'rpg-the-flagss'}}


--武将品质
GlobalConfig.HeroColor 			= {}
GlobalConfig.HeroColor.Bai 		= 1
GlobalConfig.HeroColor.Lv 		= 2
GlobalConfig.HeroColor.Lan 		= 3
GlobalConfig.HeroColor.Zi 		= 4
GlobalConfig.HeroColor.Orange 	= 5
--武将品质映射特效
GlobalConfig.HeroColor2Effect = {}
GlobalConfig.HeroColor2Effect[GlobalConfig.HeroColor.Bai] 		= nil
GlobalConfig.HeroColor2Effect[GlobalConfig.HeroColor.Lv] 		= "rgb-wj-lv"
GlobalConfig.HeroColor2Effect[GlobalConfig.HeroColor.Lan] 		= "rgb-wj-lan"
GlobalConfig.HeroColor2Effect[GlobalConfig.HeroColor.Zi] 		= "rgb-wj-zi"
GlobalConfig.HeroColor2Effect[GlobalConfig.HeroColor.Orange] 	= nil



GlobalConfig.rersistResMap = {}  --持久，不释放的纹理资源
--是否为不释放的资源
function GlobalConfig:isRersistRes(key)
	return self.rersistResMap[key] ~= nil
end

GlobalConfig.firstRenderTexture = nil
GlobalConfig.secondRenderTexture = nil

--全局，预加载完毕后，才能进入场景
GlobalConfig.preLoadComplete = false
--全局预加载图片资源
function GlobalConfig:preLoadImage()
	print("... --全局预加载图片资源 ...0")
	print("... --全局预加载图片资源 ...1")
	print("... --全局预加载图片资源 ...2")
	print("... --全局预加载图片资源 ...3")
	print("... --全局预加载图片资源 ...4")

    if GameConfig.targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
    	AudioManager:clearAudioCache()  --加载的时候，做一下清除缓存
    end

    NodeUtils:preLoadShader()

    local winSize = cc.Director:getInstance():getWinSize()
	if GlobalConfig.firstRenderTexture == nil then
	    local renderTexture = cc.RenderTexture:create(winSize.width, winSize.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, gl.DEPTH24_STENCIL8_OES)
	    if renderTexture ~= nil then
	        renderTexture:retain()
            GlobalConfig.firstRenderTexture = renderTexture
	    end
    end

    if GlobalConfig.secondRenderTexture == nil then
	    local renderTexture = cc.RenderTexture:create(winSize.width, winSize.height)
	    if renderTexture ~= nil then
	        renderTexture:retain()
            GlobalConfig.secondRenderTexture = renderTexture
	    end
    end

    --异步加载，不采用加载条了，直接后台加载，加快进入游戏
    --预加载plist
    local maxPlistNum = 0
    local curPlistNum = 0
    local startPlistProgree = 60
    local function addSpriteFrames(objm, plist)
    	logger:info("~~资%s", plist)
        cc.SpriteFrameCache:getInstance():addSpriteFrames(plist)
        curPlistNum = curPlistNum + 1
        if curPlistNum >= maxPlistNum then
--            if completeCallback ~= nil then
--                -- completeCallback()
--            end
        end
    end

    local maxNum = 0
    local curNum = 0
    local startProgree = 20
    local plistList = {}
    local function imageLoaded(texture)
--        print("======preLoadImage==========", texture)
        curNum = curNum + 1
        local progree = startProgree + (curNum / maxNum) * 40
        -- self:setLoadProgress(progree)
        if curNum >= maxNum then
             GlobalConfig.preLoadComplete = true
            local index = 1
            for _, plist in pairs(plistList) do  --TODO 需要优化 场景切换时，会断掉定时器，导致后面的plish没有加载上
                local tmp = {}
                TimerManager:addOnce(10 * index, addSpriteFrames, tmp, plist ) 
                index = index + 1
            end
            maxPlistNum = #plistList
--            if completeCallback ~= nil then
--                completeCallback()
--            end
        end
    end
    
    local file_type = TextureManager.file_type
    local preLoadUrlList = {}

    -- table.insert(preLoadUrlList, "ui/gui_ui_resouce_big_0" .. file_type)
    -- table.insert(preLoadUrlList, "ui/guiNew_ui_resouce_big_0" .. file_type)
    table.insert(preLoadUrlList, "ui/common_ui_resouce_big_0" .. file_type)
    table.insert(preLoadUrlList, "ui/guiScale9_ui_resouce_big_0" .. file_type)
    
    table.insert(preLoadUrlList, "ui/newGui1_ui_resouce_big_0" .. file_type)
    table.insert(preLoadUrlList, "ui/newGui2_ui_resouce_big_0" .. file_type)
    table.insert(preLoadUrlList, "ui/newGui9Scale_ui_resouce_big_0" .. file_type)
    table.insert(preLoadUrlList, "ui/newOriginal_ui_resouce_big_0" .. file_type)
    table.insert(preLoadUrlList, "ui/roleInfo_ui_resouce_big_0" .. file_type)
    table.insert(preLoadUrlList, "ui/toolbar_ui_resouce_big_0" .. file_type)

    --TextureManager.bg_type
    for index=1, 10 do
        local url = string.format("bg/scene/1_%02d" .. ".pvr.ccz", index)
        table.insert(preLoadUrlList, url)
    end

    table.insert(preLoadUrlList, "ui/mainScene_ui_resouce_big_0" .. file_type)
    -- for k,v in pairs(GlobalConfig.ScenePreEffects) do
    --     url = "effect/frame/" .. v .. ".png"
    --     table.insert(preLoadUrlList, url)  --无脑设置，png或者pvr通杀
    --     url = "effect/frame/" .. v .. ".pvr.ccz"
    --     table.insert(preLoadUrlList, url)
    -- end



    -- table.insert(preLoadUrlList, "bg/dungeon/dungeon_bg" .. TextureManager.bg_type )
    table.insert(preLoadUrlList, "bg/dungeon/1/dungeon_bg1.jpg")
    table.insert(preLoadUrlList, "bg/dungeon/1/dungeon_bg2.jpg")

    -- table.insert(preLoadUrlList, "bg/region/bg_map.jpg")
    -- table.insert(preLoadUrlList, "bg/region/bg_map2.jpg")  --不预加载，新手不会用到
    
    -- table.insert(preLoadUrlList, "bg/battle/101/bg.pvr.ccz")  -- .. TextureManager.bg_type
    -- table.insert(preLoadUrlList, "bg/battle/102/bg" .. TextureManager.bg_type)
    -- table.insert(preLoadUrlList, "bg/battle/103/bg" .. TextureManager.bg_type)
    -- table.insert(preLoadUrlList, "bg/battle/104/bg" .. TextureManager.bg_type)

    table.insert(preLoadUrlList, "bg/map/map_bg.webp")
    table.insert(preLoadUrlList, "bg/map/map-alpha.webp")

    table.insert(preLoadUrlList, "bg/ui/Bg_teamset.pvr.ccz")
    
    
    -- for index=1, 4 do
    --     local url = string.format("bg/legion/1_%02d" .. TextureManager.bg_type, index)
    --     table.insert(preLoadUrlList, url)
    -- end
    
    
    table.insert(preLoadUrlList, "ui/component_ui_resouce_big_0" .. file_type)
    table.insert(preLoadUrlList, "ui/titleIcon_ui_resouce_big_0" .. file_type)
    table.insert(preLoadUrlList, "ui/otherIcon_ui_resouce_big_0" .. file_type)
    -- table.insert(preLoadUrlList, "ui/dungeonIcon_ui_resouce_big_0" .. file_type)
    table.insert(preLoadUrlList, "ui/region_ui_resouce_big_0" .. file_type)
--    table.insert(preLoadUrlList, "ui/activity_ui_resouce_big_0" .. file_type)
    table.insert(preLoadUrlList, "ui/itemIcon_ui_resouce_big_0" .. file_type)
    -- table.insert(preLoadUrlList, "ui/map_ui_resouce_big_0" .. file_type)      
    table.insert(preLoadUrlList, "ui/otherIcon_ui_resouce_big_0" .. file_type)
    table.insert(preLoadUrlList, "ui/skillIcon_ui_resouce_big_0" .. file_type)
    table.insert(preLoadUrlList, "ui/soldierIcon_ui_resouce_big_0" .. file_type)
--    table.insert(preLoadUrlList, "ui/counsellorIcon_ui_resouce_big_0" .. file_type)
    table.insert(preLoadUrlList, "ui/barrack2Icon_ui_resouce_big_0" .. file_type)
    table.insert(preLoadUrlList, "ui/barrackIcon_ui_resouce_big_0" .. file_type)
    --table.insert(preLoadUrlList, "ui/treasure_ui_resouce_big_0" .. file_type)
    --table.insert(preLoadUrlList, "ui/activity_ui_resouce_big_0" .. file_type)
--    table.insert(preLoadUrlList, "ui/lotteryEquip_ui_resouce_big_0" .. file_type)
    table.insert(preLoadUrlList, "ui/productIcon_ui_resouce_big_0" .. file_type)  --主城生产图标
    -- table.insert(preLoadUrlList, "ui/equip_ui_resouce_big_0" .. file_type)  --新增武将资源加载
     table.insert(preLoadUrlList, "ui/headIcon_ui_resouce_big_0" .. file_type) 

     table.insert(preLoadUrlList, "ui/building2Icon_ui_resouce_big_0" .. file_type) 
     -- table.insert(preLoadUrlList, "ui/buildingIcon_ui_resouce_big_0" .. file_type)
     table.insert(preLoadUrlList, "ui/heroIcon_ui_resouce_big_0" .. file_type)
     table.insert(preLoadUrlList, "ui/littleIcon_ui_resouce_big_0" .. file_type)
     
     --table.insert(preLoadUrlList, "ui/personInfoTalentIcon_ui_resouce_big_0" .. file_type) --国策兵法图标


     -- self.rersistResMap["ui/barrack2Icon_ui_resouce_big_0" .. file_type] = true
     -- self.rersistResMap["ui/building2Icon_ui_resouce_big_0" .. file_type] = true
     -- self.rersistResMap["ui/barrackIcon_ui_resouce_big_0" .. file_type] = true
     -- self.rersistResMap["ui/littleIcon_ui_resouce_big_0" .. file_type] = true
     self.rersistResMap["ui/itemIcon_ui_resouce_big_0" .. file_type] = true
     self.rersistResMap["ui/soldierIcon_ui_resouce_big_0" .. file_type] = true
     -- self.rersistResMap["ui/titleIcon_ui_resouce_big_0" .. file_type] = true
     -- self.rersistResMap["ui/otherIcon_ui_resouce_big_0" .. file_type] = true
     -- self.rersistResMap["ui/productIcon_ui_resouce_big_0" .. file_type] = true
     -- self.rersistResMap["ui/consigliereIcon_ui_resouce_big_0" .. file_type] = true


    -- table.insert(preLoadUrlList, "ui/hero_ui_resouce_big_0" .. file_type)
--     table.insert(preLoadUrlList, "ui/heroPortrait_ui_resouce_big_0" .. file_type)
--     table.insert(preLoadUrlList, "ui/heroPortrait_ui_resouce_big_1" .. file_type)
--     table.insert(preLoadUrlList, "ui/heroPortrait_ui_resouce_big_2" .. file_type)

    
    -- table.insert(preLoadUrlList, "effect/spine/xuli_blue/skeleton.pvr.ccz")
    
    -- table.insert(preLoadUrlList, "effect/spine/qiang01_hit/skeleton.pvr.ccz")
    
    -- table.insert(preLoadUrlList, "effect/spine/qiang01_atk/skeleton.png")
    -- table.insert(preLoadUrlList, "effect/spine/gong01_hit/skeleton.png")
    -- table.insert(preLoadUrlList, "effect/spine/gong01_atk/skeleton.png")

    -- table.insert(preLoadUrlList, "effect/spine/bu01_hit/skeleton.pvr.ccz")
    -- table.insert(preLoadUrlList, "effect/spine/bu01_hit/skeleton2.pvr.ccz")
    
    -- table.insert(preLoadUrlList, "effect/spine/qi01_atk/skeleton.pvr.ccz")
    -- table.insert(preLoadUrlList, "effect/spine/qi01_atk/skeleton2.pvr.ccz")


    -- local isfirstLogin = LocalDBManager:getValueForKey("firstLogin")
    -- if isfirstLogin == nil then
    --     table.insert(preLoadUrlList, "ui/task_ui_resouce_big_0" .. file_type)
    -- end

    -- local localVerion = cc.UserDefault:getInstance():getIntegerForKey(ModuleName.MapModule,-10000)
    -- if localVerion ~= -10000 then
    --     table.insert(preLoadUrlList, "ui/map_ui_resouce_big_0" .. file_type)
    --     table.insert(plistList, "ui/map_ui_resouce_big_0.plist")
    -- end
    
    maxNum = #preLoadUrlList
    -- maxNum = maxNum - table.size(GlobalConfig.ScenePreEffects) --这里重复一份了，要减掉，避免不加载plist
    
    -- table.insert(plistList, "ui/gui_ui_resouce_big_0.plist")
    -- table.insert(plistList, "ui/guiNew_ui_resouce_big_0.plist")
    table.insert(plistList, "ui/common_ui_resouce_big_0.plist")
    table.insert(plistList, "ui/mainScene_ui_resouce_big_0.plist")
    table.insert(plistList, "ui/roleInfo_ui_resouce_big_0.plist")
    table.insert(plistList, "ui/toolbar_ui_resouce_big_0.plist")
    table.insert(plistList, "ui/component_ui_resouce_big_0.plist")

    table.insert(plistList, "ui/newGui1_ui_resouce_big_0.plist")
    table.insert(plistList, "ui/newGui2_ui_resouce_big_0.plist")
    table.insert(plistList, "ui/newGui9Scale_ui_resouce_big_0.plist")
    table.insert(plistList, "ui/newOriginal_ui_resouce_big_0.plist")

    
    -- for k,v in pairs(GlobalConfig.ScenePreEffects) do
    --     url = "effect/frame/" .. v .. ".plist"
    --     table.insert(plistList, url)
    -- end

    table.insert(plistList, "ui/titleIcon_ui_resouce_big_0.plist")
    table.insert(plistList, "ui/otherIcon_ui_resouce_big_0.plist")
    -- table.insert(plistList, "ui/dungeonIcon_ui_resouce_big_0.plist")
    -- table.insert(plistList, "ui/region_ui_resouce_big_0.plist")
    
--    table.insert(plistList, "ui/counsellorIcon_ui_resouce_big_0.plist")
    
    table.insert(plistList, "ui/itemIcon_ui_resouce_big_0.plist")
    -- table.insert(plistList, "ui/map_ui_resouce_big_0.plist")     
    table.insert(plistList, "ui/otherIcon_ui_resouce_big_0.plist")
    table.insert(plistList, "ui/skillIcon_ui_resouce_big_0.plist")
    table.insert(plistList, "ui/soldierIcon_ui_resouce_big_0.plist")
    table.insert(plistList, "ui/barrack2Icon_ui_resouce_big_0.plist")
    table.insert(plistList, "ui/barrackIcon_ui_resouce_big_0.plist")
    table.insert(plistList, "ui/productIcon_ui_resouce_big_0.plist")--主城生产图标

    table.insert(plistList, "ui/building2Icon_ui_resouce_big_0.plist") 
     -- table.insert(plistList, "ui/buildingIcon_ui_resouce_big_0.plist")
     table.insert(plistList, "ui/heroIcon_ui_resouce_big_0.plist")
     table.insert(plistList, "ui/littleIcon_ui_resouce_big_0.plist" )

--    table.insert(plistList, "ui/heroPortrait_ui_resouce_big_0.plist" )
--     table.insert(plistList, "ui/heroPortrait_ui_resouce_big_1.plist" )
--     table.insert(plistList, "ui/heroPortrait_ui_resouce_big_2.plist" )
    -- table.insert(plistList, "ui/hero_ui_resouce_big_0.plist")

    -- if isfirstLogin == nil then
    --     table.insert(plistList, "ui/task_ui_resouce_big_0.plist")
    -- end

    for _, url in pairs(preLoadUrlList) do
        cc.Director:getInstance():getTextureCache():addImageAsync(url, imageLoaded)
    end
    
--    completeCallback()
end



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function GlobalConfig:removeAllSubcontract(preKey)
    for key,value in pairs(GlobalConfig.Subcontract) do
        local modules = value.modules
        local keyName = value.moduleName or modules[1]
        local localKey = self:getLocalKey(keyName, preKey)
        cc.UserDefault:getInstance():setIntegerForKey(localKey, -1000)
        GlobalConfig.Subcontract[key].finish = false
    end
end

function GlobalConfig:getLocalKey(moduleName, preKey)
	local mainVersion = require("version")
	local localKey = moduleName .. mainVersion

	if preKey ~= nil then
		localKey = preKey .. localKey 
	elseif GameConfig.isPre then
		 localKey = "pre" .. localKey  ----预览版Key
	end
    return localKey
end

------分包的功能-------
GlobalConfig.Subcontract = {}

--军团 10个模块
GlobalConfig.Subcontract[1] = {}
GlobalConfig.Subcontract[1].finish = false
GlobalConfig.Subcontract[1].moduleName = "LegionModule"
GlobalConfig.Subcontract[1].modules = {
	"LegionWelfareModule",
	"LegionSceneModule",
	"LegionScienceTechModule",
	"LegionApplyModule",
	"LegionModule",
	"LegionHallModule",
	"LegionShopModule",
	"LegionAdviceModule",
	"LegionHelpModule",
	"LegionCombatCenterModule",
	"DungeonXModule",
	"LegionTaskModule"
}

--军械 3个模块
GlobalConfig.Subcontract[2] = {}
GlobalConfig.Subcontract[2].finish = false
GlobalConfig.Subcontract[2].moduleName = "PartsModule"
GlobalConfig.Subcontract[2].modules = {
	"PartsModule",
	"PartsWarehouseModule",
	"PartsStrengthenModule"
}

--军师3个模块+礼贤下士
GlobalConfig.Subcontract[3] = {}
GlobalConfig.Subcontract[3].finish = false
GlobalConfig.Subcontract[3].moduleName = "ConsigliereModule"
GlobalConfig.Subcontract[3].modules = {
	"ConsigliereModule",
	"ConsigliereImgModule",
	"ConsigliereRecruitModule",
	"ConsortModule"
} 

GlobalConfig.Subcontract[11] = {}  --已有的限时活动分包
GlobalConfig.Subcontract[11].finish = false
GlobalConfig.Subcontract[11].moduleName = "ActivityCenterModule"
GlobalConfig.Subcontract[11].modules = {
	"ActivityCenterModule",
	"PullBarActivityModule",
	"GeneralAndSoldierModule",
	"ChargeShareModule",
	"RedPacketModule",
	"VipBoxModule",
	"PartsGodModule",
	"VipRebateModule",
	"DayTurntableModule",
	"EmperorAwardModule",
	"EmperorCityModule",
	"EmperorReportModule",
	"LegionRichModule",
	"LuckTurntableModule",
	"ChangeLuckModule",
	"RichPowerfulVillageModule",
	"GetLotOfMoneyModule",
	"CornucopiaModule",
}


GlobalConfig.Subcontract[15] = {} 
GlobalConfig.Subcontract[15].finish = false
GlobalConfig.Subcontract[15].moduleName = "SettingModule"
GlobalConfig.Subcontract[15].modules = {
	"SettingModule",
	"BigStationModule"
}


--英雄模块，只分包图鉴
GlobalConfig.Subcontract[16] = {} 
GlobalConfig.Subcontract[16].finish = false
GlobalConfig.Subcontract[16].moduleName = "HeroModule"
GlobalConfig.Subcontract[16].modules = {
	"HeroPokedexModule"
}

-- --世界boss讨伐物资
-- GlobalConfig.Subcontract[17] = {} 
-- GlobalConfig.Subcontract[17].finish = false
-- GlobalConfig.Subcontract[17].moduleName = "WorldBossModule"
-- GlobalConfig.Subcontract[17].modules = {
-- 	"WorldBossModule"
-- }

--群雄逐鹿
GlobalConfig.Subcontract[18] = {} 
GlobalConfig.Subcontract[18].finish = false
GlobalConfig.Subcontract[18].moduleName = "WarlordsModule"
GlobalConfig.Subcontract[18].modules = {
	"WarlordsModule", 
	"WarlordsFieldModule", 
	"WarlordsRankModule"
}

--宝具
GlobalConfig.Subcontract[19] = {} 
GlobalConfig.Subcontract[19].finish = false
GlobalConfig.Subcontract[19].moduleName = "HeroTreaModule"
GlobalConfig.Subcontract[19].modules = {
	"HeroTreaPutModule", 
	"HeroTreaTrainModule", 
	"HeroTreaWarehouseModule"
}

--城主战
GlobalConfig.Subcontract[20] = {} 
GlobalConfig.Subcontract[20].finish = false
GlobalConfig.Subcontract[20].moduleName = "LordCityModule"
GlobalConfig.Subcontract[20].modules = {
	"LordCityModule", 
	"LordCityRankModule", 
	"LordCityRecordModule",
	"WorldBossModule"
}

--科举乡试
GlobalConfig.Subcontract[21] = {} 
GlobalConfig.Subcontract[21].finish = false
GlobalConfig.Subcontract[21].moduleName = "ProvincialExamModule"
GlobalConfig.Subcontract[21].modules = {
	"ProvincialExamModule", 
	"PalaceExamModule"
}

--限时春节活动_爆竹酉礼  迎春集福  金鸡砸蛋   洛阳闹市
GlobalConfig.Subcontract[22] = {} 
GlobalConfig.Subcontract[22].finish = false
GlobalConfig.Subcontract[22].moduleName = "SpringSquibModule"
GlobalConfig.Subcontract[22].modules = {
	"SpringSquibModule", 
	"SmashEggModule", 
	"ActivityShopModule", 
	"CollectBlessModule"
}

--武学讲堂  煮酒论英雄  连续充值
GlobalConfig.Subcontract[23] = {} 
GlobalConfig.Subcontract[23].finish = false
GlobalConfig.Subcontract[23].moduleName = "CookingWineModule"
GlobalConfig.Subcontract[23].modules = {
	"CookingWineModule", 
	"DayRechargeModule", 
	"MartialTeachModule"
}

--乱军来袭
GlobalConfig.Subcontract[24] = {} 
GlobalConfig.Subcontract[24].finish = false
GlobalConfig.Subcontract[24].moduleName = "RebelsModule"
GlobalConfig.Subcontract[24].modules = {
	"RebelsModule"
}

--国之重器
GlobalConfig.Subcontract[27] = {} 
GlobalConfig.Subcontract[27].moduleName = "BroadSealModule"
GlobalConfig.Subcontract[27].finish = false
GlobalConfig.Subcontract[27].modules = {
	"BroadSealModule"
}

--精绝古城,充值返利
GlobalConfig.Subcontract[28] = {} 
GlobalConfig.Subcontract[28].finish = false
GlobalConfig.Subcontract[28].moduleName = "JingJueCityModule"
GlobalConfig.Subcontract[28].modules = {
	"JingJueCityModule"
}

--雄狮轮盘
GlobalConfig.Subcontract[29] = {} 
GlobalConfig.Subcontract[29].finish = false
GlobalConfig.Subcontract[29].moduleName = "LionTurntableModule"
GlobalConfig.Subcontract[29].modules = {
	"LionTurntableModule",
	"RechargeRebateModule"
}

--热卖礼包
GlobalConfig.Subcontract[30] = {} 
GlobalConfig.Subcontract[30].finish = false
GlobalConfig.Subcontract[30].moduleName = "GiftBagModule"
GlobalConfig.Subcontract[30].modules = {
	"GiftBagModule"
}

--军工所
GlobalConfig.Subcontract[31] = {} 
GlobalConfig.Subcontract[31].finish = false
GlobalConfig.Subcontract[31].moduleName = "MilitaryModule"
GlobalConfig.Subcontract[31].modules = {
	"MilitaryModule"
}

--世界帮助

GlobalConfig.Subcontract[32] = {}
GlobalConfig.Subcontract[32].finish = false
GlobalConfig.Subcontract[32].moduleName = "WorldHelpModule"
GlobalConfig.Subcontract[32].modules = {
    "WorldHelpModule"
}
-------------------------------------------------------------------------------
--场景切换协议
--message M30105{
GlobalConfig.Scene = {}
GlobalConfig.Scene[1] = 1  --世界boss
GlobalConfig.Scene[2] = 2  --群雄涿鹿
GlobalConfig.Scene[3] = 3  --世界地图
GlobalConfig.Scene[4] = 4  --皇城战争夺MapEmperorWarOnPanel
GlobalConfig.Scene[5] = 5  --同盟城池

-------------------------------------------------------------------------------
-- 探宝竖屏滚屏富文本动画的参数
-- 动画分成2段：第一段渐显，第二段渐隐
GlobalConfig.RichTxt_FontSize = 24			--字体大小
GlobalConfig.RichTxt_LineDelay = 3		--每行出现的间隔时间，控制行间距
GlobalConfig.RichTxt_FadeInDelay = 1		--渐渐出现的时间
GlobalConfig.RichTxt_FadeOutDelay = 1		--渐渐消失的时间
GlobalConfig.RichTxt_MoveToDelay = 6		--每一段上升的时间
GlobalConfig.RichTxt_MoveInitY = 300        --起始高度：相对屏幕中点向下的偏移值
GlobalConfig.RichTxt_MoveDstY1 = 200		--第一段上升高度
GlobalConfig.RichTxt_MoveDstY2 = 400		--第二段上升高度
GlobalConfig.RichTxt_NameColor = "#eebf00"	--玩家名字颜色
GlobalConfig.RichTxt_InfoColor = "#ffffff"  --'获得'颜色
-------------------------------------------------------------------------------
-- 探宝横屏滚屏富文本动画的参数
GlobalConfig.RichTxt_X_FontSize = 24			--字体大小
GlobalConfig.RichTxt_X_LineDelay = 3			--每行出现的间隔时间，控制行间距
GlobalConfig.RichTxt_X_MoveToDelay = 6.5		--水平移动的时间
GlobalConfig.RichTxt_X_MoveInitY = 435        	--起始高度：相对屏幕中点向下的偏移值
GlobalConfig.RichTxt_X_NameColor = "#eebf00"	--玩家名字颜色
GlobalConfig.RichTxt_X_InfoColor = "#ffffff"  	--'获得'颜色
-- GlobalConfig.RichTxt_X_FadeInDelay = 1		--渐渐出现的时间
-- GlobalConfig.RichTxt_X_FadeOutDelay = 1		--渐渐消失的时间
-- GlobalConfig.RichTxt_X_MoveDstY1 = 200		--第一段上升高度
-- GlobalConfig.RichTxt_X_MoveDstY2 = 400		--第二段上升高度
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
GlobalConfig.dungeonTargetIconScale = 1    --通用副本地图据点建筑缩放大小
-------------------------------------------------------------------------------
-- GlobalConfig.littleHelperHideLV = 19    --小助手消失时主公等级
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- 全屏警告播放次数
GlobalConfig.WarningTimes = 5

--属性小图标id对应图片路径
GlobalConfig.SmallIconRefPath = {
	[5]="IconShuXingGongJi",--攻击
	[6]="IconShuXingXueLiang",--血量
	[8]="IconShuXingMingZhong",--命中
	[9]="IconShuXingShangBi",--闪避  --拼音写错了 --
	[10]="IconShuXingBaoJi",--暴击
	[11]="IconShuXingKangBao",--抗暴
	-- "IconShuXingBuDui",--部队
	[12]="IconShuXingChuangCi",--穿刺
	[14]="IconShuXingXianShou",--先手
    [33]= "IconShuXingBaoLie",   -- 爆伤
    [34]= "IconShuXingRenXing",  -- 韧性
    [44]= "IconShuXingShangHai", -- 伤害
    [45]= "IconShuXingHuJia" ,   -- 护甲
	-- "IconShuXingDaiBing",--带兵
	-- "IconShuXingDanYiGongJi",--单一攻击
	-- "IconShuXingFanShang",--反伤
	-- "IconShuXingFuZhong",--负重
	-- "IconShuXingHengPaiGongJi",--横排攻击
	-- "IconShuXingHuiXue",--回血
	-- "IconShuXingMuBiao",--目标
	-- "IconShuXingQuanJunGongJi",--全军攻击
	-- "IconShuXingQuSan",--驱散
	-- "IconShuXingRanShao",--燃烧
	-- "IconShuXingShuPaiGongJi",--穿刺 竖排攻击
	-- "IconShuXingTime",--时间
	-- "IconShuXingXiaoHao",--消耗
	-- "IconShuXingXiXue",--吸血
	-- "IconShuXingXuanYun",--眩晕
	-- "IconShuXingzhuangTai",--状态
}

-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
------------------------------------------兵营转盘参数配置start-----------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

--模型转动的区域大小（第一个值为width，第二个值为height）
GlobalConfig.Module_Size = {760, 420}--（状态：不可修改）

--模型转动的圆心（第一个值为X，第二个值为Y）Y值控制模型士兵模型上下高度位置，X值不建议修改作用和Y值同理
GlobalConfig.Module_Center = {321, 102}--（状态：可修改）---------------------------------------------------------------------

--模型透明基值（最后面士兵模型最终透明度，范围：0 - 255，0：透明， 255：不透明）
GlobalConfig.Opacity_Basic = 192--（状态：可修改）---------------------------------------------------------------------
--模型透明因子（状态：不可修改）
GlobalConfig.Opacity_Factor = 255 - GlobalConfig.Opacity_Basic--(高级版：这个暂时不开启，与转动的时候，透明度变化率相关)

--缩放基值 + 缩放因子 = 1（理想状态两个值相加要等于1，超过会拉伸原来模型大小，反之亦然）
--模型缩放基值（最后面士兵模型最终缩放比例，范围：可放大，所以暂时不做限制）
GlobalConfig.Scale_Basic = 0.75--（状态：可修改）---------------------------------------------------------------------
--模型缩放因子
GlobalConfig.Scale_Factor = 0.25--（状态：可修改）---------------------------------------------------------------------
--模型偏移角度
GlobalConfig.Offset_Angel = 0.2--（状态：可修改）---------------------------------------------------------------------
--模型适配偏移（距离上面的距离）数值越大越往上
GlobalConfig.Offset_Aaptive = 80--（状态：可修改）---------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
------------------------------------------兵营转盘参数配置end-----------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

-- 特效名字表
GlobalConfig.ccbMapInfos = {}

-- 客户端盟战本地控制开关
GlobalConfig.isOpenTownFight = true