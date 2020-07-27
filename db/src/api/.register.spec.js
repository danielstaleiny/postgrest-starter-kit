const ROOT = process.cwd()
const { get, post, put, patch, del } = require(`${ROOT}/util/fetch.js`)(
  'http://localhost:3000/'
)

describe('/rpc/register', () => {
  test('Success 201', async () => {
    const res = await post('rpc/register')({
      body: {
        name: 'New user',
        email: 'test@email.com',
        password: 'pass',
      },
    })
    res.body.token = 'checked'
    res.body.refresh_token = 'checked'
    res.body.csrf = 'checked'
    expect(res).toMatchSnapshot()
  })

  test('Success 201, no csrf', async () => {
    const res = await post('rpc/register')({
      body: {
        name: 'New user2',
        email: 'test2@email.com',
        password: 'pass',
        csrf: false,
      },
    })
    res.body.token = 'checked'
    res.body.refresh_token = 'checked'
    expect(res).toMatchSnapshot()
  })
})
