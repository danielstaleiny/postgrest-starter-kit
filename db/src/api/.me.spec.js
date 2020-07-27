const ROOT = process.cwd()
const { get, post, put, patch, del } = require(`${ROOT}/util/fetch.js`)(
  'http://localhost:3000/'
)

describe('/rpc/me', () => {
  test('success 200 POST', async () => {
    const res = await post('rpc/me')({
      withRole: { id: 1, role: 'webuser' },
    })
    expect(res).toMatchSnapshot()
  })

  test('success 200 GET', async () => {
    const res = await get('rpc/me')({
      withRole: { id: 1, role: 'webuser' },
    })
    expect(res).toMatchSnapshot()
  })

  test('fail 401', async () => {
    const res = await post('rpc/me')({})
    expect(res).toMatchSnapshot()
  })
})
