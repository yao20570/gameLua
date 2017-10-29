
--游戏对应power值
GamePowerConfig = {}

GamePowerConfig.Item = 401                  --道具
GamePowerConfig.General = 402               --武将
GamePowerConfig.Resource = 407              --资源
GamePowerConfig.Soldier = 406               --佣兵
GamePowerConfig.Ordnance = 403              --军械
GamePowerConfig.OrdnanceFragment = 404      --军械碎片
GamePowerConfig.Counsellor = 405            --谋士 ？？
GamePowerConfig.Hero = 409                  --武将
GamePowerConfig.HeroTreasure = 410          --宝具
GamePowerConfig.HeroTreasureFragment = 411  --宝具碎片
GamePowerConfig.HeroFragment = 412          --武将碎片
GamePowerConfig.LimitActivityItem = 413     --限时活动特殊物品

GamePowerConfig.Command = 4060              --司令部 -特殊icon
GamePowerConfig.Skill = 4061                --技能 -
GamePowerConfig.SoldierBarrack = 4062       --佣兵图片
GamePowerConfig.Building = 4063             --普通建筑图片\building2Icon
GamePowerConfig.Collection = 4064           --收藏资源图片\collection
GamePowerConfig.Other = 666                 --其他icon图片（任务、主公等）
GamePowerConfig.Product = 6666              --主城生产图标
GamePowerConfig.Reward = 6667               --奖励图标
GamePowerConfig.CitySkill = 6668            --城主战技能图标

SoldierDefine = {}
--//战斗属性
---------血量上限*/
SoldierDefine.POWER_hpMax = 1
---------血量*/
SoldierDefine.POWER_hp = 2
---------攻击*/
SoldierDefine.POWER_atk = 3
---------命中率*/
SoldierDefine.POWER_hitRate = 4
---------闪避率*/
SoldierDefine.POWER_dodgeRate = 5
---------暴击率*/
SoldierDefine.POWER_critRate = 6
---------抗暴率*/
SoldierDefine.POWER_defRate = 7
---------穿刺*/
SoldierDefine.POWER_wreck = 8
---------防护*/
SoldierDefine.POWER_defend = 9
---------先手值*/
SoldierDefine.POWER_initiative = 10
---------血量百分比*/
SoldierDefine.POWER_hpMaxRate = 11
---------攻击百分比*/
SoldierDefine.POWER_atkRate = 12
---------步兵血量百分比*/
SoldierDefine.POWER_infantryHpMax = 13
---------步兵攻击百分比*/
SoldierDefine.POWER_infantryAtk = 14
---------骑兵血量百分比*/
SoldierDefine.POWER_cavalryHpMax = 15
---------骑兵攻击百分比*/
SoldierDefine.POWER_cavalryAtk = 16
---------枪兵血量百分比*/
SoldierDefine.POWER_pikemanHpMax = 17
---------枪兵攻击百分比*/
SoldierDefine.POWER_pikemanAtk = 18
---------弓兵血量百分比*/
SoldierDefine.POWER_archerHpMax = 19
---------弓兵攻击百分比*/
SoldierDefine.POWER_archerHpatk = 20
---------载重*/
SoldierDefine.POWER_load = 21
---------载重百分比*/
SoldierDefine.POWER_loadRate = 22
---------行军速度加成比*/
SoldierDefine.POWER_speedRate = 23
---------PVE伤害加成*/
SoldierDefine.POWER_pveDamAdd = 24
---------PVE伤害减免*/
SoldierDefine.POWER_pveDamDer = 25
---------PVP伤害加成*/
SoldierDefine.POWER_pvpDamAdd = 26
---------PVP伤害减免*/
SoldierDefine.POWER_pvpDamDer = 27
---------伤害加成*/
SoldierDefine.POWER_damadd = 28
---------伤害减免*/
SoldierDefine.POWER_damder = 29
---------总战斗属性数量*/
SoldierDefine.TOTAL_FIGHT_POWER = 29
---------玩家战力
SoldierDefine.POWER_capacity = 30
---------世界战斗伤害加成*/
SoldierDefine.POWER_worlddamadd = 31
---------世界战斗伤害减免*/
SoldierDefine.POWER_worlddamder = 32
---------爆伤*/
SoldierDefine.POWER_critdam = 33
---------韧性*/
SoldierDefine.POWER_tenacity = 34
---------先手百分比*/
SoldierDefine.POWER_initiativeRate = 35
---------额外血量*/
SoldierDefine.POWER_extraHp = 36
---------额外攻击*/
SoldierDefine.POWER_extraAtk = 37
---------吸血触发概率*/
SoldierDefine.POWER_hpbackRate = 38
---------眩晕触发概率*/
SoldierDefine.POWER_vertRate = 39
---------反弹触发概率*/
SoldierDefine.POWER_resilRate = 40
---------驱散触发概率*/
SoldierDefine.POWER_dispelRate = 41
---------燃烧触发概率*/
SoldierDefine.POWER_burnRate = 42
---------伤害减免触发概率*/
SoldierDefine.POWER_damDerRate = 43
---------伤害*/
SoldierDefine.POWER_damHurt = 44
---------护甲*/
SoldierDefine.POWER_damArmor  = 45

