--奖励数据处理
RewardManager = {}
local FixRewardConfig = require("excelConfig.FixRewardConfig")
local ChoiceRewardConfig = require("excelConfig.ChoiceRewardConfig")
local ChoiceContentConfig = require("excelConfig.ChoiceContentConfig")

function RewardManager:init(gameState)
    self._gameState = gameState
end

function RewardManager:finalize()

end

function RewardManager:getProxy(name)
    return self._gameState:getProxy(name)
end

--  reward = '[567,572]'  return   UIIconDatas = {{power = , typeid = ,num = }, ...}
function RewardManager:jsonRewardGroupToArray(reward)
    local fixedRewardIdGroup = StringUtils:jsonDecode(reward)
    local UIIconDatas = {}
    local function getFixedRewardsByID(id)
        rewardItem = StringUtils:jsonDecode(FixRewardConfig[id].reward)
        local datas = {}
        for i,v in ipairs(rewardItem) do
            local data = {}
            data.power = v[1]
            data.typeid = v[2]
            data.num = v[3]
            table.insert(UIIconDatas,data)
        end
        return datas
    end
    for _, id in ipairs(fixedRewardIdGroup) do
        getFixedRewardsByID(id)
    end
    return UIIconDatas
end

--id 额外奖励ID
--返回值Data    icon 图标名称 canGets 达到条件可以领取  cannotGets未达条件不可领取
--不可领取中含 需要vip等级或人物等级信息
function RewardManager:getAddedRewardById(id)
    local Data = {}
    local rewardID
    for k, v in pairs(ChoiceRewardConfig) do
        if k == id then
            Data.icon = v.icon
            Data.choicenum = v.choicenum
            rewardID = v.rewardID
        end
    end
    Data.canGets = {} 
    Data.cannotGets = {}
    local roleProxy = self:getProxy(GameProxys.Role)
    for _, v in pairs(ChoiceContentConfig) do
        if v.group == rewardID then
            local item = {}
            item.power = v.type
            item.typeid = v.contentID
            item.num = v.num
            item.ID = v.ID
            if roleProxy:getRoleAttrValue(v.contype) <   v.condition 
                and v.contype ~= 0 then
                item.Power_value = v.contype
                item.needLv = v.condition
                table.insert(Data.cannotGets,item)
            else
                table.insert(Data.canGets,item)
            end
        end
    end
    return Data
end

