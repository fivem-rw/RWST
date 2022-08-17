local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vrp_rw_userlistS = {}
vRP = Proxy.getInterface("vRP")

local RequestGetUserList = function(response, limit)
  vRP.getUserList(
    {
      function(userList)
        local playerList = {}
        if userList then
          local cnt = 0
          for k, v in pairs(userList) do
            if cnt >= limit then
              break
            end
            table.insert(
              playerList,
              {
                source = v.source,
                id = v.user_id,
                nickname = v.nickname,
                name = v.name or "(신분증 미발급)",
                job = v.job or "(직업 미선택)",
                jobType = v.jobType,
                groups = v.groups
              }
            )
            cnt = cnt + 1
          end
        end
        response(playerList)
      end
    }
  )
end

local RequestGetUserData = function(response, userId)
  vRP.getUData(
    {
      userId,
      "vRP:datatable",
      function(data)
        response(json.decode(data))
      end
    }
  )
end

RWST:RequestEventHandler(
  function(event, response)
    if event.name == "GetUserList" then
      local limit = parseInt(event.body.limit) or 1000
      RequestGetUserList(response, limit)
    elseif event.name == "GetUserData" then
      local userId = parseInt(event.body.id)
      if userId then
        RequestGetUserData(response, userId)
      else
        response({})
      end
    elseif event.name == "Kick" then
      local userId = parseInt(event.body.id)
      if userId then
        local resData = {}
        local source = vRP.getUserSource({userId})
        local reason = "RWST Test"
        if source then
          vRP.kick({source, reason})
          resData.success = true
          resData.userId = userId
          resData.reason = reason
        else
          resData.success = false
          resData.userId = userId
        end
        response(resData)
      else
        response({})
      end
    else
      response({})
    end
  end
)
