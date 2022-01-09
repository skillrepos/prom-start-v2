ab -c 5 -n 10000  -m PATCH -H "host:httpbin.local" -H "accept: application/json" http://localhost:30999/patch
ab -c 5 -n 10000  -m GET -H "host:httpbin.local" -H "accept: application/json" http://localhost:30999/get
ab -c 5 -n 10000  -m POST -H "host:httpbin.local" -H "accept: application/json" http://localhost:30999/post
