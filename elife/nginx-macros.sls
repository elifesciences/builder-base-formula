{% macro consumer_groups_filter(users) -%}
# Authenticates the api-gateway.
# Copies a filtered version of the api-gateway X-Consumer-Groups header
# into X-Consumer-Groups-Filtered, only allowing the client to specify the
# header if it carries an Authorization header too
variables_hash_max_size 2048; # to fit this map
map_hash_bucket_size 128;
map $remote_addr/$http_authorization $consumer_groups_filtered {
    # base case: do not allow header
    default "";
    # local requests case, don't check authentication
    ~^127.0.0.1/.*$ $http_x_consumer_groups;
    {%- for i, user in users.items() -%}
    ~^.*/Basic {{ salt['hashutil.base64_b64encode'](user['username'] ~ ':' ~ user['password']) }}$ $http_x_consumer_groups;
    {% endfor -%}
}
{%- endmacro -%}
