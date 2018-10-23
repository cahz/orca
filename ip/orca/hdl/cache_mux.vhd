library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.rv_components.all;
use work.utils.all;
use work.constants_pkg.all;

--This OIMM Mux can be configured with or without multiple read support.  If
--MAX_OUTSTANDING_READS is 1, then it is the responsibility of the requester to
--not issue a read request while a current read request is pending but the
--readdatavalid signal has not been asserted.  If turned on then the
--MAX_OUTSTANDING_READS generic sets the number of outstanding reads that can
--be in flight on any one interface; all reads on one interface must finish
--before reads on another interface can start.  MAX_OUTSTANDING_READS should be
--set to a power of 2 minus 1 (1,3,7,15,etc.) normally as numbers between those
--will use the same amount of resources as the next highest power of 2 minus 1.

entity cache_mux is
  generic (
    ADDRESS_WIDTH : positive;
    DATA_WIDTH    : positive;

    MAX_OUTSTANDING_READS : positive;

    AUX_MEMORY_REGIONS : natural range 0 to 4;
    AMR0_ADDR_BASE     : std_logic_vector(31 downto 0);
    AMR0_ADDR_LAST     : std_logic_vector(31 downto 0);

    UC_MEMORY_REGIONS : natural range 0 to 4;
    UMR0_ADDR_BASE    : std_logic_vector(31 downto 0);
    UMR0_ADDR_LAST    : std_logic_vector(31 downto 0);

    CACHE_SIZE      : natural;
    CACHE_LINE_SIZE : positive range 16 to 256;

    INTERNAL_REQUEST_REGISTER : request_register_type;
    INTERNAL_RETURN_REGISTER  : boolean;
    UC_REQUEST_REGISTER       : request_register_type;
    UC_RETURN_REGISTER        : boolean;
    AUX_REQUEST_REGISTER      : request_register_type;
    AUX_RETURN_REGISTER       : boolean
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    amr_base_addrs : in std_logic_vector((imax(AUX_MEMORY_REGIONS, 1)*ADDRESS_WIDTH)-1 downto 0);
    amr_last_addrs : in std_logic_vector((imax(AUX_MEMORY_REGIONS, 1)*ADDRESS_WIDTH)-1 downto 0);
    umr_base_addrs : in std_logic_vector((imax(UC_MEMORY_REGIONS, 1)*ADDRESS_WIDTH)-1 downto 0);
    umr_last_addrs : in std_logic_vector((imax(UC_MEMORY_REGIONS, 1)*ADDRESS_WIDTH)-1 downto 0);

    internal_register_idle  : out std_logic;
    external_registers_idle : out std_logic;

    --ORCA-internal memory-mapped slave
    oimm_address       : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    oimm_byteenable    : in  std_logic_vector((DATA_WIDTH/8)-1 downto 0) := (others => '1');
    oimm_requestvalid  : in  std_logic;
    oimm_readnotwrite  : in  std_logic                                   := '1';
    oimm_writedata     : in  std_logic_vector(DATA_WIDTH-1 downto 0)     := (others => '-');
    oimm_readdata      : out std_logic_vector(DATA_WIDTH-1 downto 0);
    oimm_readdatavalid : out std_logic;
    oimm_waitrequest   : out std_logic;

    --Cache interface ORCA-internal memory-mapped master
    cacheint_oimm_address       : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    cacheint_oimm_byteenable    : out std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    cacheint_oimm_requestvalid  : out std_logic;
    cacheint_oimm_readnotwrite  : out std_logic;
    cacheint_oimm_writedata     : out std_logic_vector(DATA_WIDTH-1 downto 0);
    cacheint_oimm_readdata      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    cacheint_oimm_readdatavalid : in  std_logic;
    cacheint_oimm_waitrequest   : in  std_logic;

    --Uncached ORCA-internal memory-mapped master
    uc_oimm_address       : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    uc_oimm_byteenable    : out std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    uc_oimm_requestvalid  : out std_logic;
    uc_oimm_readnotwrite  : out std_logic;
    uc_oimm_writedata     : out std_logic_vector(DATA_WIDTH-1 downto 0);
    uc_oimm_readdata      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    uc_oimm_readdatavalid : in  std_logic;
    uc_oimm_waitrequest   : in  std_logic;

    --Tightly-coupled memory ORCA-internal memory-mapped master
    aux_oimm_address       : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    aux_oimm_byteenable    : out std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    aux_oimm_requestvalid  : out std_logic;
    aux_oimm_readnotwrite  : out std_logic;
    aux_oimm_writedata     : out std_logic_vector(DATA_WIDTH-1 downto 0);
    aux_oimm_readdata      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    aux_oimm_readdatavalid : in  std_logic;
    aux_oimm_waitrequest   : in  std_logic
    );
