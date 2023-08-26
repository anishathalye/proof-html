# proof-html

proof-html is a [GitHub Action](https://github.com/features/actions) to validate HTML and CSS using the [Nu HTML Validator](https://github.com/validator/validator) and check links, images, and more using [HTMLProofer](https://github.com/gjtorikian/html-proofer).

## Usage

```yaml
- uses: anishathalye/proof-html@v2
  with:
    directory: ./site
```

See below for a [full example](#full-example).

## Options

| Name | Description | Default |
| --- | --- | --- |
| `directory` | The directory to scan | **(required)** |
| `check_external_hash` | Check whether external anchors exist | true |
| `check_favicon` | Check whether favicons are valid | true |
| `check_html` | Validate HTML | true |
| `check_css` | Validate CSS | true |
| `check_opengraph` | Check images and URLs in Open Graph metadata | true |
| `ignore_empty_alt` | Allow images with empty alt tags | false |
| `ignore_missing_alt` | Allow images with missing alt tags | false |
| `allow_missing_href` | Allow anchors with missing href tags | false |
| `enforce_https` | Require that links use HTTPS | true |
| `swap_urls` | JSON-encoded map of URL rewrite rules | (empty) |
| `ignore_url` | Newline-separated list of URLs to ignore | (empty) |
| `ignore_url_re` | Newline-separated list of URL regexes to ignore | (empty) |
| `connect_timeout` | HTTP connection timeout | 30 |
| `tokens` | JSON-encoded map of domains to authorization tokens | (empty) |
| `max_concurrency` | Maximum number of concurrent requests | 50 |
| `timeout` | HTTP request timeout | 120 |
| `retries` | Number of times to retry checking links | 3 |

Most of the options correspond directly to [configuration options for
HTMLProofer](https://github.com/gjtorikian/html-proofer#configuration).

**tokens**

`tokens` is a _JSON-encoded_ map of domains to authorization tokens. So it's
"doubly encoded": the workflow file is written in YAML and `tokens` is a string
(not a map!), a JSON encoding of the data. This option can be used to provide
bearer tokens to use in certain scenarios, which is useful for e.g. avoiding
rate limiting. Tokens are only sent to the specified websites. Note that
domains must not have a trailing slash. Here is an example of an encoding of
tokens:

```yaml
tokens: |
  {"https://github.com": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
   "https://twitter.com": "yyyyyyyyyyyyyyyyyyyyyyy"}
```

You can also see the full example below for how to pass on the `GITHUB_TOKEN`
supplied by the workflow runner.

**swap_urls**

`swap_urls` is a _JSON-encoded_ map, mapping regexes to strings. This can be
useful to strip a base path for an internal domain. For example:

```yaml
swap_urls: |
  {"^https://example.com/": "/"}
```

You can also use capture groups and back-references here. For example, to
ignore checking hashes for GitHub URLs (like
`https://github.com/anishathalye/proof-html#options`), you can use:

```yaml
swap_urls: |
  {"^(https://github.com/.*)#.*$": "\\1"}
```

## Full Example

This is the entire `.github/workflows/build.yml` file for a GitHub Pages /
[Jekyll](https://jekyllrb.com/docs/github-pages/) site.

```yaml
name: CI
on:
  push:
  schedule:
    - cron: '0 8 * * 6'
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-ruby@v1
        with:
          ruby-version: 2.7.x
      - uses: actions/cache@v2
        with:
          path: vendor/bundle
          key: ${{ runner.os }}-gems-${{ hashFiles('**/Gemfile.lock') }}
          restore-keys: |
            ${{ runner.os }}-gems-
      - run: |
          bundle config path vendor/bundle
          bundle install --jobs 4 --retry 3
      - run: bundle exec jekyll build
      - uses: anishathalye/proof-html@v2
        with:
          directory: ./_site
          enforce_https: false
          tokens: |
            {"https://github.com": "${{ secrets.GITHUB_TOKEN }}"}
          ignore_url: |
            http://www.example.com/
            https://en.wikipedia.org/wiki/Main_Page
          ignore_url_re: |
            ^https://twitter.com/
          swap_urls: |
            {"^https://www.anishathalye.com/": "/"}
```

### Real-world examples

- [missing-semester/.../links.yml](https://github.com/missing-semester/missing-semester/blob/master/.github/workflows/links.yml)
- [dotfiles.github.com/.../build.yml](https://github.com/dotfiles/dotfiles.github.com/blob/master/.github/workflows/build.yml)

## Running locally

You can build the Docker container locally with `docker build . -t proof-html`.

The GitHub Action is set up to pass arguments as strings through environment
variables, where an argument like `ignore_url` is passed as `INPUT_IGNORE_URL`
(capitalize and prepend `INPUT_`) to the Docker container, so you will need to
do this translation yourself if you're running the Docker container locally.
You can mount a local directory in the Docker container with the `-v` argument
and pass the directory name as the `INPUT_DIRECTORY` argument. For example, if
you compiled a site into the `build` directory, you can run:

```bash
docker run --rm \
    -e INPUT_DIRECTORY=build \
    -v "${PWD}/build:/build" \
    proof-html:latest
```

You can pass additional arguments as additional environment variables, e.g.
`-e INPUT_FORCE_HTTPS=0` or
`-e INPUT_TOKENS='{"https://github.com": "your-token-here"}'`.

## License

Copyright (c) Anish Athalye. Released under the MIT License. See
[LICENSE.md](LICENSE.md) for details.
