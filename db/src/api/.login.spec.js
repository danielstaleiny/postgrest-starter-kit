const ROOT = process.cwd()
const resetdb = require(`${ROOT}/util/reset-db.js`)
const { get, post, put, patch, del } = require(`${ROOT}/util/fetch.js`)(
  'http://localhost:3000/'
)

describe('/rpc/login', () => {
  beforeAll(() => {
    return resetdb()
  })
  afterAll(() => {
    return resetdb()
  })

  test('success 200', async () => {
    const res = await post('rpc/login')({
      body: {
        email: 'alice@email.com',
        password: 'pass',
      },
    })
    res.body.csrf = 'checked'
    res.body.token = 'checked'
    res.body.refresh_token = 'checked'
    expect(res).toMatchSnapshot()
  })

  test('fail 404', async () => {
    const res = await post('rpc/login')({
      body: {
        email: 'random@email.com',
        password: 'nonexistent',
      },
    })
    expect(res).toMatchSnapshot()
  })
})
