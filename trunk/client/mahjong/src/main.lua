
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

cc.FileUtils:getInstance():setPopupNotify(false)
package.path = package.path .. ";src/"
require("app.MyApp").new():run()
