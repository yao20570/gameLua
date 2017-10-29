module("server", package.seeall)

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

SoldierDefine.POWER_NAME_MAP = {}

function SoldierDefine:getPowerName(power)
    if SoldierDefine.POWER_NAME_MAP[power] ~= nil then
        return SoldierDefine.POWER_NAME_MAP[power]
    end
    for key, value in pairs(SoldierDefine) do
        if power == value then
            if key ~= "TOTAL_FIGHT_POWER" then
                local name = string.gsub(key, "POWER_", "")
                SoldierDefine.POWER_NAME_MAP[power] = name
                return name
            end
        end
    end
    return ""
end