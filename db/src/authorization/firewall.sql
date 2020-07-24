create or replace function firewall() returns void as $$
declare
  claim text;
  head text;
begin
  claim := current_setting('request.jwt.claim.user-agent', true);
  if claim is not null then
     head := request.header('host') || '-' ||  request.header('user-agent');
     if claim != head then
        RAISE insufficient_privilege USING
              DETAIL = 'ERROR CODE 69 firewall.sql', -- 'You changed User-Agent or Domain'
              HINT = 'Use jwt without cookies instead.';
     end if;
  end if;
end
$$ stable security definer language plpgsql;

comment on function firewall is
    'Checks User-Agent and domain, if the device is the same for security messures.';

grant execute on function firewall to anonymous;
