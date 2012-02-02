crypto = require 'crypto'
s4 = () ->
	(((1 + Math.random()) * 0x10000) | 0).toString(16).substring 1

salt = (func = (s) -> ) ->
	s = crypto.createHash('md5').update(s4()).digest 'base64'
	func s
	s

shasum = (salt,pw,a = 'sha512',func = (s) -> ) ->
	s = crypto.createHmac(a , salt).update(pw).digest 'base64'
	func s
	s

password =
	createSalt : salt
	hmac : shasum


exports = module.exports = password


