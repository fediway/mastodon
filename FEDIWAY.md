# Fediway

Fork of [Mastodon](https://github.com/mastodon/mastodon), maintained at https://github.com/fediway/mastodon.

## What this fork changes

Fediway-specific behavior is feature-flagged. With every flag unset, the fork is byte-compatible with upstream Mastodon.

- **`POST /api/fediway/v1/credentials`** — first-party cookie-based login. Takes `{email, password}`, validates against Devise, applies the same user-state checks as Mastodon's web sign-in (2FA, confirmed, approved, functional), and calls `sign_in` to set the standard `_mastodon_session` cookie. Same trust model as github.com / slack.com / stripe.com web logins — the web client is treated as first-party. Returns `401 invalid_credentials` for bad email/password (no account enumeration), `403` with a specific error code for 2FA / unconfirmed / unapproved / disabled users. No env flag — the endpoint exists whenever the fork is deployed. Third-party clients should continue to use the OAuth redirect flow.
- **`FEDIWAY_DEV_CORS_ORIGINS=<origin_1>,<origin_2>,...`** — dev-only CORS exception for `POST /api/fediway/v1/credentials`. Cross-origin cookie auth requires `credentials: true` with a specific origin (never `*`), so the default CORS config can't serve it. Set this to the frontend dev origins (e.g. `http://localhost:3000`) to let the browser send the session cookie back. Leave unset in production — same-origin deployments don't need it.
- **`FEDIWAY_AUTH_DIRECT=true`** + **`FEDIWAY_AUTH_DIRECT_CLIENT_IDS=<id_1>,<id_2>,...`** — enables OAuth 2.0 password grant ([RFC 6749 §4.3](https://datatracker.ietf.org/doc/html/rfc6749#section-4.3)) on `/oauth/token`, but only for the specific first-party `client_id`s listed in the allowlist. Mistakes fail closed: if the flag is on but the allowlist is empty or missing the requesting `client_id`, password grant is rejected. Register each first-party app (web, iOS, Android) once via `POST /api/v1/apps`, copy its `client_id`, add it to the comma-separated allowlist. Third-party clients that register themselves via the same public endpoint are rejected by the allowlist and fall back to the OAuth redirect flow. 2FA users are always rejected — they use the OAuth redirect flow. Mastodon's existing OAuth code-exchange flow is unchanged whether these flags are set or not.
- **`POST /api/fediway/v1/sessions/bridge`** — additive endpoint. Takes a valid `Authorization: Bearer <token>` and creates a Devise session cookie for the same user. Lets a single Fediway-frontend login give access to both the JSON API (via the bearer token) and the server-rendered admin / settings pages (via the session cookie), without requiring a second sign-in. No env flag — the endpoint exists whenever the fork is deployed, harmless when unused.
- **`FEDIWAY_WEB_URL=<url>`** — Mastodon's React SPA routes redirect to this URL. The SPA serves unchanged when unset.

## Runtime version identification

Release images report `<upstream>+fediway.<version>` via `/api/v1/instance` (e.g. `4.5.8+fediway.0.1.0`). This uses upstream's `MASTODON_VERSION_METADATA` build arg — `build-releases.yml` derives the value from the release tag and bakes it into the image at build time. No Ruby code modifications.

For local dev, set it manually in `.env.production`:

    MASTODON_VERSION_METADATA=fediway.0.1.0

## Branching model

- **`main`** — dev trunk. Feature PRs land here. Force-pushed during upstream rebases.
- **`release`** — production pointer. Force-updated to a `main` commit when cutting a release. Semver tags (`v0.1.0`, `v0.2.0`, …) are created from this branch and become Docker images at `ghcr.io/fediway/mastodon`.

## Streaming image

We do **not** build the streaming image. Deployments use upstream's `ghcr.io/mastodon/mastodon-streaming:<upstream-version>` directly. The streaming image version must match the upstream Mastodon version the Fediway release was built on.

## Upstream sync

When upstream ships a new `v4.5.X`:

    git fetch upstream --tags
    git checkout main
    git rebase v4.5.X
    git push --force-with-lease origin main

When ready to ship a Fediway release built on the new upstream:

    git checkout release
    git reset --hard main
    git push --force-with-lease origin release
    git tag v0.X.Y -m 'Fediway v0.X.Y based on Mastodon v4.5.X'
    git push origin v0.X.Y

The release tag triggers `.github/workflows/build-releases.yml`, which publishes `ghcr.io/fediway/mastodon:v0.X.Y`.

## License

AGPL-3.0, inherited from upstream. See [LICENSE](LICENSE).