SoldierDefine.SOLDIER_TYPE_CAVALRY = 1 --;//骑兵
SoldierDefine.SOLDIER_TYPE_INFANTRY = 2 --;//步兵
SoldierDefine.SOLDIER_TYPE_PIKEMAN = 3  --;//枪兵
SoldierDefine.SOLDIER_TYPE_ARCHER = 4  --;//弓兵


BuildingTypeConfig = {}
BuildingTypeConfig.COMMAND = 1 			--官邸
BuildingTypeConfig.WAREHOUSE  = 7 		--仓库
BuildingTypeConfig.SCIENCE = 8 			--太学院（科技）
BuildingTypeConfig.BARRACK = 9 			--兵营（战车工厂）
BuildingTypeConfig.REFORM = 10 			--改造车间（校场）
BuildingTypeConfig.MAKE = 11  			--制作车间(工匠坊)
BuildingTypeConfig.LEGIONHALL = 17 		--军团大厅
BuildingTypeConfig.MILITARYROOM  = 15 	--军师府（暂未开启）
BuildingTypeConfig.ARMYBASE = 12 		--大军基地（暂未开启）
BuildingTypeConfig.ARMYRULEROOM = 18	--军制所（暂未开启）
BuildingTypeConfig.ARMYTYPEROOM = 20	--军工所
BuildingTypeConfig.EMPERORSTATUE = 19	--皇帝雕像（暂未开启）


BuildingDefine = {} --建筑相关的定义
BuildingDefine.MIN_BUILD_SIZE = 2 --; //初始建筑位2
BuildingDefine.MIN_BUY_BUILD_GOlD = 30 --; //初始建筑位2时，购买第三个建筑位需30金币,之后递增30，
BuildingDefine.BUY_BUILD_SIZE_GOLD = 120  --; //购买建筑位花费金币120
BuildingDefine.ACCELERATE_FREE_TIME = 300 --免费加速时间
--需要成长的建筑类型，只有这些建筑类型才会依赖服务端，其他客户端初始化的时候自己构建
BuildingDefine.BUILD_GROWTH_LIST = {11,10,9,8,7,6,5,4,3,2,1} 

--*******等*待*队*列*初始值****
BuildingDefine.MIN_WAITQUEUE = 1

VipDefine = {} --Vip相关定义
VipDefine.VIP_ISONHOOK = "isonhook"  ----vip挂机特权
VipDefine.VIP_WAITQUEUE = "waitqueue"  ----vip等待队列数
VipDefine.VIP_BOOMLOSS = "boomloss"  ----vip繁荣度扣除比例
VipDefine.VIP_ENERGYBUY= "energybuy"  ----vip购买体力次数
VipDefine.VIP_ARENABUY= "arenabuy"  ----vip购买竞技场次数
VipDefine.VIP_MILITARYRESET= "militaryreset"  ----vip军工关卡重置次数
VipDefine.VIP_FITRESET= "fitreset"  ----vip装备，配件关卡重置次数
VipDefine.VIP_BULIDQUEUE= "bulidqueue"  ----vip建筑队列
VipDefine.VIP_DAYQUESTRESET= "dayquestreset"  ----vip日常任务
VipDefine.VIP_TROOPCOUNT= "troopCount"  ----vip出战队伍数
VipDefine.VIP_REDBUILDTIME= "redBuildtime"  ----vip建筑加速
VipDefine.VIP_REDSCIENCETIME= "redSciencetime"  ----vip科技加速
VipDefine.VIP_SPEEDUPCOLLECTRES= "speedUpCollectRes"  ----vip世界资源点采集加速
VipDefine.VIP_REDTANKPRO= "redTankpro"  ----vip坦克生成加速
VipDefine.VIP_REDTANKREM= "redTankrem"  ----vip坦克改造加速
VipDefine.VIP_SPEEDUPMARCH= "speedupMarch"  ----vip野外行军速度加速
VipDefine.VIP_STRENGBASERATE= "StrengBaseRate" 


