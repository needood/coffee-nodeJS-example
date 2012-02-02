connect = require 'connect'
socketwithsession = (cli , store , func) ->
	cookies = cli.manager.handshaken[cli.id].headers.cookie
	parsed_cookies = connect.utils.parseCookie cookies
	connect_sid = parsed_cookies['connect.sid']
	if connect_sid
		store.get connect_sid , (error,session) ->
			func connect_sid , session
	else
		func null , null


exports = module.exports = socketwithsession
