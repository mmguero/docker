const http = require('http')
const server = http.createServer((req, res) => {
	res.writeHead(200, { 'content-type': 'text/html' })

	if (req.url === '/') {
		res.write('<h1>Node.js and NGINX</h1>')
		res.end()
	} else {
		res.write('<h1>404 Not Found</h1>')
		res.end()
	}
})

server.listen(process.env.PORT || 3000, () => console.log(`server running on ${server.address().port}`))
