This app is a sample that uses [wasabi](https://github.com/sinsoku/wasabi) which is a Rust-based Ruby extension.

# Build a docker image

```
$ docker build -t rusty_rails .
```

# Usage

```
$ docker run --rm --env SECRET_KEY_BASE=dummy rusty_rails bin/rails r 'pp Wasabi.sum(1, 2)'
3
$ docker run --rm --env SECRET_KEY_BASE=dummy rusty_rails bin/rails r 'pp Wasabi.call_to_s(1)'
"1"
```
