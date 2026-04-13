# Fediway

This is the Fediway fork of [Mastodon](https://github.com/mastodon/mastodon), maintained at https://github.com/fediway/mastodon.

## What this fork changes

All Fediway-specific behavior is feature-flagged so the fork can be deployed as a clean Mastodon target with every flag off.

- **`FEDIWAY_AUTH_DIRECT=true`** — enables a direct email/password login endpoint used by the Fediway web frontend. Mastodon's built-in OAuth flow is unchanged.
- **`FEDIWAY_WEB_URL=<url>`** — when set, Mastodon's React SPA routes redirect to the Fediway web frontend at this URL. The SPA serves unchanged when unset.
- **`FEDIWAY_VERSION_SUFFIX=true`** — when set, `/api/v1/instance` reports the version as `<upstream>+fediway.<our-version>` (e.g. `4.5.8+fediway.0.1.0`) for federation peers and admin tooling.

**With all three flags unset, this fork is byte-compatible with upstream Mastodon.** Upstream's RSpec and JS test suites pass unchanged.

## Branching model

- **`main`** — dev trunk. Feature PRs land here. Force-pushed during upstream rebases.
- **`release`** — production pointer. Force-updated to a `main` commit when we cut a release. Semver tags (`v0.1.0`, `v0.2.0`, …) are created from this branch and become Docker images at `ghcr.io/fediway/mastodon`.

## Streaming image

We do **not** build the streaming image. Deployments use upstream's published `ghcr.io/mastodon/mastodon-streaming:<upstream-version>` directly.

The streaming image version must match the upstream Mastodon version that our Fediway release was built on. Track this in your deploy manifest.

## Upstream sync

When upstream ships a new `v4.5.X`:

```sh
git fetch upstream --tags
git checkout main
git rebase v4.5.X
git push --force-with-lease origin main
```

When ready to ship a Fediway release built on the new upstream:

```sh
git checkout release
git reset --hard main
git push --force-with-lease origin release
git tag v0.X.Y -m 'Fediway v0.X.Y — based on Mastodon v4.5.X'
git push origin v0.X.Y
```

The release tag triggers `.github/workflows/build-releases.yml`, which builds and publishes a multi-arch Docker image to `ghcr.io/fediway/mastodon:v0.X.Y`.

## License

AGPL-3.0, inherited from upstream. See [LICENSE](LICENSE).
