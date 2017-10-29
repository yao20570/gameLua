--

---const
require("game.const.GameConfig")
require("game.const.ModuleConfig")
require("game.const.PhoneInfo")
require("game.const.PlayerPowerDefine")
require("game.const.TextWordsConfig")
require("game.const.GamePowerConfig")
require("game.const.SoliderPowerDefine")
require("game.const.RewardDefine")
require("game.const.EventConfig")
require("game.const.ErrorCodeDefine")
require("game.const.GlobalConfig")
require("game.const.LayoutConfig")
require("game.const.ActivityDefine")
require("game.const.FunctionShieldConfig")

--log
require("game.log.LogUtils")
require("game.log.GuideLog")
require("game.log.KKKLog")

--texture manager
require("game.manager.TextureManager")
require("game.manager.ConfigDataManager")
require("game.manager.AudioManager")
require("game.manager.LocalDBManager")
require("game.manager.SDKManager")
require("game.manager.VersionManager")
require("game.manager.FilterWordManager")
require("game.manager.TimerManager")
require("game.manager.CountDownManager")
require("game.manager.HttpRequestManager")
require("game.manager.ModuleJumpManager")
require("game.manager.RewardManager")
require("game.manager.EffectQueueManager")
require("game.manager.FunctionWebManager")
require("game.manager.CustomHeadManager")


require("game.manager.guide.Guide")
require("game.manager.guide.GuideManager")
require("game.manager.guide.action.GuideAction")
require("game.manager.guide.action.DialogueAction")
require("game.manager.guide.action.ConditionAction")
require("game.manager.guide.action.AreaClickAction")
require("game.manager.guide.action.TaskImgAction")
require("game.manager.guide.action.AutoClickAction")
require("game.manager.guide.action.ImageAction")
require("game.manager.guide.action.PlotAction")
require("game.manager.guide.action.DialogAction")

--
--events
require("game.events.AppEvent")

--component
require("component.__init")

--net
require("game.net.SocketTransceiver")
require("game.net.NetChannel")
require("game.net.ByteArray")

--States
require("game.states.GameBaseState")
require("game.states.login.LoginState")
require("game.states.scene.SceneState")
require("game.states.update.UpdateState")
require("game.states.test.TestState")
require("game.Game")
require("game.GameLayer")


--animation
require("game.animation.base.BaseAnimation")
require("game.animation.AnimationFactory")
require("game.animation.effect.BagFreshFly")
require("game.animation.effect.CapactityAnimation")
require("game.animation.effect.GetGoodsEffect")
require("game.animation.effect.GetPropAnimation")
require("game.animation.effect.LevelUpAnimation")
require("game.animation.effect.GuideRewardEffect")

