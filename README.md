# proof-html

proof-html is a [GitHub Action](https://github.com/features/actions) to
validate HTML using [HTMLProofer](https://github.com/gjtorikian/html-proofer).

## Usage

```yaml
- name: Proof HTML
  uses: anishathalye/proof-html@v1
  with:
    directory: ./site
```

See below for a [full example](#full-example).

## Options

| Name | Description | Default |
| --- | --- | --- |
| `directory` | The directory to scan | **(required)** |
| `check_external_hash` | Check whether external anchors exist | true |
| `check_html` | Validate HTML | true |
| `check_img_http` | Enforce that images use HTTPS | true |
| `check_opengraph` | Check images and URLs in Open Graph metadata | true |
| `check_favicon` | Check whether favicons are valid | true |
| `empty_alt_ignore` | Allow images with empty alt tags | false |
| `enforce_https` | Require that links use HTTPS | true |
| `max_concurrency` | Maximum number of concurrent requests | 10 |
| `connect_timeout` | HTTP connection timeout | 30 |
| `timeout` | HTTP request timeout | 120 |
| `url_ignore` | Newline-separated list of URLs to ignore | (empty string) |
| `url_ignore_re` | Newline-separated list of URL regexes to ignore | (empty string) |

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
      - uses: anishathalye/proof-html@v1
        with:
          directory: ./_site
          enforce_https: false
          url_ignore: |
            http://www.example.com/
            https://en.wikipedia.org/wiki/Main_Page
          url_ignore_re: |
            ^https://twitter.com/
```

For a real-world example, see
[missing-semester/.../build.yml](https://github.com/missing-semester/missing-semester/blob/master/.github/workflows/build.yml)

## License

Copyright (c) 2020 Anish Athalye. Released under the MIT License. See
[LICENSE.md](LICENSE.md) for details.