SystemTimerConfig = {}  --系统时间配置
SystemTimerConfig.BUILDING_CREATE = 10 --建筑生产类型10
SystemTimerConfig.BUILDING_LEVEL_UP = 3 --建筑本身升级类型3
SystemTimerConfig.DEFAULT_ENERGY_RECOVER = 1 --恢复体力
SystemTimerConfig.DEFAULT_BOOM_RECOVER = 4 --恢复繁荣值
SystemTimerConfig.ITEM_BUFF = 13 --道具buff
SystemTimerConfig.LIMITEXP_CITY = 37 --扫荡
SystemTimerConfig.BUILDING_AUTO_UPGRATE = 39 --自动升级建筑


ClientCacheType = {}  --客户端缓存到服务端的类型
ClientCacheType.WORLD_COLLECTION = 1  --世界收藏缓存信息
ClientCacheType.WORLD_ENTER = 2  --是否进入过世界

ChatShareType = {}
ChatShareType.SOLDIRE_TYPE = 1 --佣兵分享
ChatShareType.ARENA_TYPE = 2 --竞技场分享
ChatShareType.REPORT_TYPE = 3 --野外战报分享
ChatShareType.GMNOTIFIER_TYPE = 4 --系统公告
ChatShareType.RECRUIT_TYPE = 5 --军团招募
ChatShareType.ADVISER_TYPE = 6 --军师分享
ChatShareType.RESOURCE_TYPE = 7 --矿点邀请
ChatShareType.HERO_TYPE = 11 --英雄分享
ChatShareType.PROP_TYPE = 8 --道具分享
ChatShareType.ORDNANCE_TYPE = 10 --军械分享


WorldTileType = {} --世界格子类型
WorldTileType.Building = 1  --有人的建筑
WorldTileType.Resource = 2  --资源点
WorldTileType.Empty = 3  --空地
WorldTileType.Rebels = 4  --叛军
WorldTileType.BanditDungeon = 5  --黄巾贼
WorldTileType.CityWar = 6 -- 盟战州城
WorldTileType.City = 7  --主城
WorldTileType.EmperorCity = 8  -- 皇城

OrdnancePieceType = {}
OrdnancePieceType.Universal = 301 --万能碎片

LegionJobConfig = {} --军团职业配置
LegionJobConfig.CUSTOM_JOB_1 = 1
LegionJobConfig.CUSTOM_JOB_2 = 2
LegionJobConfig.CUSTOM_JOB_3 = 3
LegionJobConfig.CUSTOM_JOB_4 = 4
LegionJobConfig.NORMAL_JOB = 5  --普通成员
LegionJobConfig.VICE_LEADER_JOB = 6 --副团长
LegionJobConfig.LEADER_JOB = 7 --团长

RewardActionConfig = {}  			--物品飘窗配置
RewardActionConfig.ICON_SCALE 		= 0.8   		 --物品缩放比例
RewardActionConfig.FONT_SIZE 		= 26			 --物品数量字体大小	
RewardActionConfig.INTERVAL_TIME 	= 0.3	 		 --每个出现物品间隔时间	
RewardActionConfig.FLY_TIME 		= 1.5	 		 	 --物品飞行时间	
RewardActionConfig.FLY_HIGHT 		= 150	 		 --物品飞行高度

RewardActionConfig.FLY_POS_X_LIST   = {200, 300, 400}
RewardActionConfig.FLY_POS_Y_LIST   = {400, 400, 400}
RewardActionConfig.DISTANCE 		= 30	 		 --物品与数字之间间隔

