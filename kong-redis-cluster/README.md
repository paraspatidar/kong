# Kong OSS with Sample Redis cluster plugin 

### The Problem

The default kong OSS’s rate limiting and bundle comes with [open restly redis client](https://github.com/openresty/lua-resty-redis) , which as of today date [doesn't support](https://github.com/openresty/lua-resty-redis/issues/43) redis cluster.

Thus , if want to connect to redis which is in cluster mode , then we can not use that [lua-resty-redis](https://github.com/openresty/lua-resty-redis) client.

=============

### The Solutions :

1.  There was a package effort made by [https://github.com/steve0511/resty-redis-cluster](https://github.com/steve0511/resty-redis-cluster) for initial reference.
2.  Then after that , various developers forked it and created their own improved libraries.
3.  KongHowever , in this post , we shall use the one which comes from house of Kong itself as its in their github repo and so far well maintained , ref : [https://github.com/Kong/resty-redis-cluster](https://github.com/Kong/resty-redis-cluster)

=============

### High Level Approach :

1.  Install required luarocks to get the library. (preferably in Kong docker image itself and create our own custom image out of it)
2.  Install redis tool also in Kong image, to verify connectivity.
3.  Modify Kong deployment to inject required dictionary dependency in nginx config.
4.  Run redis cluster locally in docker.
5.  Write a sample plugin which uses this library and connect to redis cluster in docker to SET-GET values.
6.  Spin-up : redis cluster + Kong with this plugin + sample API
7. Register a sample api in kong.
8. Register the redis plugin  in kong.
9.  Make some test API calls to verify redis SET & GET.

=============

### GitHub Repo with Instructions :
*Below files are windows compatible.*
*feel free to replace .sh (powershell) scripts to shell if needed and make file path to line based paths*

1. Cd to the folder where **Make** file is present.
2. Run `make help` to find available options.
3. To buils image and setup everything in one click,just go to powershell and run `make all`
4. This will setup everything as per above steps.
5. **Test SET** :  Run a test api call from any http client or ui and pass required header as `action:set` ,`key:abc` , `value:xyz` , here we are instruction to SET in redis with KEY as `abc` and setting its VALUE as `xyz`. On success the response should contain a header `x-res` with value as `success`.
6. If above response header is not present  , then refer to setup container logs or kong logs.
7. **Test GET** :Run a test api call from any http client or ui and pass required header as `action:get` ,`key:abc`, here we are instruction to GET in redis with KEY as `abc` this will fetch the previously set  VALUE `xyz`. On success the response should contain a header `x-res` with value as `xyz`.

=============

#### Sample Images :
**Setting value**
  

![SET redis key](https://raw.githubusercontent.com/paraspatidar/kong/refs/heads/main/kong-redis-cluster/set-redis-key.png)


**Getting value**

![GET the value of key form redis](https://raw.githubusercontent.com/paraspatidar/kong/refs/heads/main/kong-redis-cluster/get-redis-key.png)

=============

#### References :

[https://github.com/Kong/resty-redis-cluster/tree/master?tab=readme-ov-file](https://github.com/Kong/resty-redis-cluster/tree/master?tab=readme-ov-file)

[https://github.com/dream11/kong-scalable-rate-limiter/tree/master](https://github.com/dream11/kong-scalable-rate-limiter/tree/master)


## License

This project is **dual-licensed**:

- ✅ **Free under the MIT License** for:
  - Personal use
  - Educational use
  - Non-commercial open-source projects

- 💼 **Commercial use requires a one-time paid license.**

Commercial use includes:
- SaaS products
- Enterprise software
- Internal corporate tools
- Paid APIs or platforms

📧 For commercial licensing, contact: paraspatidar.com
