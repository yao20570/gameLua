
LordCityRecordView = class("LordCityRecordView", BasicView)

function LordCityRecordView:ctor(parent)
    LordCityRecordView.super.ctor(self, parent)
end

function LordCityRecordView:finalize()
    LordCityRecordView.super.finalize(self)
end

function LordCityRecordView:registerPanels()
    LordCityRecordView.super.registerPanels(self)

    require("modules.lordCityRecord.panel.LordCityRecordPanel")
    self:registerPanel(LordCityRecordPanel.NAME, LordCityRecordPanel)

    require("modules.lordCityRecord.panel.LordCityRecordSinglePanel")
    self:registerPanel(LordCityRecordSinglePanel.NAME, LordCityRecordSinglePanel)

    require("modules.lordCityRecord.panel.LordCityRecordFullPanel")
    self:registerPanel(LordCityRecordFullPanel.NAME, LordCityRecordFullPanel)
end

function LordCityRecordView:initView()
    local panel = self:getPanel(LordCityRecordPanel.NAME)
    panel:show()
end

function LordCityRecordView:onSingleRecordMapUpdate()
    local panel = self:getPanel(LordCityRecordSinglePanel.NAME)
    if panel:isVisible() then
        panel:onSingleRecordMapUpdate()
    end
end

function LordCityRecordView:onFullRecordMapUpdate()
    local panel = self:getPanel(LordCityRecordFullPanel.NAME)
    if panel:isVisible() then
        panel:onFullRecordMapUpdate()
    end
end