RewardActionConfig.EXP_X            = 43             --经验飘NUMX位置
RewardActionConfig.TL_X				= 43             --体力NUMX坐标

FightingActionCapConfig = {}		--战力飘字配置
FightingActionCapConfig.FONT_SIZE   	= 28			 --战力增减数字大小	
FightingActionCapConfig.POSITION_X   	= -70			 --战力显示X坐标调节
FightingActionCapConfig.POSITION_Y   	= 115 + 150		 --战力显示Y坐标调节	
FightingActionCapConfig.POSITION_NUM_X   	= 0		         --数字X坐标调节	
FightingActionCapConfig.POSITION_NUM_Y   	= 10		         --数字Y坐标调节	
-----------------------0为特效出来的时间轴-----------------
FightingActionCapConfig.TIME_ONE        = 0.2            --数字出来的时间轴
FightingActionCapConfig.TIME_TOW        = 0.04            --数字停留的时间轴
FightingActionCapConfig.TIME_THREE      = 1.9            --开始飘字变化值的时间轴
------------------------开始战力增减数字飞行------下面开始没用时间轴了---------
FightingActionCapConfig.FLY_TIME 		= 0.3	 		 --战力增减数字飞行时间	
FightingActionCapConfig.FLY_HIGHT 		= 35	 		 --战力增减数字飞行高度
FightingActionCapConfig.END_TIME 		= 0.2	 		 --飞行数字结束停留时间
-----新参数
FightingActionCapConfig.NUM_ROLL_TIME   = 0.08            --出现战力数字出现的时间
FightingActionCapConfig.NUM_ROLL_SPEED  = 1.1              --数字滚动速度
FightingActionCapConfig.NUM_FLY_TIME    = 0.2            --出现战力数字飘的时间
FightingActionCapConfig.NUM_SPACING     = 24             --战力数字间距


FightingActionCapConfig.energy_X        = 0              --体力显示X坐标
FightingActionCapConfig.energy_Y        = 0              --体力显示Y坐标

ItemBagTypeConfig = {} --道具背包类型
ItemBagTypeConfig.COMMON_BAG = 1
ItemBagTypeConfig.TREA_MASTRIAL_BAG = 2 --宝具材料
ItemBagTypeConfig.PARTS_MASTERIAL_BAG = 3 --军械材料


--锤子动作参数
HammerActionConfig = {}
HammerActionConfig.ACTION_TIME			= 0.4			 --时间
HammerActionConfig.ACTION_ANGLE			= 15			 --角度	

--战斗类型
GameConfig.battleType = {}
GameConfig.battleType.level = 1 --战役
GameConfig.battleType.explore = 2 --探险
GameConfig.battleType.arena = 3 --演武场
GameConfig.battleType.world = 4 --世界战斗
GameConfig.battleType.world_def = 5 --世界战斗防守
GameConfig.battleType.legion = 6 --军团试炼场
GameConfig.battleType.world_boss = 7 --世界Boss
GameConfig.battleType.qunxiong = 8 --群雄逐鹿
GameConfig.battleType.kill = 9 --剿匪
GameConfig.battleType.west = 10 --西域远征
GameConfig.battleType.lordCity_boss = 11 -- 城主BOSS战
GameConfig.battleType.lordCity_pvp = 12 -- 城主玩家攻防（PVP）
GameConfig.battleType.lordCity_city = 13 -- 城主城墙战
GameConfig.battleType.rebles = 14 -- 乱军来袭
GameConfig.battleType.palyerRes = 15 -- 世界战斗有人矿点
GameConfig.battleType.city_pvp = 16 -- 郡城盟战pvp
GameConfig.battleType.city_pve = 17 -- 郡城盟战pve
GameConfig.battleType.emperor_city = 18 -- 郡城盟战pve




GameConfig.isAutoBattle = "isAutoBattle"
GameConfig.isAutoExperience = "isAutoExperience"

