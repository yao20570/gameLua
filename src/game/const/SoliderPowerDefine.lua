
--佣兵对应power值
SoliderPowerDefine = {}

SoliderPowerDefine.life = 1 --生命力，血量上限
SoliderPowerDefine.attack = 3 --攻击力
SoliderPowerDefine.target = 4 --命中
SoliderPowerDefine.escape = 5 --闪避
SoliderPowerDefine.heavyFight = 6 --暴击
SoliderPowerDefine.Kbao = 7 --抗暴
SoliderPowerDefine.chuanCi = 8  --穿刺
SoliderPowerDefine.proctect = 9 --防护
SoliderPowerDefine.critdam  = 33 -- 爆伤
SoliderPowerDefine.tenacity = 34 -- 韧性
SoliderPowerDefine.damHurt  = 44 -- 伤害
SoliderPowerDefine.damArmor = 45 -- 护甲

-- /*血量上限*/
SoliderPowerDefine.POWER_hpMax = 1;
--    /*血量*/
SoliderPowerDefine.POWER_hp = 2;
--    /*攻击*/
SoliderPowerDefine.POWER_atk = 3;
--    /*命中率*/
SoliderPowerDefine.POWER_hitRate = 4;
--    /*闪避率*/
SoliderPowerDefine.POWER_dodgeRate = 5;
--    /*暴击率*/
SoliderPowerDefine.POWER_critRate = 6;
--    /*抗暴率*/
SoliderPowerDefine.POWER_defRate = 7;
 --   /*穿刺*/
SoliderPowerDefine.POWER_wreck = 8;
 --   /*防护*/
SoliderPowerDefine.POWER_defend = 9;
 --   /*先手值*/
SoliderPowerDefine.POWER_initiative = 10;
--   /*血量百分比*/
SoliderPowerDefine.POWER_hpMaxRate = 11;
--   /*攻击百分比*/
SoliderPowerDefine.POWER_atkMaxRate = 12;


 -- /*步兵血量百分比*/
 SoliderPowerDefine.POWER_infantryHpMax = 13;
 --/*步兵攻击百分比*/
SoliderPowerDefine.POWER_infantryAtk = 14;
--/*骑兵血量百分比*/
SoliderPowerDefine.POWER_cavalryHpMax = 15;
--   /*骑兵攻击百分比*/
SoliderPowerDefine.POWER_cavalryAtk = 16;
 --/*枪兵血量百分比*/
SoliderPowerDefine.POWER_pikemanHpMax = 17;
 --   /*枪兵攻击百分比*/
SoliderPowerDefine.POWER_pikemanAtk = 18;
 --   /*弓兵血量百分比*/
SoliderPowerDefine.POWER_archerHpMax = 19;
 --   /*弓兵攻击百分比*/
SoliderPowerDefine.POWER_archerHpatk = 20;




SoliderPowerDefine.weight = 21  --载重
SoliderPowerDefine.skill = 30  --技能

SoliderPowerDefine.type = {} 
SoliderPowerDefine.type[21] = "weight"

SoliderPowerDefine.equipAttribute = {}  --装备的属性值

SoliderPowerDefine.equipAttribute[12] = "atkRate"    --攻击
SoliderPowerDefine.equipAttribute[4] = "hitRate"     --命中
SoliderPowerDefine.equipAttribute[6] = "critRate"    --暴击
SoliderPowerDefine.equipAttribute[11] = "hpRate"     --生命
SoliderPowerDefine.equipAttribute[5] = "dodgeRate"   --闪避
SoliderPowerDefine.equipAttribute[7] = "defRate"     --抗暴

SoliderPowerDefine.equipGao = {}
SoliderPowerDefine.equipGao[12] = "高攻击"
SoliderPowerDefine.equipGao[4] = "高命中"
SoliderPowerDefine.equipGao[6] = "高暴击"
SoliderPowerDefine.equipGao[11] = "高生命"
SoliderPowerDefine.equipGao[5] = "高闪避"
SoliderPowerDefine.equipGao[7] = "高抗暴"