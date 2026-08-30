# Configuration

The `Configuration` centralizes the application settings.

## Source

The settings are obtained directly from **environment variables**. The other
components must not access `ENV` directly.

## Variables

The required variables are `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`,
`R2_ENDPOINT` and `R2_BUCKET`.

The `R2_REGION` variable is optional and, when absent, uses the default value
`auto`, recommended for Cloudflare R2.

When a required variable is absent, the `Configuration` raises
`R2::Errors::ConfigurationError` with a message indicating the variable.

## Evolution

The source of the settings may be diversified in the future if a real need
arises.