--新手引导 参数设置
GameConfig.guideParams = {}
GameConfig.guideParams.TIME_EFFECT_STOP = 300  --小乔出来停留时间
GameConfig.guideParams.TIME_ACTION_STOP = 200  --文字箭头停留时间
GameConfig.guideParams.SPEED1 = 1080*1    --距离300像素以下速度
GameConfig.guideParams.SPEED2 = 1080*3  --距离600像素以下速度
GameConfig.guideParams.SPEED3 = 1080*3  --距离600像素以上速度
GameConfig.guideParams.TIME_QUAN_MARK = 0.6  --箭头变化速度
GameConfig.guideParams.QUAN_SCALE_MAX = 0.95 --箭头缩放最大倍数
GameConfig.guideParams.QUAN_SCALE_MIN = 0.8  --箭头缩放最小倍数
GameConfig.guideParams.MAP_MOVE_TIME = 2.5   --场景移动时间
GameConfig.guideParams.DELAY_TIME = 2000 --毫秒

--二级弹框设置
GameConfig.TwoLevelShells = {}
GameConfig.TwoLevelShells.TIME = 0.05 		 --二级弹框动作执行时间
GameConfig.TwoLevelShells.OPACITY_MAX = 255  --二级弹框动作最大透明度
GameConfig.TwoLevelShells.OPACITY_MIN = 128	 --二级弹框动作最小透明度
GameConfig.TwoLevelShells.SCALE_MAX = 1      --二级弹框动作放大倍数
GameConfig.TwoLevelShells.SCALE_MIN = 0.7    --二级弹框动作缩小倍数

GameConfig.TwoLevelShells.SHOW_TIME_01 = 0.15 -- 放大时间1
GameConfig.TwoLevelShells.SCALE_01 = 1.05 -- 放大参数1
GameConfig.TwoLevelShells.SHOW_TIME_02 = 0.05 -- 放大时间2(缩回1倍所需时间)

GameConfig.TwoLevelShells.CLOSE_TIME = 0.1 -- 关闭时间
GameConfig.TwoLevelShells.CLOSE_SCALE = 0.2 -- 关闭缩小倍数
GameConfig.TwoLevelShells.CLOSE_OPACITY = 0 -- 缩小到关闭的透明度

GameConfig.TwoLevelShells.BLUR_START_OPACITY = 100 -- 模糊起始透明度
GameConfig.TwoLevelShells.BLUR_END_OPACITY = 255 -- 模糊结束透明度
GameConfig.TwoLevelShells.BLUR_FADE_TIME = 0.2 -- 模糊渐变时间


--升级动画设置
GameConfig.LvUp = {}
GameConfig.LvUp.X = 0.5  		 --目标X坐标/屏幕宽度
GameConfig.LvUp.Y = 0.6  	 	 --目标Y坐标/屏幕高度
GameConfig.LvUp.TIME = 0.17      --每一帧时间

GameConfig.denglong = {}
GameConfig.denglong.darlyEffectX = 60 --灯笼特效坐标
GameConfig.denglong.darlyEffectY = 50 
GameConfig.denglong.ROTATE = 2 --灯笼晃动角度
GameConfig.denglong.TIME = 0.6 --灯笼晃动速度

--装备动作
GameConfig.Equip = {}
GameConfig.Equip.EquipFadeTime1 = 0.3   --装备消失缩小时间
GameConfig.Equip.EquipFadeTime2 = 0.3   --装备显示放大时间
GameConfig.Equip.EquipScale = 0.5     --装备缩放大小比例

GameConfig.Equip.RoleFadeTime1 = 0.3    --人物消失缩小时间
GameConfig.Equip.RoleFadeTime2 = 0.3    --人物显示放大时间
GameConfig.Equip.RoleScale = 0.8 	   --人物缩放大小比例


--武将交换
GameConfig.Hero = {}
GameConfig.Hero.MaxScale = 1.05
GameConfig.Hero.MinScale = 0.95
GameConfig.Hero.MaxNum = 200


--装备更换
GameConfig.EquipWear = {} 
GameConfig.EquipWear.TIME = 0.4 --动作时间
GameConfig.EquipWear.X = 50    --X逐渐消失距离
GameConfig.EquipWear.Y = 50     --Y逐渐显示距离

--天降奇兵特效配置
GameConfig.TJQB = {}
GameConfig.TJQB =      --配置特效光点10个坐标位置
	{
	cc.p(55,70),
	cc.p(30,-70),   
	cc.p(-90,-20),   
	cc.p(-75,40),   
	cc.p(60,-55),   
	cc.p(100,-15),   
	cc.p(95,40),   
	cc.p(-35,-65),   
	cc.p(-55,-50),   
	cc.p(-85,15),   
	}
    
