create or replace function signup(name text, email text, password text,jwt_cookie boolean DEFAULT false, rt_cookie boolean DEFAULT false, csrf boolean DEFAULT true) returns json as $$
declare
    usr record;
begin
    insert into data."user" as u
    (name, email, password) values ($1, $2, $3)
    returning *
    into usr;

    return login(usr.email, password, jwt_cookie, rt_cookie, csrf);
end
$$ security definer language plpgsql;

revoke all privileges on function signup(text, text, text, boolean, boolean, boolean) from public;
