# env-SetEnv

`env-SetEnv.sh` is a bash script that provides programmatic insertion of Apache `SetEnv` directives using available environment variables.

<p align="center">
    <img src="https://raw.githubusercontent.com/joehehir/depository/0de8a4d3adbb2e1b09de380d7faefcb262068948/img/env-SetEnv/demo.gif" width="513" height="424.5" />
</p>

## Usage

Multiple `SetEnv` directives (batch) can be inserted in a single pass. Each batch insertion requires a script execution and a "marker" comment. Marker comments are consumed in order of occurrence (see GIF).

Environment variables are loaded from both the current environment and, if present, the `.env` file in the current working directory.


## Syntax
```sh
./env-SetEnv.sh [var var ...] path
```

### Parameters

- **var:** `String` **| Optional**

  Space-separated list of available environment variable names to be inserted.
  
  `!important:` Omitting this parameter means that all available environment variables will be inserted.

- **path:** `String`

  Path to Apache configuration file.
  
  This configuration file must include at least one "marker" comment to determine the insertion position. The format of a marker comment is "`# !env-SetEnv.sh`". Please refer to the [examples](#examples) section for more information.

## [Examples](#examples)

#### | example.conf
```sh
Listen 80

<VirtualHost *:80>
    DocumentRoot "/www/example"
    ServerName www.example.com

    # !env-SetEnv.sh
</VirtualHost>
```

#### | <span>entrypoint.sh</span>
```sh
./env-SetEnv.sh SHELL PWD USER ./example.conf
```

#### | example.conf (post-modification)
```sh
Listen 80

<VirtualHost *:80>
    DocumentRoot "/www/example"
    ServerName www.example.com

    # env-SetEnv.sh
    SetEnv SHELL /bin/zsh
    SetEnv PWD /Users/joehehir/env-SetEnv
    SetEnv USER joehehir

</VirtualHost>
```

## Dependencies

- GNU sed (available as `sed` or `gsed`). The following error will be printed if GNU sed is not available.

  <span style="color: red">Error: GNU sed not found</span>

  ### Installation

  - macOS

    ```sh
    brew install gnu-sed
    ```
