# RWST

```v1.1.0```

<br>

## 업데이트 v.1.1.0
- 크로스도메인 지원 (server.crossDomain 설정 참조)
- 웹소켓 지원

<br>

## 소개

RWST는 FiveM서버에서 외부와의 양방향 통신을 위한 리얼월드 웹 인터페이스 입니다.<br>
HTTP GET, Websocket 으로 FiveM 서버와 양방향으로 통신할 수 있습니다.

<br>

## 사용 사례
1. 서버 웹 API 를 제작할 수 있습니다.
2. FiveM의 실시간 채팅을 웹 또는 디스코드로 출력할 수 있습니다.
3. 웹 엔드포인트 또는 웹 소켓을 통하여 실시간으로 서버의 데이터를 업데이트 할 수 있습니다.
4. 서버 웹 관리 페이지를 제작할 수 있습니다.
5. 기타 등등..

<br>

## HTTP GET 예제
현재 온라인 상태인 리얼월드 VRP 에 적용된 RWST 입니다.<br>
첨부한 RWST-VRPExample 리소스가 그대로 적용되었습니다. 아래의 URL로 요청하여 테스트 할 수 있습니다.

- 현재 접속자 목록
```
GET https://rwst.realw.kr/api/GetUserList
```

- 사용자 데이터
```
GET https://rwst.realw.kr/api/GetUserData?id=[고유번호]
```

- 사용자 킥
```
GET https://rwst.realw.kr/api/Kick?id=[고유번호]
```

- config.json 설정
```json
{
  "debug": true,
  "server": {
    "endpoint": "/api"
  },
  "requests": [
    {
      "name": "GetUserList",
      "path": "/GetUserList",
      "methods": ["GET"]
    },
    {
      "name": "GetUserData",
      "path": "/GetUserData",
      "methods": ["GET"]
    },
    {
      "name": "Kick",
      "path": "/Kick",
      "methods": ["GET"]
    }
  ]
}
```

<br>

## 사용 방법
1. RWST 리소스를 다운받고 `config.example.json` 파일명을 `config.json` 으로 변경합니다.
2. `config.json` 파일의 값을 적절히 변경한 후 `ensure RWST` 명령으로 리소스를 실행합니다.
3. RWST 를 사용할 리소스의 서버 스크립트에 lib/RWST.lua 파일을 추가합니다. (RWST-LuaExample 참조)
4. 리소스에서 아래와 같이 RWST 이벤트를 구독합니다.

```lua
RWST:RequestEventHandler(
  function(event, response)
    -- event.name: requests[].name 에 설정한 식별자입니다.
    -- event.path: requests[].path 에 설정한 경로입니다.
    -- event.method: 해당 URL을 요청한 방식입니다.
    -- event.body: 요청시 파라메터 입니다.
    print(event.name, event.path, event.method, event.body)
    
    -- function(string || object)
    -- 해당 이벤트를 요청한 URL의 응답으로 보낼 데이터를 입력합니다.
    response({["test"] = "response"})
  end
)
```

5. 설정파일의 requests[] 에서 설정한 경로 요청시 위의 이벤트를 수신할 수 있습니다.

- 요청 예시
```js
GET http://서버IP/[server.endpoint][requests[].path]
```

- 응답 예시

```json
{
  "success": true,
  "event": "request",
  "response": {
    "test": "response"
  }
}
```
<br>

## 웹소켓 

- 웹소켓은 socket.io 클라이언트를 이용하여 서버에 연결할 수 있습니다.
- socket.io 버전 v4 이상

### 웹소켓 RWST LUA 함수

- 현재 연결된 클라이언트를 표시합니다.
```js
RWST:WSGetConnectors(): string[]
```

- 클라이언트의 메세지를 수신 합니다.
```js
RWST:WSReceive(callback: function): void
```

(예시)
```js
RWST:WSReceive(
  function(name, data, event)
    -- name: 메세지 이름
    -- data: 메세지 데이터
    -- event.id: 클라이언트 연결 id
    -- event.send(name, ...args): 메세지를 보낸 클라이언트에게 메세지를 전송합니다. (응답)
  end
)
```

- 연결된 특정 클라이언트에게 메세지를 전송합니다.
```js
RWST:WSSend(id: string, name: string, ...args: any): void
```

- 연결된 모든 클라이언트에게 메세지를 전송합니다.
```js
RWST:WSBroadcast(name: string, ...args: any): void
```

<br>

