const { fetch } = require('fetch-ponyfill')()
const jsonwebtoken = require('jsonwebtoken')
const { config } = require('dotenv')
config() // .env file vars added to process.env

// GET, POST, PUT, PATCH, DEL, RAW

// addQuery :: Object => String
const addQuery = (obj) => {
  let result = ''
  let first = true
  for (const prop in obj) {
    if (first === true) {
      result = result + genQueryFirst(prop, obj[prop])
      first = false
    } else {
      result = result + genQuery(prop, obj[prop])
    }
  }
  return result
}

// genQuery :: (String, String) => String
const genQuery = (key, value) => `&${key}=${value}`

// genQueryFirst :: (String, String) => String
const genQueryFirst = (key, value) => `?${key}=${value}`

// stringify :: Object => String
const stringify = (body) => JSON.stringify(body)

// form :: Object => FormData
const form = (form) => new FormData(form)

// raw :: ?String -> String -> Object => Promise
const raw = (method = 'GET') => (uri) => ({
  body = {},
  body_type = 'json',
  headers = {},
} = {}) => {
  const encode = body_type === 'json' ? stringify : form
  const defaultOptions = {
    // cookies sent
    // mode: 'cors', // do not use the cors because we redirect on nginx to correct end point
    // credentials: 'include', // Server doesn't like this, use of * is
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/vnd.pgrst.object+json',
      ...headers,
      // ,'X-XSRF-TOKEN': getCookieValue('XSRF-TOKEN') // this is once we have XSRF token in place
    },
  }
  const options =
    method === 'GET'
      ? defaultOptions
      : { ...defaultOptions, method: method, body: encode(body) }

  return fetch(uri, options)
}

// method = 'GET' || 'POST' || 'PUT' || 'PATCH' || 'DELETE'
// path = 'ping'
// opt ={
//        body: { name: 'example' },
//        body_type: 'form' || 'json',
//        token: 'uuid4 type'
//      }

// request :: String -> String -> String -> ?Object => Promise
const request = (domain) => (method) => (path) => (opt = {}) => {
  const { body, body_type, token, withRole, ...rest } = opt
  let options = {}
  if (body) options = { ...options, body: body }
  if (body_type) options = { ...options, body_type: body_type }
  if (token)
    options = { ...options, headers: { Authorization: `Bearer ${token}` } }
  if (withRole && withRole.role && withRole.id)
    options = {
      ...options,
      headers: {
        Authorization: `Bearer ${jsonwebtoken.sign(
          {
            user_id: withRole.id,
            role: withRole.role,

            iat: Math.floor(Date.now() / 1000) - 30, // - Pretend that the JWT was issued 30 seconds ago in the past
          },
          process.env.JWT_SECRET
        )}`,
      },
    }

  const qs = rest !== undefined ? addQuery(rest) : ''
  // localhost:3000/ + ping + ?key=value
  const uri = domain + path + qs
  return raw(method)(uri)(options).then(async (r) => ({
    status: r.status,
    statusText: r.statusText,
    body: await r.json(),
  }))
}

module.exports = (url) => ({
  // get :: String -> ?Object => Promise
  get: request(url)('GET'),
  // post :: String -> ?Object => Promise
  post: request(url)('POST'),
  // put :: String -> ?Object => Promise
  put: request(url)('PUT'),
  // patch :: String -> ?Object => Promise
  patch: request(url)('PATCH'),
  // del :: String -> ?Object => Promise
  del: request(url)('DELETE'),
  // raw :: ?String -> String -> Object => Promise
  raw,
})
