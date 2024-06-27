# Next.js

## env vcs handling

- .env, .env.development, .env.production, はリポジトリに含める。
- .env*.local はリポジトリに含めない。secret な情報を格納する。
- .env*.local は常にデフォルト設定を上書きする。

- refs

    - [Configuring: Environment Variables | Next.js](https://nextjs.org/docs/pages/building-your-application/configuring/environment-variables#default-environment-variables)

        > Good to know: .env, .env.development, and .env.production files
        > should be included in your repository as they define defaults.
        > .env*. local should be added to .gitignore,
        > as those files are intended to be ignored.
        > .env.local is where secrets can be stored.

## expande $ vairable

- `$` で変数展開できる

    ```.env
    TWITTER_USER=nextjs
    TWITTER_URL=https://twitter.com/$TWITTER_USER
    ```

## .env behavior

- 以下順で見つかったもの先勝ちで使われる。

    - process.env
    - .env.$(NODE_ENV).local
    - .env.local(NODE_ENVがtestの場合はチェックされない)
    - .env.$(NODE_ENV)
    - .env

- refs

    - [Configuring: Environment Variables | Next.js](https://nextjs.org/docs/pages/building-your-application/configuring/environment-variables#default-environment-variables)

        > In general only one .env.local file is needed.
        > However, sometimes you might want to add some defaults
        > for the development (next dev) or production (next start) environment.
        > Next.js allows you to set defaults in .env (all environments),
        > .env.development (development environment), and
        > .env.production (production environment).
        > .env.local always overrides the defaults set.

## Expose environment variables to the browser

- Use `NEXT_PUBLIC_` prefix to expose environment variables to the browser.

- refs
    - [Configuring: Environment Variables | Next.js](https://nextjs.org/docs/pages/building-your-application/configuring/environment-variables#bundling-environment-variables-for-the-browser)

        > Bundling Environment Variables for the Browser
        > Non-NEXT_PUBLIC_ environment variables are only available in the Node.js environment,
        > meaning they aren't accessible to the browser (the client runs in a different environment).
