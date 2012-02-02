p = require './password'

p.createSalt (s) ->
	console.log 'salt: ' ,s
	p.hmac s,'pw',null,(sha) ->
		console.log 'shasum: ' ,sha
