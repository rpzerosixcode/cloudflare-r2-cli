# Security

The project follows the following security practices:

- **Credentials through environment variables** — access credentials and
  sensitive settings are obtained through environment variables and are not
  stored in source code or versioned files.

- **Isolated test environment** — E2E tests use a dedicated bucket
  (`R2_TEST_BUCKET`) separated from the default application bucket.

- **Ignored environment files** — `.env` files are excluded from version
  control. Only the `.env.example` template is versioned.

- **CI and secrets** — CI credentials are provided through repository secrets
  and are not exposed in workflow logs.

If an access key is accidentally exposed, revoke it immediately through the
Cloudflare dashboard and generate a new one.