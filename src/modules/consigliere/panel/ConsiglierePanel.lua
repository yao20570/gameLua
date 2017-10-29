
ConsiglierePanel = class("ConsiglierePanel", BasicPanel)
ConsiglierePanel.NAME = "ConsiglierePanel"

function ConsiglierePanel:ctor(view, panelName)
    ConsiglierePanel.super.ctor(self, view, panelName,true)

    self:setUseNewPanelBg(true)
end

function ConsiglierePanel:finalize()
    ConsiglierePanel.super.finalize(self)
end

function ConsiglierePanel:initPanel()
	ConsiglierePanel.super.initPanel(self)
	--
	self:setBgType(ModulePanelBgType.ROOM)
    self:addTabControl()
end

function ConsiglierePanel:addTabControl()

    self._tabControl = UITabControl.new(self)
    -- self._tabControl:setBg("bg/consigliere/room.jpg")

    self._tabControl:addTabPanel(ConsigliereForeignPanel.NAME,self:getTextWord(270055)) --内政
    self._tabControl:addTabPanel(ConsigliereListPanel.NAME,self:getTextWord(270056))  --军师
    self._tabControl:addTabPanel(ConsigliereRecruitsPanel.NAME,self:getTextWord(270057))  --招募
    --270033

    -- local consigliereProxy = self:getProxy( GameProxys.Consigliere )
    -- local allInfos = consigliereProxy:getAllInfo()
    -- if #allInfos<=0 then
    --     self._tabControl:setTabSelectByName( ConsigliereRecruitsPanel.NAME )
    -- else
    --     self._tabControl:setTabSelectByName( ConsigliereForeignPanel.NAME )
    -- end

    -- self:setTitle(true,self:getTextWord(3400))
    self:setTitle(true, "consigliere", true)
    
    --self:updateItemCount()
    -- self:setblacklayer(true)
end

function ConsiglierePanel:onShowHandler()
    -- 设置标签页的红点
    self:updateItemCount()
end


function ConsiglierePanel:updateItemCount()
    local consigliereProxy = self:getProxy(GameProxys.Consigliere)
    local data = consigliereProxy:getRecruitInfo() or {}
    local needCoin = data[1] and data[1].onceprice or 0
    local needRes = data[2] and data[2].onceprice or 0
    needCoin = needCoin>0 and 0 or 1
    needRes = needRes>0 and 0 or 1
    if (needCoin+needRes)>0 then
        self._tabControl:setItemCount(3,true,needCoin+needRes)
    else
        self._tabControl:setItemCount(3,false,0)
    end
end

function ConsiglierePanel:setblacklayer(visb)
    if self.blycl==null then
    self.blycl=cc.LayerColor:create(cc.c4b(0,0,0,100))
    self._skin:getRootNode():getChildByName("UIPanelBgNew"):addChild(self.blycl,2)
    end
    self.blycl:setVisible(visb)
end

--发送关闭系统消息
function ConsiglierePanel:onClosePanelHandler()
    self.view:dispatchEvent( ConsigliereEvent.HIDE_SELF_EVENT )
end