# TAI for Crystal

## Purpose

Monotonic time that never needs leapseconds

## Usage

### Time To TAI64

`your_time.to_tai64`

### Time To TAI64N

`your_time.to_tai64n`

### TAI64N to Time

`your_tai64n.to_time`

### TAI64NA to Time

`your_tai64na.to_time`

### Live self-update (non-persistent) of leapsecond data

`Time.tai_update_leap_sec_tables!`
`Time.tai_update_leap_sec_tables!("https://your.server/path/here")`

## Installation

Add to `shard.yml`

```yaml
dependencies:
  tai:
    github: steakknife/tai
    version: ~> 0.1.0
```

## Documentation

```
make doc # creates ./docs
```

## Test

```
git clone https://github.com/steakknife/tai
cd tai
make check
```

## License

MIT
