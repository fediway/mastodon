# Fediway

Fork of [Mastodon](https://github.com/mastodon/mastodon), maintained at https://github.com/fediway/mastodon.

## What this fork changes

Fediway-specific behavior is feature-flagged. With every flag unset, the fork is byte-compatible with upstream Mastodon.

- **`FEDIWAY_AUTH_DIRECT=true`** — enables OAuth 2.0 password grant ([RFC 6749 §4.3](https://datatracker.ietf.org/doc/html/rfc6749#section-4.3)) on the existing `/oauth/token` endpoint. POST `{grant_type: password, username, password, client_id, scope}` returns a bearer token without the OAuth redirect dance. 2FA users are rejected — the redirect-based flow remains the path for them. Mastodon's existing OAuth code-exchange flow is unchanged whether the flag is set or not.
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
