
EspecialGoodsUseView = class("EspecialGoodsUseView", BasicView)

function EspecialGoodsUseView:ctor(parent)
    EspecialGoodsUseView.super.ctor(self, parent)
end

function EspecialGoodsUseView:finalize()
    EspecialGoodsUseView.super.finalize(self)
end

function EspecialGoodsUseView:registerPanels()
    EspecialGoodsUseView.super.registerPanels(self)

    require("modules.especialGoodsUse.panel.EspecialGoodsUsePanel")
    self:registerPanel(EspecialGoodsUsePanel.NAME, EspecialGoodsUsePanel)

    require("modules.especialGoodsUse.panel.EspecialSelectPanel")
    self:registerPanel(EspecialSelectPanel.NAME, EspecialSelectPanel)

    require("modules.especialGoodsUse.panel.RedPacketItemUsePanel")
    self:registerPanel(RedPacketItemUsePanel.NAME, RedPacketItemUsePanel)
end

function EspecialGoodsUseView:initView()
    -- local panel = self:getPanel(EspecialGoodsUsePanel.NAME)
    -- panel:show()
end

function EspecialGoodsUseView:showExtraMsg(extraMsg)
    if extraMsg.itemtype then
        if extraMsg.itemtype == 42 then
            --红包物品使用（打开选择频道界面）
            local panel = self:getPanel(RedPacketItemUsePanel.NAME)
            local noShowBlur = true
            panel:show(extraMsg,nil,noShowBlur)
        end 
    else
    	local panel = self:getPanel(EspecialGoodsUsePanel.NAME)
        local noShowBlur = true
        panel:show(extraMsg, nil, noShowBlur)
    end 
end

function EspecialGoodsUseView:onPlayerInfoResp(data)
    local panel = self:getPanel(EspecialSelectPanel.NAME)
    panel:onPlayerInfoResp(data)
end

function EspecialGoodsUseView:onLaterPersonResp(data)
    self.nearData = data.infos
end

function EspecialGoodsUseView:getNearData()
    return self.nearData or {}
end