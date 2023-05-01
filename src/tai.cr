require "http/client"
require "uri"

struct Tai64
  getter s : UInt64

  def initialize(s : Int)
    @s = s.to_u64
  end

  def initialize(s : Tai64)
    @s = s.s
  end

  def initialize(s : Tai64n)
    @s = s.s.s
  end

  def to_time
    Time.from_tai(self)
  end
end

struct Tai64n
  getter s : Tai64
  getter ns : UInt32

  def initialize(s : Tai64)
    @s = s.s
    @ns = s.ns
  end

  def initialize(@s : Tai64, ns : Int = 0)
    @ns = ns.to_u32
  end

  def initialize(s : UInt64, ns : Int = 0)
    @s = Tai64.new(s)
    @ns = ns.to_u32
  end

  def to_time
    Time.from_tai(self)
  end
end

# struct Tai64na
#   def s
#     ns.s
#   end
# 
#   getter ns : Tai64n
#   getter attos : UInt32
# 
#   def initialize(s, ns = 0, @attos = 0)
#     @ns = Tai64n(s, ns)
#   end
# end

struct Time
  TAI_UPDATE_URL = "https://cr.yp.to/libtai/leapsecs.dat"
  
  # 1970-01-01 00:00:00 TAI
  # 1969-12-31 23:59:50 UTC
  TAI_EPOCH = 0x4000000000000000

  TAI_SANITY_CHECK = TAI_EPOCH..0x4000000200000000

  TAI_LEAP_SEC_BASE = 10 # seconds
  
  class_getter tai_from_table = [
    0x40000000586846a4_u64,
    0x4000000055932da3_u64,
    0x400000004fef9322_u64,
    0x40000000495c07a1_u64,
    0x4000000043b71ba0_u64,
    0x40000000368c101f_u64,
    0x4000000033b8489e_u64,
    0x4000000030e7241d_u64,
    0x400000002e135c9c_u64,
    0x400000002c32291b_u64,
    0x400000002a50f59a_u64,
    0x40000000277fd119_u64,
    0x40000000259e9d98_u64,
    0x4000000021dae517_u64,
    0x400000001d25ea16_u64,
    0x4000000019623195_u64,
    0x400000001780fe14_u64,
    0x40000000159fca93_u64,
    0x4000000012cea612_u64,
    0x4000000010ed7291_u64,
    0x400000000f0c3f10_u64,
    0x400000000d2b0b8f_u64,
    0x400000000b48868e_u64,
    0x400000000967530d_u64,
    0x4000000007861f8c_u64,
    0x4000000005a4ec0b_u64,
    0x4000000004b2580a_u64,
  ]
  
  class UpdateError < Exception end

  private def self.http(url : String, &)
    url = URI.parse(url)
    http = HTTP::Client.new(url)
    http.connect_timeout = 2.0
    http.dns_timeout = 2.0
    http.read_timeout = 2.0
    http.write_timeout = 2.0
    http.get(url.request_target) do |resp|
      yield resp
    end
  end
  
  def self.tai_update_leap_sec_tables!(url : String? = nil)
    new_tab = http(url || TAI_UPDATE_URL) do |resp|
      raise UpdateError.new("Invalid server response") unless resp.success?
      tab = [] of UInt64
      loop do
        x = resp.body_io.read_bytes(UInt64, IO::ByteFormat::BigEndian)
        raise UpdateError.new("Corrupt data") unless TAI_SANITY_CHECK.includes?(x)
        tab << x
      rescue IO::EOFError
        break
      end
      tab.reverse!
    end
    return if new_tab.size == @@tai_from_table.size # no need to update if hasn't changed
    raise UpdateError.new("Update table is empty") if new_tab.size.zero?
    @@tai_from_table = new_tab
    @@tai_to_table = nil # clear the memoized cache to be recomputed

  rescue Socket::Addrinfo::Error
    raise UpdateError.new("Can't resolve address of update server")

  rescue ArgumentError
    raise UpdateError.new("Bad update server URL")

  rescue IO::TimeoutError
    raise UpdateError.new("Update server timeout")

  rescue OpenSSL::SSL::Error
    raise UpdateError.new("Protocol error connecting to update server. Probably not an HTTPS server.")
  end

  protected class_getter tai_to_table : Array(Int32) do
    t = tai_from_table
    delta = TAI_EPOCH + t.size + TAI_LEAP_SEC_BASE
    t.map_with_index do |s, i|
      (s - delta + i).to_i32
    end
  end
  
  protected def self.leaps(table, value)
    sz = table.size
    offset = table.index { |limit| value > limit } || sz
    sz + TAI_LEAP_SEC_BASE - offset
  end
  
  def to_tai64 : Tai64
    s = to_unix.to_i64
    ls = self.class.leaps(self.class.tai_to_table, s)
    Tai64.new(s + ls + TAI_EPOCH)
  end

  def to_tai64n : Tai64n
    Tai64n.new(to_tai64, nanosecond)
  end

  def self.from_tai(t : Tai64)
    ls = leaps(tai_from_table, t.s)
    unix = t.s.to_i64 - TAI_EPOCH - ls
    Time.unix(unix)
  end
  
  def self.from_tai(t : Tai64n)
    ns = Time::Span.new(nanoseconds: t.ns)
    from_tai(t.s) + ns
  end
end
