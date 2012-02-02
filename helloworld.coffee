connect = require 'connect'
io = require 'socket.io'
RedisStore = require('connect-redis') connect
fs = require 'fs'
sio = require './socket.io-session'

store = new RedisStore

app = connect()
app.use connect.cookieParser()
app.use connect.session
	secret:'pokerface'
	store:store
	cookie:
		maxAge:60000
app.use '/auth' , (req,res,next) ->
	res.end('auth')
app.use (req,res,next) ->
	sess = req.session
	if sess.touch is true
		req.session.reload ()->
	else
		sess.touch = true
	next()
app.use (req,res,next) ->
	fs.readFile __dirname + '/helloworld.html' , (err,data) ->
		res.setHeader 'Content-Type', 'text/html'
		res.write data
		res.end()

app.listen 8081
###
socket = sio.enable
	socket : io.listen app
	store : store
	parser : connect.cookieParser()
	per_message: true
###

socket = io.listen app


chat = socket
	.of('/chat')
	.on 'connection', (cli) ->
		sio cli , store , (sid , sess) ->
			console.log 'session:' , sess
			if sess.username is undefined
				cli.emit('getname')
			cli.on 'setname' , (m)->
				sess.username = m
				store.set(sid, sess)
			cli.on 'message' , (m)->
				console.log m
				chat.send sess.username + ': ' + m
				


