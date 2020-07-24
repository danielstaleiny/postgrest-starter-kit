local function before_rest_refresh_token()
  local refresh_token = ngx.header["Refresh-Token"]
  utils.set_body_postprocess_mode(utils.postprocess_modes.ALL)
  utils.set_body_postprocess_fn(function(body)
      local b = cjson.decode(body)
      b.refresh_token = refresh_token
      return cjson.encode(b)
  end)
end

before_rest_refresh_token()
