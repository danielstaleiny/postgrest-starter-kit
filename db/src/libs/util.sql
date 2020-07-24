drop schema if exists util cascade;
create schema util;
grant usage on schema util to public;



create or replace function util.ifnull(condition boolean, t text) returns text as $$
begin
       if condition is true then
          return t;
       else
          return NULL;
       end if;
end
$$ stable security definer language plpgsql;
