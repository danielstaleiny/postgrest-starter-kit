create or replace function refresh_token(refresh_token text, csrf text default null, jwt_cookie boolean default false ) returns json as $$
declare
    usr record;
    ses record;
    token text;
    head text;
begin

    select * from data."session" as s
    where id = refresh_token::uuid
    into ses;


    if ses is null then
        raise exception 'Session was not found'; -- TODO check error code
    elsif (ses.exp::int < extract(epoch from now())::integer) then
        raise exception 'Session expired'; -- TODO check error code
    elsif ses.csrf != csrf then
        raise exception 'CSRF does not match'; -- TODO check error code
    else
        select * from data."user" as u
        where id = ses.user_id
        into usr;

        -- TODO maybe change this to delete, and create new refresh_token
        update data."session"
        set exp = (extract(epoch from now())::integer + settings.get('refresh_token_lifetime')::int)
        where id = ses.id;


        if jwt_cookie is true then
           head := request.header('host') || '-' ||  request.header('user-agent');
           token := pgjwt.sign(
                 json_build_object(
                    'role', usr.role,
                    'user_id', usr.id,
                    'exp', extract(epoch from now())::integer + settings.get('jwt_lifetime')::int,
                    'user-agent', head
                ),
                settings.get('jwt_secret')
            );
        else
            token := pgjwt.sign(
                        json_build_object(
                             'role', usr.role,
                             'user_id', usr.id,
                             'exp', extract(epoch from now())::integer + settings.get('jwt_lifetime')::int
                        ),
                        settings.get('jwt_secret')
                    );
        end if;
        return json_build_object('token', token);
    end if;
end
$$ volatile security definer language plpgsql;
-- by default all functions are accessible to the public, we need to remove that and define our specific access rules
revoke all privileges on function refresh_token(text, text, boolean) from public;
