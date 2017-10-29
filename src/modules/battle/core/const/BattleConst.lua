module("battleCore", package.seeall)

ModelAnimation = {}  --模型动作名
ModelAnimation.Attack = "attack"
ModelAnimation.Die = "die"
ModelAnimation.Hurt = "hurt"
ModelAnimation.Run = "run"
ModelAnimation.Wait = "wait"
ModelAnimation.Win = "win"


ModelDirection = {}  --模型朝向
ModelDirection.Left = 1 --朝左边
ModelDirection.Right = -1  --朝右边

ModelConsIndex = {}  --军师模型位置
ModelConsIndex.Left = 19 --左边军师
ModelConsIndex.Right = 29  --右边军师


BattleCamp = {}  --战斗阵营
BattleCamp.Left = 1  --左边阵营
BattleCamp.Right = 2 --右边阵营

HurtType = {}  --血量变更类型
HurtType.NormalHurt = 1 --普通攻击
HurtType.MagicHurt = 2 --普通攻击
HurtType.CritHurt = 3 --暴击
HurtType.DodgeHurt = 4 --闪避
HurtType.AddHpHurt = 5 --加血
HurtType.OtherHurt = 6 --其他类型
HurtType.RefrainHurt = 7 --克制类型

HurtEffectType = {} --伤害对应的飘字类型
HurtEffectType[HurtType.NormalHurt] = "BloodMinusEffect"
HurtEffectType[HurtType.MagicHurt] = "BloodMinusEffect"
HurtEffectType[HurtType.CritHurt] = "BloodCritEffect"
HurtEffectType[HurtType.DodgeHurt] = "BloodMinusEffect"
HurtEffectType[HurtType.AddHpHurt] = "BloodMinusEffect"
HurtEffectType[HurtType.OtherHurt] = "BloodMinusEffect"
HurtEffectType[HurtType.RefrainHurt] = "BloodRefrainEffect"


-- -------------------------------------------------------------------------------
-- -- 高阶兵种受击特效

-- -- effect="bu06_hit" ：匹配FightShow表的hurtaction里的effect
-- -- {'A',1,3} : 'A'=播放位置，1=坑位1，3=坑位3 ..(即前排还有敌人(受击坑位含有1~3之一)，则在A位置播放特效effect="bu06_hit")
-- -- {'B',4,6} : 'B'=播放位置，4=坑位4，6=坑位6 ..(即后排还有敌人(受击坑位含有4~6之一)，则在B位置播放特效effect="bu06_hit")
-- -- 坑位A~F坐标到UI:BattlePanel中调整

-- HurtSkillConf = {}  --高级佣兵受击特效
-- HurtSkillConf[1] = {ID = 1, effect="bu06_hit", indexMaps={{'A',1,3},{'B',4,6}}}  
-- HurtSkillConf[2] = {ID = 2, effect="gong06_hit", indexMaps={{'C',1,6}}}  
-- HurtSkillConf[3] = {ID = 3, effect="qiang06_hit", indexMaps={{'D',1,1},{'D',4,4},{'E',2,2},{'E',5,5},{'F',3,3},{'F',6,6}}}  
-- HurtSkillConf[4] = {ID = 4, effect="qi01_atk", indexMaps={{'A',1,3},{'B',4,6}}}
-- HurtSkillConf[5] = {ID = 5, effect="gong08_hit", indexMaps={{'C',1,6}}}
-- HurtSkillConf[6] = {ID = 6, effect="bu01_hit", indexMaps={{'A',1,3},{'B',4,6}}}  

-- -------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 高阶兵种攻击特效

-- {'A',1,3} : 'A'=播放位置，1=坑位1，3=坑位3 ..(即前排还有敌人(受击坑位含有1~3之一)，则在A位置播放特效effect="bu06_hit")
-- {'B',4,6} : 'B'=播放位置，4=坑位4，6=坑位6 ..(即后排还有敌人(受击坑位含有4~6之一)，则在B位置播放特效effect="bu06_hit")
-- 坑位A~F坐标到UI:BattlePanel中调整

HurtSkillConf = {}  --高级佣兵攻击特效
HurtSkillConf[1] = {ID = 1, showType = 1, indexMaps={{'A',1,3},{'B',4,6}}}  --固定A/B位播放
HurtSkillConf[2] = {ID = 2, showType = 2, indexMaps={{'C',1,6}}}   --固定C位播放
HurtSkillConf[3] = {ID = 3, showType = 3, indexMaps={{'D',1,1},{'D',4,4},{'E',2,2},{'E',5,5},{'F',3,3},{'F',6,6}}}  --固定D/E/F位播放
HurtSkillConf[4] = {ID = 4, showType = 4, indexMaps={{'G',1,1},{'H',2,2},{'I',3,3},{'J',4,4},{'K',5,5},{'L',6,6}}}

-------------------------------------------------------------------------------

