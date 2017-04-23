[fisherman]: https://github.com/fisherman/fisherman

# [fisherman] brew tap

[![](https://img.shields.io/badge/fisherman-2.12.0-blue.svg)](https://github.com/fisherman/fisherman/releases)
[![](https://fisherman-wharf.herokuapp.com/badge.svg)](https://fisherman-wharf.herokuapp.com)

## Usage

```shell
brew tap fisherman/tap
```

Then choose to install:

* the latest stable version of [fisherman]

  ```
  brew install fisherman
  ```

* or latest commits from the `master` branch

  ```
  brew install --HEAD fisherman
  ```

When you `brew update` this tap will be automatically updated, then you can upgrade fisherman as any other formula:

```shell
brew update
brew upgrade fisherman
```

## Maintaining

Update the two fields in [`fisherman.rb`](./fisherman.rb#L5-L6):

- the version of `fisher.fish` in the `url`
- `sha256` which can be obtained with `shasum -a 256 fisher.fish`
