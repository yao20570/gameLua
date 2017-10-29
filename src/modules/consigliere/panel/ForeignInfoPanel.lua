-- 资源道具
ForeignInfoPanel = class("ForeignInfoPanel", BasicPanel)
ForeignInfoPanel.NAME = "ForeignInfoPanel"

function ForeignInfoPanel:ctor(view, panelName)
    ForeignInfoPanel.super.ctor(self, view, panelName, 900)

    self:setUseNewPanelBg(true)
end

function ForeignInfoPanel:finalize()
    ForeignInfoPanel.super.finalize(self)
end

function ForeignInfoPanel:initPanel()
    ForeignInfoPanel.super.initPanel(self)

    self:setTitle(true, self:getTextWord(270064))

    self._listView = self:getChildByName("Panel_46/ListView_0")   

    self.proxy = self:getProxy(GameProxys.Consigliere)
    self.interiorConf = ConfigDataManager:getConfigData( ConfigData.InteriorConfig ) or {}
end   
--每次打开面板时调用
function ForeignInfoPanel:onShowHandler()
    if self._listView then
        self._listView:jumpToTop()
    end

    local datalist = self.proxy:getAllPosInfo()
    table.sort( datalist, function(a,b)
        local confa = self.interiorConf[a.pos] or {}
        local confb = self.interiorConf[b.pos] or {}
        local ret = true
        if confa.openlv and confb.openlv then
            ret = confa.openlv<confb.openlv
        end
        return ret
    end )
    self:renderListView( self._listView, datalist, self, self.renderItemPanel)
end

function ForeignInfoPanel:renderItemPanel(item, data, index)

    local info = self.proxy:getInfoById( data.id ) or {}
    local conf = self.proxy:getDataById( info.typeId ) or {}

    local lab_name = item:getChildByName("lab_name")
    local lab_tit = item:getChildByName("lab_tit")
    local lab_vul = item:getChildByName("lab_vul")

    local bg = item:getChildByName( "Image_752" )
    bg:setVisible( index%2==0 )

    --
    local sName = conf.name
    if info and info.lv>0 then
        sName = sName.."+"..info.lv
    end
    lab_name:setString( sName )
    lab_name:setColor( ColorUtils:getColorByQuality( conf.quality ) )

    local InteriorConf = self.interiorConf[data.pos] or {}

    -- 信息
    local sInfo = InteriorConf.info or ""
    lab_tit:setString( sInfo )

    -- 加成
    local vul = self.proxy:analyzeForeignAddVul( conf.quality, InteriorConf.effectshow )
    local addShow = StringUtils:jsonDecode( conf.addShow or "[]" )
    print("vul1", vul)
    if addShow and addShow[1]==data.pos then
        vul = vul + (addShow[2] or 0)
    print("vul12", vul)
    end
    local str = vul..( data.pos~=1 and "%" or "")
    lab_vul:setString( str )

end
