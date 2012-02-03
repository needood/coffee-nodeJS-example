connect = require 'connect'
socketwithsession = (cli , store , func , func2 = (e) -> ) ->
	cookies = cli.manager.handshaken[cli.id].headers.cookie
	return func2(cli) if cookies is undefined
	parsed_cookies = connect.utils.parseCookie cookies
	connect_sid = parsed_cookies['connect.sid']
	if connect_sid
		store.get connect_sid , (error,session) ->
			func connect_sid , session
	else
		func2(cli)


exports = module.exports = socketwithsession
