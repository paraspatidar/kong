FROM kong:3.9

USER root
# Install build tools, luarocks, and dependencies
RUN apt-get update && apt-get install -y \
      git \
      gcc \
      make \
      unzip \
      curl \
      libpcre3-dev \
      libssl-dev \
      luarocks \
	  redis-tools \
    && rm -rf /var/lib/apt/lists/*

    # # Point luarocks to use Kong's bundled LuaJIT (not system lua5.1)
ENV LUAJIT_INC=/usr/local/openresty/luajit/include/luajit-2.1
ENV LUAJIT_LIB=/usr/local/openresty/luajit/lib    

# COPY lua-resty-jwt-0.2.3-0.rockspec /tmp/
# RUN luarocks install /tmp/lua-resty-jwt-0.2.3-0.rockspec

# COPY lua-cjson-2.1.0.10-1.rockspec /tmp/
# RUN luarocks install /tmp/lua-cjson-2.1.0.10-1.rockspec

# COPY lua-resty-http-0.17.2-0.rockspec /tmp/
# RUN luarocks install /tmp/lua-resty-http-0.17.2-0.rockspec

#needed for redis cluster support
RUN luarocks install kong-redis-cluster
RUN luarocks install lua-resty-lock

#COPY sum.lua /usr/local/share/

COPY kong /usr/local/share/lua/5.1/kong

# # Copy custom plugin into the Kong image
# COPY kong /usr/local/share/lua/5.1/kong

# # Ensure correct permissions
# RUN chown -R kong:kong /usr/local/share/lua/5.1/kong

USER kong
