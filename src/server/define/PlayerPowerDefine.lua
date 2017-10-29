module("server", package.seeall)

PlayerPowerDefine = {}

--  --******数据库保存人物属性power*******/
PlayerPowerDefine.POWER_exp = 101  --经验
PlayerPowerDefine.POWER_energy = 102  --军令(能量)
PlayerPowerDefine.POWER_vipExp = 103  --vip经验
PlayerPowerDefine.POWER_prestige = 104  --声望
PlayerPowerDefine.POWER_honour = 105  --荣誉
PlayerPowerDefine.POWER_command = 106  --带兵量
PlayerPowerDefine.POWER_boom = 107  --繁荣度
PlayerPowerDefine.POWER_arenaGrade = 108  --竞技场积分
PlayerPowerDefine.POWER_areaId = 109  --服务器id
PlayerPowerDefine.POWER_level = 110  --等级
PlayerPowerDefine.POWER_sex = 111  --性别
PlayerPowerDefine.POWER_icon = 112  --头像
PlayerPowerDefine.POWER_militaryRank = 113  --军衔
PlayerPowerDefine.POWER_vipLevel=114  --VIP等级
PlayerPowerDefine.POWER_boomLevel=115  --繁荣等级
PlayerPowerDefine.POWER_boomUpLimit=116  --繁荣度上限
PlayerPowerDefine.POWER_commandLevel=117  --统帅等级
PlayerPowerDefine.POWER_prestigeLevel=118  --声望等级
PlayerPowerDefine.POWER_equipsize = 119  --装备仓库容量
PlayerPowerDefine.POWER_buildsize = 120  --建筑位
PlayerPowerDefine.POWER_tael = 201  --银两（宝石）
PlayerPowerDefine.POWER_iron = 202  --铁锭(铁矿)
PlayerPowerDefine.POWER_wood = 203  --木材（铜矿）
PlayerPowerDefine.POWER_stones = 204  --石料（石油）
PlayerPowerDefine.POWER_food = 205  --粮食（硅矿）
PlayerPowerDefine.POWER_gold = 206  --金币(元宝)
PlayerPowerDefine.POWER_giftgold = 207  --礼券
PlayerPowerDefine.POWER_active = 208  --活跃
PlayerPowerDefine.POWER_atklv = 209 --  -- //攻击装备最高等级
PlayerPowerDefine.POWER_critlv = 210  --暴击装备最高等级
PlayerPowerDefine.POWER_dogelv = 211  --闪避装备最高等级
PlayerPowerDefine.POWER_autoBuild = 213  --开关
PlayerPowerDefine.POWER_legionLevel=214  --军团等级

      --******Power大类*********/
      --道具*/
PlayerPowerDefine.BIG_POWER_ITEM = 401  --
      --武将*/
PlayerPowerDefine.BIG_POWER_GENERAL = 402  --
      --军械*/
PlayerPowerDefine.BIG_POWER_ORDNANCE = 403  --
      --军械碎片*/
PlayerPowerDefine.BIG_POWER_ORDNANCE_FRAGMENT = 404  --
      --谋士*/
PlayerPowerDefine.BIG_POWER_COUNSELLOR = 405  --
      --佣兵*/
PlayerPowerDefine.BIG_POWER_SOLDIER = 406  --
      --资源*/
PlayerPowerDefine.BIG_POWER_RESOURCE = 407  --

      --******缓存人物属性*******/
       --血量上限*/
PlayerPowerDefine.NOR_POWER_hpMax = 1  --
      --血量*/
PlayerPowerDefine.NOR_POWER_hp = 2  --
      --攻击*/
PlayerPowerDefine.NOR_POWER_atk = 3  --
      --命中率*/
PlayerPowerDefine.NOR_POWER_hitRate = 4  --
      --闪避率*/
PlayerPowerDefine.NOR_POWER_dodgeRate = 5  --
      --暴击率*/
PlayerPowerDefine.NOR_POWER_critRate = 6  --
      --抗暴率*/
PlayerPowerDefine.NOR_POWER_defRate = 7  --
      --穿刺*/
PlayerPowerDefine.NOR_POWER_wreck = 8  --
      --防护*/
PlayerPowerDefine.NOR_POWER_defend = 9  --
      --先手值*/
PlayerPowerDefine.NOR_POWER_initiative = 10  --
      --血量百分比*/
PlayerPowerDefine.NOR_POWER_hpMaxRate = 11  --
      --攻击百分比*/
PlayerPowerDefine.NOR_POWER_atkRate = 12  --
      --步兵血量百分比*/
PlayerPowerDefine.NOR_POWER_infantryHpMax = 13  --
      --步兵攻击百分比*/
PlayerPowerDefine.NOR_POWER_infantryAtk = 14  --
      --骑兵血量百分比*/
PlayerPowerDefine.NOR_POWER_cavalryHpMax = 15  --
      --骑兵攻击百分比*/
PlayerPowerDefine.NOR_POWER_cavalryAtk = 16  --
      --枪兵血量百分比*/
PlayerPowerDefine.NOR_POWER_pikemanHpMax = 17  --
      --枪兵攻击百分比*/
PlayerPowerDefine.NOR_POWER_pikemanAtk = 18  --
      --弓兵血量百分比*/
PlayerPowerDefine.NOR_POWER_archerHpMax = 19  --
      --弓兵攻击百分比*/
PlayerPowerDefine.NOR_POWER_archerHpatk = 20  --
      --载重*/
PlayerPowerDefine.NOR_POWER_load = 21  --
      --载重百分比*/
