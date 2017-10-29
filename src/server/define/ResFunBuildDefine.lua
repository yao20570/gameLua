module("server", package.seeall)


ResFunBuildDefine = {}

----/*******定时器类型**************/
ResFunBuildDefine.BUILDE_TYPE_RESOUCE = 1    --;//野外建筑
ResFunBuildDefine.BUILDE_TYPE_FUNTION= 2     --;//基地建筑


ResFunBuildDefine.RESOUCETYPELIST = {1,2,3,4,5,6,7}   --;//资源建筑
ResFunBuildDefine.FUNCTIONTYPELIST = {8,9,10,11}  --;//功能建筑
ResFunBuildDefine.REMOVEBUILDLIST = {3,4,5}  --;//拆除野外铜、铁、油三类建筑时，扣除相应的繁荣度
ResFunBuildDefine.SPEEDBUILDLEVELUP = {3131,3132,3133}  --;//建筑升级加速道具
ResFunBuildDefine.BASEBUILDLIST = {1,9,10,13,14,15,16,8,7,17,11}  --;//基地建筑
ResFunBuildDefine.PRODUCTBUILD = {8,9,10,11}  --;//生产建筑


ResFunBuildDefine.BUILDE_TYPE_COMMOND = 1    --;//司令部
ResFunBuildDefine.BUILDE_TYPE_GEM_PROCESS= 2   --;//宝石加工
ResFunBuildDefine.BUILDE_TYPE_CUPROPROCESS= 3   --;//铜矿场
ResFunBuildDefine.BUILDE_TYPE_IRON_PROCESS= 4   --;//铁矿场
ResFunBuildDefine.BUILDE_TYPE_OIL_WELL= 5   --;//油井
ResFunBuildDefine.BUILDE_TYPE_SI_PROCESS = 6   --;//硅矿场
ResFunBuildDefine.BUILDE_TYPE_DEPOT = 7   --;//仓库
ResFunBuildDefine.BUILDE_TYPE_SCIENCE =8   --;//科技馆
ResFunBuildDefine.BUILDE_TYPE_TANK= 9   --;//战车工厂
ResFunBuildDefine.BUILDE_TYPE_RREFIT= 10   --;//改装工厂
ResFunBuildDefine.BUILDE_TYPE_CREATEROOM = 11   --;//制造车间

--*******等*待*队*列*初始值****
ResFunBuildDefine.MIN_WAITQUEUE = 1

--/***************建筑升级返还比例***********/
ResFunBuildDefine.CANCEL_LEVEL_RETURN = 70;

ResFunBuildDefine.MIN_BUILD_SIZE = 2 --; //初始建筑位2
ResFunBuildDefine.MIN_BUY_BUILD_GOlD = 30 --; //初始建筑位2时，购买第三个建筑位需30金币,之后递增30，
ResFunBuildDefine.BUY_BUILD_SIZE_GOLD = 120  --; //购买建筑位花费金币120


ResFunBuildDefine.SODIER_CREATE_MAX_NUM = 100