GameConfig.TJQB_2 = {}
GameConfig.TJQB_2 =      --配置特效光点10个坐标位置
	{
	cc.p(-48,90),
	cc.p(54,128),      
	cc.p(-20,90),    
	cc.p(15,154),   
	cc.p(-18,122),   
	cc.p(36,111),    
	cc.p(-22,122),   
	cc.p(50,122),   
	cc.p(-55,121), 
	cc.p(22,131),    
	}
    
GameConfig.TJQB_1 = {}
GameConfig.TJQB_1 =      --配置特效光点10个坐标位置
	{
	cc.p(-50,90),
	cc.p(52,26),   
	cc.p(-10,90),  
	cc.p(24,154), 
	cc.p(-16,122), 
	cc.p(16,58), 
	cc.p(-32,122), 
	cc.p(34,122), 
	cc.p(-54,90), 
	cc.p(42,90),   
	}

GameConfig.TJQB.TIME1 = 0.2 --随机点移动到指定点时间
GameConfig.TJQB.TIME2 = 0.4  --在指定点停留的时间
--指定点飞到终点是随机的时间取最大到最小值随机
GameConfig.TJQB.TIME3 = 1.0  --指定点飞到终点的最小时间
GameConfig.TJQB.TIME4 = 1.5  --指定点飞到终点的最大时间

GameConfig.TJQB.BEZIER_POINTS_JIN = {
	{cc.p(160,1),cc.p(160,-200)}, --第1条贝塞尔线控制点
	{cc.p(165,4),cc.p(160,-600)}, --第2条贝塞尔线控制点
	{cc.p(170,7),cc.p(160,-400)}, --第3条贝塞尔线控制点
	{cc.p(175,10),cc.p(160,-500)}, --第4条贝塞尔线控制点
	{cc.p(180,13),cc.p(160,-300)}, --第5条贝塞尔线控制点
	{cc.p(190,16),cc.p(160,-230)}, --第6条贝塞尔线控制点
	{cc.p(195,19),cc.p(160,-640)}, --第7条贝塞尔线控制点
	{cc.p(100,22),cc.p(160,-550)}, --第8条贝塞尔线控制点
	{cc.p(105,25),cc.p(160,-360)}, --第9条贝塞尔线控制点
	{cc.p(110,28),cc.p(160,-400)}, --第10条贝塞尔线控制点
}
GameConfig.TJQB.BEZIER_POINTS_YIN = {
	{cc.p(-160,1),cc.p(-160,-380)}, --第1条贝塞尔线控制点
	{cc.p(-160,1),cc.p(-160,-380)}, --第2条贝塞尔线控制点
	{cc.p(-160,1),cc.p(-160,-380)}, --第3条贝塞尔线控制点
	{cc.p(-160,1),cc.p(-160,-380)}, --第4条贝塞尔线控制点
	{cc.p(-160,1),cc.p(-160,-380)}, --第5条贝塞尔线控制点
	{cc.p(-160,1),cc.p(-160,-380)}, --第6条贝塞尔线控制点
	{cc.p(-160,1),cc.p(-160,-380)}, --第7条贝塞尔线控制点
	{cc.p(-160,1),cc.p(-160,-380)}, --第8条贝塞尔线控制点
	{cc.p(-160,1),cc.p(-160,-380)}, --第9条贝塞尔线控制点
	{cc.p(-160,1),cc.p(-160,-380)}, --第10条贝塞尔线控制点
}

GameConfig.POPULARSUPPORT = {}
GameConfig.POPULARSUPPORT.MISS_TIME = 0.7 --跑到右边的时间
GameConfig.POPULARSUPPORT.FADE_TIME = 0.3  -- 逐渐出来的时间
GameConfig.POPULARSUPPORT.INTERVAL_TIME = 0.2 --每个间隔

--缓存本地数据的key
GameConfig.PAYTWOCONFIRM = "PayTwoConfirm"
GameConfig.RESOURCELOSTCONFIRM = "ResourceLostConfirm"
GameConfig.LORDCITYSPEND = "LordCitySpend"