end entity cache_mux;

architecture rtl of cache_mux is
  signal internal_oimm_address       : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal internal_oimm_byteenable    : std_logic_vector((DATA_WIDTH/8)-1 downto 0);
  signal internal_oimm_requestvalid  : std_logic;
  signal internal_oimm_readnotwrite  : std_logic;
  signal internal_oimm_writedata     : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal internal_oimm_readdata      : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal internal_oimm_readdatavalid : std_logic;
  signal internal_oimm_waitrequest   : std_logic;

  signal c_outstanding_reads        : unsigned(log2(MAX_OUTSTANDING_READS+1)-1 downto 0);
  signal uc_outstanding_reads       : unsigned(log2(MAX_OUTSTANDING_READS+1)-1 downto 0);
  signal aux_outstanding_reads      : unsigned(log2(MAX_OUTSTANDING_READS+1)-1 downto 0);
  signal c_zero_outstanding_reads   : std_logic;
  signal uc_zero_outstanding_reads  : std_logic;
  signal aux_zero_outstanding_reads : std_logic;
  signal c_max_outstanding_reads    : std_logic;
  signal uc_max_outstanding_reads   : std_logic;
  signal aux_max_outstanding_reads  : std_logic;

  type address_vector is array (natural range <>) of unsigned(ADDRESS_WIDTH-1 downto 0);
  signal amr_base_addr     : address_vector(imax(AUX_MEMORY_REGIONS, 1)-1 downto 0);
  signal amr_last_addr     : address_vector(imax(AUX_MEMORY_REGIONS, 1)-1 downto 0);
  signal amr_address_match : std_logic_vector(imax(AUX_MEMORY_REGIONS, 1)-1 downto 0);
  signal umr_base_addr     : address_vector(imax(UC_MEMORY_REGIONS, 1)-1 downto 0);
  signal umr_last_addr     : address_vector(imax(UC_MEMORY_REGIONS, 1)-1 downto 0);
  signal umr_address_match : std_logic_vector(imax(UC_MEMORY_REGIONS, 1)-1 downto 0);

  signal c_select   : std_logic;
  signal uc_select  : std_logic;
  signal aux_select : std_logic;
  signal read_stall : std_logic;

  signal internal_uc_oimm_address       : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal internal_uc_oimm_byteenable    : std_logic_vector((DATA_WIDTH/8)-1 downto 0);
  signal internal_uc_oimm_requestvalid  : std_logic;
  signal internal_uc_oimm_readnotwrite  : std_logic;
  signal internal_uc_oimm_writedata     : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal internal_uc_oimm_readdata      : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal internal_uc_oimm_readdatavalid : std_logic;
  signal internal_uc_oimm_waitrequest   : std_logic;
  signal uc_register_idle               : std_logic;

  signal internal_aux_oimm_address       : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal internal_aux_oimm_byteenable    : std_logic_vector((DATA_WIDTH/8)-1 downto 0);
  signal internal_aux_oimm_requestvalid  : std_logic;
  signal internal_aux_oimm_readnotwrite  : std_logic;
  signal internal_aux_oimm_writedata     : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal internal_aux_oimm_readdata      : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal internal_aux_oimm_readdatavalid : std_logic;
  signal internal_aux_oimm_waitrequest   : std_logic;
  signal aux_register_idle               : std_logic;