## 엔드포인트 보안
엔드포인트는 공개적으로 노출될 수 있으므로 제3자가 서버에 승인되지 않은 요청을 보낼 수 있습니다.<br>
이를 방지 하기 위해 `config.json` 에서 `server.secretKey` 보안키를 설정하는 것을 권장합니다.<br>
보안키가 설정되면 엔드포인트 요청시 서버는 HTTP 헤더 `X-RWST-Credential` 와 보안키가 일치하지 않는 모든 요청을 거부합니다.

### 웹소켓 보안
보안키가 설정 됬을 경우 웹소켓은 클라이언트에서 socket.io 연결시 옵션 항목에 `query.secretKey` 로 설정한 보안키가 전송되어야만 합니다. 해당 보안키가 일치하지 않을 경우 서버는 해당 클라이언트의 연결을 거부합니다.

<br>

## 설정 (config.json)
<table>
<tr>
<td>값이름</td>
<td>타입</td>
<td>기본값</td>
<td>설명</td>
</tr>
  <tr>
    <td>debug</td>
    <td>BOOLEAN</td>
    <td>false</td>
    <td>디버깅 로그 정보를 콘솔에 출력합니다.</td>
  </tr>
  <tr>
    <td>server.endpoint</td>
    <td>STRING</td>
    <td>""</td>
    <td>엔드포인트의 루트 경로를 설정합니다.</td>
  </tr>
  <tr>
    <td>server.port</td>
    <td>INT</td>
    <td>30300</td>
    <td>엔드포인트의 포트를 설정합니다.</td>
  </tr>
  <tr>
    <td>server.secretKey</td>
    <td>STRING</td>
    <td>""</td>
    <td>엔드포인트의 보안을 위한 비밀키를 설정합니다.<br>설정시 X-RWST-Credential 헤더로 해당 비밀키를 전송해야만 접근할 수 있습니다.</td>
  </tr>
  <tr>
    <td>server.responseTimeout</td>
    <td>INT</td>
    <td>5000</td>
    <td>웹에서 요청 후 서버에서 응답이 없을 경우 지정한 시간 후 자동으로 응답됩니다.</td>
  </tr>
  <tr>
    <td>server.websocket</td>
    <td>BOOLEAN</td>
    <td>false</td>
    <td>웹소켓을 활성화합니다.</td>
  </tr>
  <tr>
    <td>server.websocketPort</td>
    <td>INT</td>
    <td>30301</td>
    <td>웹소켓의 포트를 지정합니다.</td>
  </tr>
  <tr>
    <td>server.crossDomain</td>
    <td>BOOLEAN</td>
    <td>false</td>
    <td>웹 접근시 크로스도메인을 허용합니다.</td>
  </tr>
  <tr>
    <td>requests</td>
    <td>ARRAY</td>
    <td>[]</td>
    <td>요청할 경로를 설정합니다.</td>
  </tr>
  <tr>
    <td>requests[].name</td>
    <td>STRING</td>
    <td>--</td>
    <td>경로의 식별자(이름)입니다.</td>
  </tr>
  <tr>
    <td>requests[].path</td>
    <td>STRING</td>
    <td>--</td>
    <td>경로의 주소입니다.</td>
  </tr>
  <tr>
    <td>requests[].methods</td>
    <td>ARRAY</td>
    <td>--</td>
    <td>경로의 요청 방법을 지정합니다. (GET: HTTP_GET, WS: Websocket)</td>
  </tr>
  <tr>
    <td>requests[].allowWeb</td>
    <td>BOOLEAN</td>
    <td>true</td>
    <td>웹 접근을 허용합니다.</td>
  </tr>
  <tr>
    <td>requests[].allowWebsocket</td>
    <td>BOOLEAN</td>
    <td>true</td>
    <td>웹소켓에서의 접근을 허용합니다.</td>
  </tr>
</table>

- 설정 예시
```json
{
  "debug": true,
  "server": {
    "endpoint": "/api",
    "port": 30300,
    "secretKey": "test123"
  },
  "requests": [
    {
      "name": "test",
      "path": "/test",
      "methods": ["GET"],
      "allowWeb": true,
      "allowWebsocket": true
    }
  ]
}
```
<br>

- `requests[]` 에 동일한 식별자 존재할 경우 앞의 설정된 값은 무시됩니다.
- `requests[]` 에 `/` 경로는 기본 `index` 식별자로 아래와 같이 설정되어 있습니다. 해당 값을 변경하려면 `index` 식별자를 추가하여 재 정의 바랍니다.

```json
{
  "name": "index",
  "path": "/",
  "methods": ["GET"],
  "allowWeb": true,
  "allowWebsocket": false,
}
```
