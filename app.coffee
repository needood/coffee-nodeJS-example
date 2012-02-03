connect = require 'connect'
io = require 'socket.io'
RedisStore = require('connect-redis') connect
fs = require 'fs'
sio = require './socket.io-session'



sesStore = new RedisStore

config = 
	sessionMaxAge : 1296000000

app = connect()
app.use connect.cookieParser()
app.use connect.favicon()
app.use connect.session
	secret:'pokerface'
	store:sesStore
	cookie:
		maxAge:config.sessionMaxAge
app.use '/auth' , (req,res,next) ->
	res.end('auth')
app.use (req,res,next) ->
	sess = req.session
	if sess._touch is true
		sess.reload () ->
	else
		sess._touch = true
	next()
app.use (req,res,next) ->
	fs.readFile __dirname + '/chat.html' , (err,data) ->
		res.setHeader 'Content-Type', 'text/html'
		res.write data
		res.end()

app.listen 8082

socket = io.listen app

chat = socket.of('/chat').on 'connection' , (cli) ->
	cli.on 'message' , (m)->
		cli.get 'nickname' , (err,name) ->
			cli.get 'room' , (err,prevroom) ->
				chat.in(prevroom).send name + ': ' + m if prevroom isnt undefined
	cli.on 'switchroom', (room)->
		console.log 'switchroom' , room
		cli.get 'room' , (err,prevroom) ->
			cli.leave prevroom if prevroom isnt undefined
			cli.join room
			cli.set 'room' , room

socket.sockets.on 'connection' , (cli) ->
	sio cli , sesStore , (sid , sess) ->
		console.log 'session: ' , sess , 'sid: ' , sid
		if sess.nickname is undefined
			cli.emit 'getname'
		else
			cli.set 'nickname',decodeURI sess.nickname
		cli.on 'setname' , (m)->
			cli.set 'nickname' , m
			sess.nickname = encodeURI m
			sesStore.set(sid, sess)
		cli.on 'disconnect', (m) ->
			cli.get 'nickname' , (err,name) ->
				sess.nickname = encodeURI name
				sesStore.set sid , sess

