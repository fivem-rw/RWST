-- PrintConfig
RWST:PrintConfig()

-- GetConfig
local config = RWST:GetConfig()
print(config.debug)

-- RequestEventHandler
RWST:RequestEventHandler(
  function(event, response)
    print(event.name, event.path, event.method, event.body)
    response({["test"] = "response"})
  end
)