PlayerPowerDefine.NOR_POWER_loadRate = 22  --
      --行军速度加成比*/
PlayerPowerDefine.NOR_POWER_speedRate = 23  --
      --PVE伤害加成*/
PlayerPowerDefine.NOR_POWER_pveDamAdd = 24  --
      --PVE伤害减免*/
PlayerPowerDefine.NOR_POWER_pveDamDer = 25  --
      --PVP伤害加成*/
PlayerPowerDefine.NOR_POWER_pvpDamAdd = 26  --
      --PVP伤害减免*/
PlayerPowerDefine.NOR_POWER_pvpDamDer = 27  --
      --伤害加成*/
PlayerPowerDefine.NOR_POWER_damadd = 28  --
      --伤害减免*/
PlayerPowerDefine.NOR_POWER_damder = 29  --
      --最高战力*/
PlayerPowerDefine.NOR_POWER_highestCapacity	=30  --

      --建筑位*/
PlayerPowerDefine.NOR_POWER_buildlevel=39  --

      --银两容量*/
PlayerPowerDefine.NOR_POWER_taelcontent =51  --
      --铁锭矿容量*/
PlayerPowerDefine.NOR_POWER_ironcontent =52  --
      --木材容量*/
PlayerPowerDefine.NOR_POWER_woodcontent =53  --
      --石料容量*/
PlayerPowerDefine.NOR_POWER_stonescontent =54  --
      --粮食容量*/
PlayerPowerDefine.NOR_POWER_foodcontent =55  --
      --仓库容量*/
PlayerPowerDefine.NOR_POWER_depotcontent =56  --
      --银两产量*/
PlayerPowerDefine.NOR_POWER_taelyield =57  --
      --铁锭产量*/
PlayerPowerDefine.NOR_POWER_ironyield =58  --
      --木材产量*/
PlayerPowerDefine.NOR_POWER_woodyield =59  --
      --石料产量*/
PlayerPowerDefine.NOR_POWER_stonesyield =60  --
      --/粮食产量*/
PlayerPowerDefine.NOR_POWER_foodyield =61  --
      --仓库保护量*/
PlayerPowerDefine.NOR_POWER_depotprotect =62  --
      --银两容量百分比*/
PlayerPowerDefine.NOR_POWER_taelcontentrate =63  --
      --铁锭矿容量百分比*/
PlayerPowerDefine.NOR_POWER_ironcontentrate =64  --
      --木材容量百分比*/
PlayerPowerDefine.NOR_POWER_woodcontentrate =65  --
      --石料容量百分比*/
PlayerPowerDefine.NOR_POWER_stonescontentrate =66  --
      --粮食容量百分比*/
PlayerPowerDefine.NOR_POWER_foodcontentrate =67  --
      --仓库容量百分比*/
PlayerPowerDefine.NOR_POWER_depotcontentrate =68  --
      --银两产量百分比*/
PlayerPowerDefine.NOR_POWER_taelyieldrate =69  --
      --铁锭矿产量百分比*/
PlayerPowerDefine.NOR_POWER_ironyieldrate =70  --
      --木材产量百分比*/
PlayerPowerDefine.NOR_POWER_woodyieldrate=71  --
      --石料产量百分比*/
PlayerPowerDefine.NOR_POWER_stonesyieldrate=72  --
      --粮食产量百分比*/
PlayerPowerDefine.NOR_POWER_foodyieldrate=73  --
      --仓库保护量百分比*/
PlayerPowerDefine.NOR_POWER_depotprotectrate=74  --
      --战斗经验加成比*/
PlayerPowerDefine.NOR_POWER_exprate=75  --
      --建筑速度加成比*/
PlayerPowerDefine.NOR_POWER_buildspeedrate=76  --
      --科技研发速度加成比*/
PlayerPowerDefine.NOR_POWER_scirespeedrate=77  --
      --全资源产量*/
PlayerPowerDefine.NOR_POWER_allresyield=78  --
      --	全资源产量百分比*/
PlayerPowerDefine.NOR_POWER_allresyieldrate=79  --
      --建筑时间减免*/
PlayerPowerDefine.NOR_POWER_buildtimered=80  --
      --	繁荣度损失加成*/
PlayerPowerDefine.NOR_POWER_boomlossrate=81  --
      --兵种生成速度加成比*/
PlayerPowerDefine.NOR_POWER_armyprorate	=82  --
      --兵种改造速度加成比*/
PlayerPowerDefine.NOR_POWER_armyremrate=83  --
      --统帅升级成功率加成*/
PlayerPowerDefine.NOR_POWER_commandrateadd=84  --

PlayerPowerDefine.NOR_POWER_advexprate	=85  --
      --野外资源经验加成比*/
PlayerPowerDefine.NOR_POWER_resexprate	=86  --
      --繁荣度损失固定值*/
PlayerPowerDefine.NOR_POWER_boomlossfix	=87  --
      --野外资源采集速度加成*/
PlayerPowerDefine.NOR_POWER_rescollectrate	=88  --
      --野外临时建筑位*/
PlayerPowerDefine.NOR_POWER_temporary_building=89  --
      --外观*/
PlayerPowerDefine.NOR_POWER_facade=90  --
      --保护期不会被攻击和侦查*/
PlayerPowerDefine.NOR_POWER_protect_date=91  --

PlayerPowerDefine.POWER_armygroupId=92  --

      --叠加的临时建筑位*/
PlayerPowerDefine.NOR_POWER_tempro=93  --