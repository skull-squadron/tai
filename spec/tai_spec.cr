require "./spec_helper"
require "../src/tai"

Spectator.describe Tai64 do

  context "#to_tai64 : Tai64" do
    it { expect(Time.utc.to_tai64).to be_a(Tai64) }
  end

  context "Time converts correctly 1" do
    let(utc) { "1992-06-02T08:06:43Z" }
    let(tai) { 0x400000002a2b2c2d_u64 }

    it { expect(Time.parse_iso8601(utc).to_tai64.s).to eq(tai) }
  end

  context "Time converts correctly 2" do
    let(utc) { "1969-12-31T23:59:49Z" }
    let(tai) { 0x3fffffffffffffff_u64 }

    it { expect(Time.parse_iso8601(utc).to_tai64.s).to eq(tai) }
  end

  context "Time converts correctly 3" do
    let(utc) { "1969-12-31T23:59:50Z" }
    let(tai) { 0x4000000000000000_u64 }

    it { expect(Time.parse_iso8601(utc).to_tai64.s).to eq(tai) }
  end

  context "Time converts correctly 4" do
    let(utc) { "1970-01-01T00:00:00Z" }
    let(tai) { 0x400000000000000a_u64 }

    it { expect(Time.parse_iso8601(utc).to_tai64.s).to eq(tai) }
  end

  context "Time converts correctly 5" do
    let(utc) { "2021-06-02T08:06:43Z" }
    let(tai) { 0x4000000060b73c38_u64 }

    it { expect(Time.parse_iso8601(utc).to_tai64.s).to eq(tai) }
  end

  context ".tai_update_leap_sec_tables!" do
    it { expect{ Time.tai_update_leap_sec_tables!("https://") }.to raise_error(Time::UpdateError) }
    it { expect{ Time.tai_update_leap_sec_tables!("https://a") }.to raise_error(Time::UpdateError) }
    it { expect{ Time.tai_update_leap_sec_tables!("https://www.google.com") }.to raise_error(Time::UpdateError) }
    it { expect{ Time.tai_update_leap_sec_tables!("https://www.google.com:80") }.to raise_error(Time::UpdateError) }
    it { expect(Time.tai_update_leap_sec_tables!).to be_nil }
    it { expect{ Time.tai_update_leap_sec_tables!("https://169.0.0.0") }.to raise_error(Time::UpdateError) }
  end
end
