

local log_custom = require("framework.log.logging.custom")
logger = log_custom()

logger.track = function()
	--logger.error(debug.track())
end



----    logger:setLevel("ERROR")
--
--logger:info("----createSpaceMap----")
--logger:debug("val1='%s', val2=%d", "string value", 1234)
--logger:error({1,2,3})
--logger:debug("string with %4")

--logger.info = function() end
--logger.error = function() end