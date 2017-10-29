module("battleCore", package.seeall)

NumFactory = class("NumFactory")

local instance = nil

function NumFactory:ctor()

end

function NumFactory:getInstance()
    if instance == nil then
        instance = NumFactory.new()
    end

    return instance
end

function NumFactory:finalize()
    instance = nil
end


function NumFactory:getNumByType(hurtType, value)
    local num = nil

    local str = tostring(math.abs(value))

    if hurtType ==  HurtType.CritHurt then
        num = self:getCritNum(hurtType)
    elseif hurtType ==  HurtType.AddHpHurt then
        num = self:getAddNum()
    elseif hurtType == HurtType.DodgeHurt then
        num = self:getMissNum()
    elseif hurtType == HurtType.RefrainHurt then
        num = self:getRefrainNum(hurtType)
    else
        num = self:getMinusNum()
    end

    -- if num ~= nil and hurtType ~= HurtType.DodgeHurt then
    --     num:setString(str)
    -- end

    if num ~= nil then
        if hurtType == HurtType.RefrainHurt or hurtType == HurtType.CritHurt then
            --暴击、克制的数值
            local number = num:getChildByTag(hurtType)
            number:setString(value)
        elseif hurtType ~= HurtType.DodgeHurt then
            -- 闪避没数值
            num:setString(str)
        end
    end

    return num
end


function NumFactory:getMissNum()
    local miss = TextureManager:createSprite("images/battle/image19.png")
    miss.setString = function() end
    return miss
end

function NumFactory:getMinusNum()
    local num = ccui.TextAtlas:create()
    num:setProperty("1234567890", "ui/images/fonts/num_attack_2.png", 34, 46, "0")
    
    return num
end

--[[
-- 暴击
-- @新建一个父节点，然后数字标签和文字作为子节点
-- @设置数字标签的tag为hurtType
-- @设置文字的name为对应资源文件名
]]
function NumFactory:getCritNum(hurtType)
    local node = cc.Sprite:create()

    local num = ccui.TextAtlas:create()
    num:setProperty("1234567890", "ui/images/fonts/num_attack_1.png", 34, 46, "0")

    node:addChild(num, 0, hurtType)

    local resTab = {"bg_eff","bao_eff","ji_eff"}
    for i=1,#resTab do
        local url = string.format("images/battle/%s.png", resTab[i])
        local eff = TextureManager:createSprite(url)
        node:addChild(eff, 0, resTab[i])
    end
    node.resTab = resTab

    return node
end

-- 克制 
-- 解释：参考方法NumFactory:getCritNum(hurtType)
function NumFactory:getRefrainNum(hurtType)
    local node = cc.Sprite:create()
    local num = self:getMinusNum()
    node:addChild(num, 0, hurtType)

    -- local resPos = {-16.15, -8.56}   --旋转：背景、克制
    local resTab = {"bg_eff", "kz_eff"}
    local resEff = {}
    for i=1,#resTab do
        local url = string.format("images/battle/%s.png", resTab[i])
        local eff = TextureManager:createSprite(url)
        -- eff:setRotation(resPos[i])
        node:addChild(eff, 0, resTab[i])
    end
    node.resTab = resTab

    return node
end

function NumFactory:getAddNum()
    local num = ccui.TextAtlas:create()
    num:setProperty("1234567890", "ui/images/fonts/num_attack_3.png", 38, 39, "0")

    return num
end

















