const ROOT = process.cwd()
const resetdb = require(`${ROOT}/util/reset-db.js`)
const { get, post, put, patch, del } = require(`${ROOT}/util/fetch.js`)(
  'http://localhost:3000/'
)

describe('/rpc/logout', () => {
  test('success 200 without refresh_token', async () => {
    const res = await post('rpc/logout')({
      withRole: { id: 1, role: 'webuser' },
    })
    expect(res).toMatchSnapshot()
  })

  test('success 200 with refresh_token', async () => {
    const res = await post('rpc/logout')({
      withRole: { id: 1, role: 'webuser' },
      body: {
        refresh_token: 'de688895-6181-440f-a25a-8a9ba14b2162',
      },
    })
    expect(res).toMatchSnapshot()
  })

  test('success 200 with refresh_token which is not in db', async () => {
    const res = await post('rpc/logout')({
      withRole: { id: 1, role: 'webuser' },
      body: {
        refresh_token: 'de688895-6181-440f-a25a-000000000000',
      },
    })
    expect(res).toMatchSnapshot()
  })
})
