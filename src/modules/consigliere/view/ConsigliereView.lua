
ConsigliereView = class("ConsigliereView", BasicView)

function ConsigliereView:ctor(parent)
    ConsigliereView.super.ctor(self, parent)
end

function ConsigliereView:finalize()
    ConsigliereView.super.finalize(self)
end

function ConsigliereView:registerPanels()
    ConsigliereView.super.registerPanels(self)

    require("modules.consigliere.panel.ConsiglierePanel")
    self:registerPanel(ConsiglierePanel.NAME, ConsiglierePanel)

    require("modules.consigliere.panel.ConsigliereListPanel")
    self:registerPanel(ConsigliereListPanel.NAME, ConsigliereListPanel)

    require("modules.consigliere.panel.ConsigliereRecruitsPanel")
    self:registerPanel(ConsigliereRecruitsPanel.NAME, ConsigliereRecruitsPanel)

    require("modules.consigliere.panel.ConsigliereForeignPanel")
    self:registerPanel(ConsigliereForeignPanel.NAME, ConsigliereForeignPanel)

    require("modules.consigliere.panel.AdvancedPanel")
    self:registerPanel(AdvancedPanel.NAME, AdvancedPanel)

    require("modules.consigliere.panel.ConsigliereResolvePanel")
    self:registerPanel(ConsigliereResolvePanel.NAME, ConsigliereResolvePanel)

    require("modules.consigliere.panel.ConsigliereTipsPanel")
    self:registerPanel(ConsigliereTipsPanel.NAME, ConsigliereTipsPanel)

    require("modules.consigliere.panel.AdvancePanel")
    self:registerPanel(AdvancePanel.NAME, AdvancePanel)

    require("modules.consigliere.panel.ChoosePanel")
    self:registerPanel(ChoosePanel.NAME, ChoosePanel)

    require("modules.consigliere.panel.ConsigliereRewardPanel")
    self:registerPanel(ConsigliereRewardPanel.NAME, ConsigliereRewardPanel)

end

function ConsigliereView:initView()
    local panel = self:getPanel(ConsiglierePanel.NAME)
    panel:show()
    panel:setHtmlStr("html/help_general.html")
end

function ConsigliereView:onOneKeySuc(newids)
    -- local panel = self:getPanel(AdvancePanel.NAME)
    -- panel:onOneKeySuc(data)

    local newDataList = {}
    for i,typeid in ipairs(newids) do
        table.insert( newDataList, {typeId=typeid} )
    end
    local data = { title=self:getTextWord(270073), dataList=newDataList, isNewAdviserPanel=true, callback=function()
        local panel = self:getPanel(AdvancePanel.NAME)
        panel:ainmInitPosition()
    end }  --获得新英雄
    local panel = self:getPanel(ChoosePanel.NAME)
    panel:show( data )

    --一键 进阶成功 还原位置
end

function ConsigliereView:updateAdvView(data)
    local panel = self:getPanel(AdvancePanel.NAME)
    panel:updateView(data)
end

function ConsigliereView:advanceSuccess(data)
    local panel = self:getPanel(AdvancePanel.NAME)
    panel:advanceSuccess( data.rs, data.newid)
end

-- 重写onShowView(),用于每次打开panel都执行onShowHandler()
function ConsigliereView:onShowView(extraMsg, isInit)
    ConsigliereView.super.onShowView(self,extraMsg, isInit, true)
end


function ConsigliereView:updateView( newDataList )
    print("刷新全部界面")
    local advancePanel = self:getPanel(AdvancePanel.NAME)

    --军师列表界面
    if not advancePanel:isVisible() then
        self:updateConsigliereList()
    end

    --内政设置成功
    local panel = self:getPanel( ConsigliereForeignPanel.NAME )
    panel:updateForeign()

    --军师升级成功
    panel = self:getPanel(AdvancedPanel.NAME)
    panel:onLevelUpSuccess()

    --进阶成功 还原位置
    panel = self:getPanel(AdvancePanel.NAME)
    panel:onAuto()
    panel:setInitPos()

    self:updateRecruitsPoint()
end

function ConsigliereView:updateConsigliereList()
    local panel = self:getPanel(ConsigliereListPanel.NAME)
    panel:updateView()
end

function ConsigliereView:resolveSuccess()
    local panel = self:getPanel(ConsigliereListPanel.NAME)
    panel:resolveSuccess()
end

function ConsigliereView:onRecruitingResp(data)
    local panel = self:getPanel(ConsigliereRecruitsPanel.NAME)
    panel:onRecruitingResp(data)

    -- panel = self:getPanel(ConsigliereRewardPanel.NAME)
    -- panel:updateView(data)
end

-- function ConsigliereView:showOtherView(data)
--     local panel = self:getPanel(ConsigliereListPanel.NAME)
--     panel:showOtherView(data)
-- end

function ConsigliereView:upgradeSuccess()
    local mainPanel = self:getPanel(ConsiglierePanel.NAME)
    mainPanel:show()
end

function ConsigliereView:hideModuleHandler()
    self:dispatchEvent(ConsigliereEvent.HIDE_SELF_EVENT, {})
end

function ConsigliereView:onShowStatus(flag)
    self._flag = flag
end

function ConsigliereView:onGetShowStatus()
    return self._flag
end


function ConsigliereView:updateHeadIcon( item, id )
    item:setBackGroundColorType(0)
end

function ConsigliereView:onUpdateBuyView()
    local panel = self:getPanel(ConsigliereRecruitsPanel.NAME)
    panel:updateView()

    panel = self:getPanel(ConsigliereRewardPanel.NAME)
    panel:updatePrice()

    self:updateRecruitsPoint()
end

function ConsigliereView:updateRecruitsPoint()
    local panel = self:getPanel(ConsiglierePanel.NAME)
    if panel:isInitUI() == true then
        panel:updateItemCount()
    end
end

function ConsigliereView:jumpToTab( panelName )
    local panels = {
        ConsigliereListPanel.NAME,
        ConsigliereRecruitsPanel.NAME,
        ConsigliereForeignPanel.NAME,
        AdvancedPanel.NAME,
        ConsigliereResolvePanel.NAME,
        ConsigliereTipsPanel.NAME,
        AdvancePanel.NAME,
        ChoosePanel.NAME,
        ConsigliereRewardPanel.NAME,
    }
    for i,p in ipairs(panels) do
        if panelName~=p then
            local panel = self:getPanel( p )
            panel:hide()
        end
    end

    local panel = self:getPanel(ConsiglierePanel.NAME)
    panel:changeTabSelectByName( panelName )
end