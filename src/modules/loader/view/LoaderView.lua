
LoaderView = class("LoaderView", BasicView)

function LoaderView:ctor(parent)
    LoaderView.super.ctor(self, parent)
end

function LoaderView:finalize()
    LoaderView.super.finalize(self)
end

function LoaderView:registerPanels()
    LoaderView.super.registerPanels(self)

    require("modules.loader.panel.LoaderPanel")
    self:registerPanel(LoaderPanel.NAME, LoaderPanel)
end

function LoaderView:initView()
    local panel = self:getPanel(LoaderPanel.NAME)
    panel:show()
end

function LoaderView:setProgress(percent, noAction, delay)
    local panel = self:getPanel(LoaderPanel.NAME)
    panel:setProgress(percent, noAction, delay)
end

function LoaderView:setStateLabel(label)
    local panel = self:getPanel(LoaderPanel.NAME)
    panel:setStateLabel(label)
end

function LoaderView:setUpdateFileSize(filesize)
    local panel = self:getPanel(LoaderPanel.NAME)
    panel:setUpdateFileSize(filesize, 0)
end

function LoaderView:setIsUpdateLoader(value)
    local panel = self:getPanel(LoaderPanel.NAME)
    panel:setIsUpdateLoader(value)
end

function LoaderView:pauseModel()
    local panel = self:getPanel(LoaderPanel.NAME)
    panel:pauseModel()
end

