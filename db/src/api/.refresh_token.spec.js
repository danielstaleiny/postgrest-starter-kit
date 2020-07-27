const ROOT = process.cwd()
const { get, post, put, patch, del } = require(`${ROOT}/util/fetch.js`)(
  'http://localhost:3000/'
)

describe('/rpc/refresh_token', () => {
  test('fail timed out 401 Session time out', async () => {
    const res = await post('rpc/refresh_token')({
      body: {
        refresh_token: 'de688895-6181-440f-a25a-8a9ba14b2163',
      },
    })
    expect(res).toMatchSnapshot()
  })

  test('200 get new token', async () => {
    const res = await post('rpc/refresh_token')({
      body: {
        refresh_token: 'de688895-6181-440f-a25a-8a9ba14b2164',
      },
    })
    res.body.token = 'checked'
    expect(res).toMatchSnapshot()
  })

  test('404 Session not found', async () => {
    const res = await post('rpc/refresh_token')({
      body: {
        refresh_token: 'de688895-6181-440f-a25a-000000000000',
      },
    })
    expect(res).toMatchSnapshot()
  })

  test('404 CSRF not found', async () => {
    const res = await post('rpc/refresh_token')({
      body: {
        refresh_token: 'de688895-6181-440f-a25a-8a9ba14b2164',
        csrf: 'de6888956181440fa25a000000000000',
      },
    })
    expect(res).toMatchSnapshot()
  })
})
