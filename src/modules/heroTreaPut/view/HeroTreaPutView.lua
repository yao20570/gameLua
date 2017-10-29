
HeroTreaPutView = class("HeroTreaPutView", BasicView)

function HeroTreaPutView:ctor(parent)
    HeroTreaPutView.super.ctor(self, parent)
end

function HeroTreaPutView:finalize()
    HeroTreaPutView.super.finalize(self)
end

function HeroTreaPutView:registerPanels()
    HeroTreaPutView.super.registerPanels(self)

    require("modules.heroTreaPut.panel.HeroTreaPutPanel")
    self:registerPanel(HeroTreaPutPanel.NAME, HeroTreaPutPanel)
end

function HeroTreaPutView:initView()
--    local panel = self:getPanel(HeroTreaPutPanel.NAME)
--    panel:show()
end
function HeroTreaPutView:onShowView(extraMsg,isInit, isAutoUpdate)
    HeroTreaPutView.super.onShowView(self,extraMsg, false)
    self:saveCurHeroIdAndPostData(extraMsg.putData)
    local panel = self:getPanel(HeroTreaPutPanel.NAME)
    panel:show(extraMsg.putData)

end
function HeroTreaPutView:saveCurHeroIdAndPostData(data)
	self.curHeroIdAndPostData = data
end
function HeroTreaPutView:getCurHeroIdAndPostDataData()
	return self.curHeroIdAndPostData
end
function HeroTreaPutView:heroTFInfoChange()
    -- local panel = self:getPanel(HeroTreaFragmentPanel.NAME)
    -- panel:updateView()
end
--宝具上下装刷新
function HeroTreaPutView:treasurePutHandler()
     local panel = self:getPanel(HeroTreaPutPanel.NAME)
     panel:treasurePutHandler()
end