drop schema if exists request cascade;
create schema request;
grant usage on schema request to public;

create or replace function request.env_var(v text) returns text as $$
    select current_setting(v, true);
$$ stable language sql;

create or replace function request.jwt_claim(c text) returns text as $$
    select request.env_var('request.jwt.claim.' || c);
$$ stable language sql;

create or replace function request.cookie(c text) returns text as $$
    select request.env_var('request.cookie.' || c);
$$ stable language sql;

create or replace function request.header(h text) returns text as $$
    select coalesce(request.env_var('request.header.' || h),'');
$$ stable language sql;


create or replace function request.user_id() returns int as $$
    select
    case coalesce(request.jwt_claim('user_id'),'')
    when '' then 0
    else request.jwt_claim('user_id')::int
	end
$$ stable language sql;

create or replace function request.user_role() returns text as $$
    select request.jwt_claim('role')::text;
$$ stable language sql;



drop schema if exists response cascade;
create schema response;
grant usage on schema response to public;


-- you can add Secure; flag to cookie, but then it doesn't work in development. Test how it is with postgrest which is http
-- you can specify domain, this really depends on your use case Domain=domain.com
-- you can also specify flag SameSite=Strict -> only matching domain
-- you can also specify flag SameSite=Lax -> would match also yourdomain.com.malicious.com
-- you can also specify flag SameSite=None
create or replace function response.get_cookie_string(name text, value text, expires_after int, path text) returns text as $$
    with vars as (
        select
            case
                when expires_after > 0 
                then current_timestamp + (expires_after::text||' seconds')::interval
                else timestamp 'epoch'
            end as expires_on
    )
    select 
        name ||'=' || value || '; ' ||
        'Expires=' || to_char(expires_on, 'Dy, DD Mon YYYY HH24:MI:SS GMT') || '; ' ||
        'Max-Age=' || expires_after::text || '; ' ||
        'Path=' ||path|| '; SameSite=Strict; HttpOnly'
    from vars;
$$ stable language sql;

create or replace function response.set_header(name text, value text) returns void as $$
    select set_config(
        'response.headers', 
        jsonb_insert(
            (case coalesce(current_setting('response.headers',true),'')
            when '' then '[]'
            else current_setting('response.headers')
            end)::jsonb,
            '{0}'::text[], 
            jsonb_build_object(name, value))::text, 
        true
    );
$$ stable language sql;

create or replace function response.set_cookie(name text, value text, expires_after int, path text) returns void as $$
    select response.set_header('Set-Cookie', response.get_cookie_string(name, value, expires_after, path));
$$ stable language sql;

create or replace function response.delete_cookie(name text) returns void as $$
    select response.set_header('Set-Cookie', response.get_cookie_string(name, 'deleted', 0 ,'/'));
$$ stable language sql;