begin
  -----------------------------------------------------------------------------
  -- Optional Internal OIMM Register
  -----------------------------------------------------------------------------
  internal_oimm_register : oimm_register
    generic map (
      ADDRESS_WIDTH    => ADDRESS_WIDTH,
      DATA_WIDTH       => DATA_WIDTH,
      REQUEST_REGISTER => INTERNAL_REQUEST_REGISTER,
      RETURN_REGISTER  => INTERNAL_RETURN_REGISTER
      )
    port map (
      clk   => clk,
      reset => reset,

      register_idle => internal_register_idle,

      --ORCA-internal memory-mapped slave
      slave_oimm_address       => oimm_address,
      slave_oimm_byteenable    => oimm_byteenable,
      slave_oimm_requestvalid  => oimm_requestvalid,
      slave_oimm_readnotwrite  => oimm_readnotwrite,
      slave_oimm_writedata     => oimm_writedata,
      slave_oimm_readdata      => oimm_readdata,
      slave_oimm_readdatavalid => oimm_readdatavalid,
      slave_oimm_waitrequest   => oimm_waitrequest,

      --ORCA-internal memory-mapped master
      master_oimm_address       => internal_oimm_address,
      master_oimm_byteenable    => internal_oimm_byteenable,
      master_oimm_requestvalid  => internal_oimm_requestvalid,
      master_oimm_readnotwrite  => internal_oimm_readnotwrite,
      master_oimm_writedata     => internal_oimm_writedata,
      master_oimm_readdata      => internal_oimm_readdata,
      master_oimm_readdatavalid => internal_oimm_readdatavalid,
      master_oimm_waitrequest   => internal_oimm_waitrequest
      );


  cacheint_oimm_address    <= internal_oimm_address;
  cacheint_oimm_byteenable <= internal_oimm_byteenable;
  cacheint_oimm_writedata  <= internal_oimm_writedata;

  internal_uc_oimm_address    <= internal_oimm_address;
  internal_uc_oimm_byteenable <= internal_oimm_byteenable;
  internal_uc_oimm_writedata  <= internal_oimm_writedata;

  internal_aux_oimm_address    <= internal_oimm_address;
  internal_aux_oimm_byteenable <= internal_oimm_byteenable;
  internal_aux_oimm_writedata  <= internal_oimm_writedata;

  amr_gen : for gregister in imax(AUX_MEMORY_REGIONS, 1)-1 downto 0 generate
    amr_base_addr(gregister) <=
      unsigned(amr_base_addrs(((gregister+1)*ADDRESS_WIDTH)-1 downto gregister*ADDRESS_WIDTH));
    amr_last_addr(gregister) <=
      unsigned(amr_last_addrs(((gregister+1)*ADDRESS_WIDTH)-1 downto gregister*ADDRESS_WIDTH));
    amr_address_match(gregister) <=
      '1' when ((unsigned(internal_oimm_address) >= amr_base_addr(gregister)) and
                (unsigned(internal_oimm_address) <= amr_last_addr(gregister))) else
      '0';
  end generate amr_gen;
  umr_gen : for gregister in imax(UC_MEMORY_REGIONS, 1)-1 downto 0 generate
    umr_base_addr(gregister) <=
      unsigned(umr_base_addrs(((gregister+1)*ADDRESS_WIDTH)-1 downto gregister*ADDRESS_WIDTH));
    umr_last_addr(gregister) <=
      unsigned(umr_last_addrs(((gregister+1)*ADDRESS_WIDTH)-1 downto gregister*ADDRESS_WIDTH));
    umr_address_match(gregister) <=
      '1' when ((unsigned(internal_oimm_address) >= umr_base_addr(gregister)) and
                (unsigned(internal_oimm_address) <= umr_last_addr(gregister))) else
      '0';
  end generate umr_gen;

  --Generate control signals depending on which interfaces are enabled and if
  --the address ranges overalp.  Cache has all unspecified addresses.  If AUX
  --and UC overlap use AUX.
  no_aux_gen : if AUX_MEMORY_REGIONS = 0 generate
    aux_select <= '0';
    no_uc_gen : if UC_MEMORY_REGIONS = 0 generate
      uc_select               <= '0';
      external_registers_idle <= '1';
      no_c_gen : if CACHE_SIZE = 0 generate
        c_select                    <= '0';
        internal_oimm_readdata      <= (others => '-');
        internal_oimm_readdatavalid <= '0';
        assert true report
          "Error; Cache is disabled (CACHE_SIZE = 0), UC interface is disabled (UC_MEMORY_REGIONS = 0), and AUX interface is disabled (AUX_MEMORY_REGIONS = 0).  At least one interface must be enabled."
          severity failure;
      end generate no_c_gen;
      has_c_gen : if CACHE_SIZE /= 0 generate
        c_select                    <= '1';
        internal_oimm_readdata      <= cacheint_oimm_readdata;
        internal_oimm_readdatavalid <= cacheint_oimm_readdatavalid;
      end generate has_c_gen;
    end generate no_uc_gen;
    has_uc_gen : if UC_MEMORY_REGIONS /= 0 generate
      external_registers_idle <= uc_register_idle;
      no_c_gen : if CACHE_SIZE = 0 generate
        c_select                    <= '0';
        uc_select                   <= '1';
        internal_oimm_readdata      <= internal_uc_oimm_readdata;
        internal_oimm_readdatavalid <= internal_uc_oimm_readdatavalid;
        assert not ((unsigned(UMR0_ADDR_BASE) /= to_unsigned(0, UMR0_ADDR_BASE'length)) or
                    (signed(UMR0_ADDR_LAST) /= to_signed(-1, UMR0_ADDR_LAST'length))) report
          "Warning; Cache is disabled (CACHE_SIZE = 0) and AUX interface is disabled (AUX_MEMORY_REGIONS = 0) but UMR0 address range does not encompass the full address range.  All accesses will go to UC interface, even those not in the UMR0 address range."
          severity note;
        assert UC_MEMORY_REGIONS = 1 report
          "Warning; Cache is disabled (CACHE_SIZE = 0) and AUX interface is disabled (AUX_MEMORY_REGIONS = 0) but UC_MEMORY_REGIONS is greater than 1.  Multiple UC_MEMORY_REGIONS are superflous in this configuration as all accesses will use the UC memory interface."
          severity note;
      end generate no_c_gen;
      has_c_gen : if CACHE_SIZE /= 0 generate
        uc_select <= or_slv(umr_address_match);
        c_select  <= and_slv(not umr_address_match);

        internal_oimm_readdata <= cacheint_oimm_readdata when cacheint_oimm_readdatavalid = '1' else
                                  internal_uc_oimm_readdata;
        internal_oimm_readdatavalid <= cacheint_oimm_readdatavalid or internal_uc_oimm_readdatavalid;
      end generate has_c_gen;
    end generate has_uc_gen;
  end generate no_aux_gen;
  has_aux_gen : if AUX_MEMORY_REGIONS /= 0 generate
    no_uc_gen : if UC_MEMORY_REGIONS = 0 generate
      uc_select               <= '0';
      external_registers_idle <= aux_register_idle;
      no_c_gen : if CACHE_SIZE = 0 generate
        aux_select                  <= '1';
        c_select                    <= '0';
        internal_oimm_readdata      <= internal_aux_oimm_readdata;
        internal_oimm_readdatavalid <= internal_aux_oimm_readdatavalid;
        assert not ((unsigned(AMR0_ADDR_BASE) /= to_unsigned(0, AMR0_ADDR_BASE'length)) or
                    (signed(AMR0_ADDR_LAST) /= to_signed(-1, AMR0_ADDR_LAST'length))) report
          "Warning; Cache is disabled (CACHE_SIZE = 0) and UC interface is disabled (UC_MEMORY_REGIONS = 0) but AMR0 address range does not encompass the full address range.  All accesses will go to AUX interface, even those not in the AMR0 address range."
          severity note;
        assert AUX_MEMORY_REGIONS = 1 report
          "Warning; Cache is disabled (CACHE_SIZE = 0) and UC interface is disabled (UC_MEMORY_REGIONS = 0) but AUX_MEMORY_REGIONS is greater than 1.  Multiple AUX_MEMORY_REGIONS are superflous in this configuration as all accesses will use the AUX memory interface."
          severity note;
      end generate no_c_gen;
      has_c_gen : if CACHE_SIZE /= 0 generate
        aux_select             <= or_slv(amr_address_match);
        c_select               <= and_slv(not amr_address_match);
        internal_oimm_readdata <= cacheint_oimm_readdata when cacheint_oimm_readdatavalid = '1' else
                                  internal_aux_oimm_readdata;
        internal_oimm_readdatavalid <= cacheint_oimm_readdatavalid or internal_aux_oimm_readdatavalid;
      end generate has_c_gen;
    end generate no_uc_gen;
    has_uc_gen : if UC_MEMORY_REGIONS /= 0 generate
      aux_select              <= or_slv(amr_address_match);
      external_registers_idle <= uc_register_idle and aux_register_idle;
      no_c_gen : if CACHE_SIZE = 0 generate
        uc_select              <= and_slv(not amr_address_match);
        c_select               <= '0';
        internal_oimm_readdata <= internal_uc_oimm_readdata when internal_uc_oimm_readdatavalid = '1' else
                                  internal_aux_oimm_readdata;
        internal_oimm_readdatavalid <= internal_uc_oimm_readdatavalid or internal_aux_oimm_readdatavalid;
      end generate no_c_gen;
      has_c_gen : if CACHE_SIZE /= 0 generate
        uc_select              <= and_slv(not amr_address_match) and or_slv(umr_address_match);
        c_select               <= and_slv(not amr_address_match) and and_slv(not umr_address_match);
        internal_oimm_readdata <= cacheint_oimm_readdata when cacheint_oimm_readdatavalid = '1' else
                                  internal_uc_oimm_readdata when internal_uc_oimm_readdatavalid = '1' else
                                  internal_aux_oimm_readdata;
        internal_oimm_readdatavalid <= cacheint_oimm_readdatavalid or
                                       internal_uc_oimm_readdatavalid or
                                       internal_aux_oimm_readdatavalid;
      end generate has_c_gen;
    end generate has_uc_gen;
  end generate has_aux_gen;

  read_stall <=
    ((c_select and (c_max_outstanding_reads or (not uc_zero_outstanding_reads) or (not aux_zero_outstanding_reads))) or
     (uc_select and (uc_max_outstanding_reads or (not c_zero_outstanding_reads) or (not aux_zero_outstanding_reads))) or
     (aux_select and (aux_max_outstanding_reads or (not c_zero_outstanding_reads) or (not uc_zero_outstanding_reads))))
    when MAX_OUTSTANDING_READS > 1 else
    '0';
  internal_oimm_waitrequest <= read_stall or
                               ((cacheint_oimm_waitrequest and c_select) or
                                (internal_uc_oimm_waitrequest and uc_select) or
                                (internal_aux_oimm_waitrequest and aux_select));

  cacheint_oimm_requestvalid <= internal_oimm_requestvalid and (not read_stall) and c_select;
  cacheint_oimm_readnotwrite <= internal_oimm_readnotwrite;

  internal_uc_oimm_requestvalid <= internal_oimm_requestvalid and (not read_stall) and uc_select;
  internal_uc_oimm_readnotwrite <= internal_oimm_readnotwrite;

  internal_aux_oimm_requestvalid <= internal_oimm_requestvalid and (not read_stall) and aux_select;
  internal_aux_oimm_readnotwrite <= internal_oimm_readnotwrite;


  --Note that we could include the updated read count when
  --internal_oimm_readdatavalid is '1' but as long as more than one read is
  --supported we can get full throughput with MAX_OUTSTANDING_READS-1 in
  --flight.
  c_zero_outstanding_reads <= '1' when c_outstanding_reads = to_unsigned(0, c_outstanding_reads'length) else '0';
  c_max_outstanding_reads <=
    '1' when c_outstanding_reads = to_unsigned(MAX_OUTSTANDING_READS, c_outstanding_reads'length) else '0';

  uc_zero_outstanding_reads <= '1' when uc_outstanding_reads = to_unsigned(0, uc_outstanding_reads'length) else '0';
  uc_max_outstanding_reads <=
    '1' when uc_outstanding_reads = to_unsigned(MAX_OUTSTANDING_READS, uc_outstanding_reads'length) else '0';

  aux_zero_outstanding_reads <= '1' when aux_outstanding_reads = to_unsigned(0, aux_outstanding_reads'length) else '0';
  aux_max_outstanding_reads <=
    '1' when aux_outstanding_reads = to_unsigned(MAX_OUTSTANDING_READS, aux_outstanding_reads'length) else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if internal_oimm_readdatavalid = '1' then
        --Subtract one unless a new request has been issued
        if (internal_oimm_requestvalid = '0' or
            internal_oimm_readnotwrite = '0' or
            internal_oimm_waitrequest = '1') then
          if c_outstanding_reads /= to_unsigned(0, c_outstanding_reads'length) then
            c_outstanding_reads <= c_outstanding_reads - to_unsigned(1, c_outstanding_reads'length);
          end if;
          if uc_outstanding_reads /= to_unsigned(0, uc_outstanding_reads'length) then
            uc_outstanding_reads <= uc_outstanding_reads - to_unsigned(1, uc_outstanding_reads'length);
          end if;
          if aux_outstanding_reads /= to_unsigned(0, aux_outstanding_reads'length) then
            aux_outstanding_reads <= aux_outstanding_reads - to_unsigned(1, aux_outstanding_reads'length);
          end if;
        end if;
      else
        if (internal_oimm_requestvalid = '1' and
            internal_oimm_readnotwrite = '1' and
            internal_oimm_waitrequest = '0') then
          if c_select = '1' then
            c_outstanding_reads <= c_outstanding_reads + to_unsigned(1, c_outstanding_reads'length);
          end if;
          if uc_select = '1' then
            uc_outstanding_reads <= uc_outstanding_reads + to_unsigned(1, uc_outstanding_reads'length);
          end if;
          if aux_select = '1' then
            aux_outstanding_reads <= aux_outstanding_reads + to_unsigned(1, aux_outstanding_reads'length);
          end if;
        end if;
      end if;

      if reset = '1' then
        c_outstanding_reads   <= to_unsigned(0, c_outstanding_reads'length);
        uc_outstanding_reads  <= to_unsigned(0, uc_outstanding_reads'length);
        aux_outstanding_reads <= to_unsigned(0, aux_outstanding_reads'length);
      end if;
    end if;
  end process;


  -----------------------------------------------------------------------------
  -- Optional UC OIMM Register
  -----------------------------------------------------------------------------
  uc_oimm_register : oimm_register
    generic map (
      ADDRESS_WIDTH    => ADDRESS_WIDTH,
      DATA_WIDTH       => DATA_WIDTH,
      REQUEST_REGISTER => UC_REQUEST_REGISTER,
      RETURN_REGISTER  => UC_RETURN_REGISTER
      )
    port map (
      clk   => clk,
      reset => reset,

      register_idle => uc_register_idle,

      --ORCA-internal memory-mapped slave
      slave_oimm_address       => internal_uc_oimm_address,
      slave_oimm_byteenable    => internal_uc_oimm_byteenable,
      slave_oimm_requestvalid  => internal_uc_oimm_requestvalid,
      slave_oimm_readnotwrite  => internal_uc_oimm_readnotwrite,
      slave_oimm_writedata     => internal_uc_oimm_writedata,
      slave_oimm_readdata      => internal_uc_oimm_readdata,
      slave_oimm_readdatavalid => internal_uc_oimm_readdatavalid,
      slave_oimm_waitrequest   => internal_uc_oimm_waitrequest,

      --ORCA-internal memory-mapped master
      master_oimm_address       => uc_oimm_address,
      master_oimm_byteenable    => uc_oimm_byteenable,
      master_oimm_requestvalid  => uc_oimm_requestvalid,
      master_oimm_readnotwrite  => uc_oimm_readnotwrite,
      master_oimm_writedata     => uc_oimm_writedata,
      master_oimm_readdata      => uc_oimm_readdata,
      master_oimm_readdatavalid => uc_oimm_readdatavalid,
      master_oimm_waitrequest   => uc_oimm_waitrequest
      );

  -----------------------------------------------------------------------------
  -- Optional AUX OIMM Register
  -----------------------------------------------------------------------------
  aux_oimm_register : oimm_register
    generic map (
      ADDRESS_WIDTH    => ADDRESS_WIDTH,
      DATA_WIDTH       => DATA_WIDTH,
      REQUEST_REGISTER => AUX_REQUEST_REGISTER,
      RETURN_REGISTER  => AUX_RETURN_REGISTER
      )
    port map (
      clk   => clk,
      reset => reset,

      register_idle => aux_register_idle,

      --ORCA-internal memory-mapped slave
      slave_oimm_address       => internal_aux_oimm_address,
      slave_oimm_byteenable    => internal_aux_oimm_byteenable,
      slave_oimm_requestvalid  => internal_aux_oimm_requestvalid,
      slave_oimm_readnotwrite  => internal_aux_oimm_readnotwrite,
      slave_oimm_writedata     => internal_aux_oimm_writedata,
      slave_oimm_readdata      => internal_aux_oimm_readdata,
      slave_oimm_readdatavalid => internal_aux_oimm_readdatavalid,
      slave_oimm_waitrequest   => internal_aux_oimm_waitrequest,

      --ORCA-internal memory-mapped master
      master_oimm_address       => aux_oimm_address,
      master_oimm_byteenable    => aux_oimm_byteenable,
      master_oimm_requestvalid  => aux_oimm_requestvalid,
      master_oimm_readnotwrite  => aux_oimm_readnotwrite,
      master_oimm_writedata     => aux_oimm_writedata,
      master_oimm_readdata      => aux_oimm_readdata,
      master_oimm_readdatavalid => aux_oimm_readdatavalid,
      master_oimm_waitrequest   => aux_oimm_waitrequest
      );

end architecture;
