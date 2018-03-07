library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.rv_components.all;
use work.utils.all;
use work.constants_pkg.all;

entity oimm_register is
  generic (
    ADDRESS_WIDTH    : positive;
    DATA_WIDTH       : positive;
    LOG2_BURSTLENGTH : positive := 2;
    REQUEST_REGISTER : request_register_type;
    RETURN_REGISTER  : boolean
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    register_idle : out std_logic;

    --ORCA-internal memory-mapped slave
    slave_oimm_address            : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    slave_oimm_burstlength        : in  std_logic_vector(LOG2_BURSTLENGTH downto 0)   := (0      => '1', others => '0');
    slave_oimm_burstlength_minus1 : in  std_logic_vector(LOG2_BURSTLENGTH-1 downto 0) := (others => '0');
    slave_oimm_byteenable         : in  std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    slave_oimm_requestvalid       : in  std_logic;
    slave_oimm_readnotwrite       : in  std_logic;
    slave_oimm_writedata          : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    slave_oimm_writelast          : in  std_logic                                     := '1';
    slave_oimm_readdata           : out std_logic_vector(DATA_WIDTH-1 downto 0);
    slave_oimm_readdatavalid      : out std_logic;
    slave_oimm_waitrequest        : out std_logic;

    --ORCA-internal memory-mapped master
    master_oimm_address            : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    master_oimm_burstlength        : out std_logic_vector(LOG2_BURSTLENGTH downto 0);
    master_oimm_burstlength_minus1 : out std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    master_oimm_byteenable         : out std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    master_oimm_requestvalid       : out std_logic;
    master_oimm_readnotwrite       : out std_logic;
    master_oimm_writedata          : out std_logic_vector(DATA_WIDTH-1 downto 0);
    master_oimm_writelast          : out std_logic;
    master_oimm_readdata           : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    master_oimm_readdatavalid      : in  std_logic;
    master_oimm_waitrequest        : in  std_logic
    );
end entity oimm_register;

architecture rtl of oimm_register is
  signal slave_oimm_waitrequest_signal   : std_logic;
  signal master_oimm_requestvalid_signal : std_logic;
begin
  slave_oimm_waitrequest   <= slave_oimm_waitrequest_signal;
  master_oimm_requestvalid <= master_oimm_requestvalid_signal;
  -----------------------------------------------------------------------------
  -- Optional Memory Request Register
  -----------------------------------------------------------------------------

  --Passthrough, lowest fmax but no extra resources or added latency.
  no_request_register_gen : if REQUEST_REGISTER = OFF generate
    master_oimm_address             <= slave_oimm_address;
    master_oimm_burstlength         <= slave_oimm_burstlength;
    master_oimm_burstlength_minus1  <= slave_oimm_burstlength_minus1;
    master_oimm_byteenable          <= slave_oimm_byteenable;
    master_oimm_requestvalid_signal <= slave_oimm_requestvalid;
    master_oimm_readnotwrite        <= slave_oimm_readnotwrite;
    master_oimm_writedata           <= slave_oimm_writedata;
    master_oimm_writelast           <= slave_oimm_writelast;

    slave_oimm_waitrequest_signal <= master_oimm_waitrequest;

    register_idle <= '1';               --idle is state-only
  end generate no_request_register_gen;

  --Light register; breaks waitrequest/stall combinational path but does not break
  --address/etc. path.  Does not add latency if slave is not asserting
  --waitrequest, but will reduce throughput if the slave does.
  light_request_register_gen : if REQUEST_REGISTER = LIGHT generate
    signal slave_oimm_address_held            : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    signal slave_oimm_burstlength_held        : std_logic_vector(LOG2_BURSTLENGTH downto 0);
    signal slave_oimm_burstlength_minus1_held : std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    signal slave_oimm_byteenable_held         : std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    signal slave_oimm_requestvalid_held       : std_logic;
    signal slave_oimm_readnotwrite_held       : std_logic;
    signal slave_oimm_writedata_held          : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal slave_oimm_writelast_held          : std_logic;
  begin
    master_oimm_address             <= slave_oimm_address_held            when slave_oimm_waitrequest_signal = '1' else slave_oimm_address;
    master_oimm_burstlength         <= slave_oimm_burstlength_held        when slave_oimm_waitrequest_signal = '1' else slave_oimm_burstlength;
    master_oimm_burstlength_minus1  <= slave_oimm_burstlength_minus1_held when slave_oimm_waitrequest_signal = '1' else slave_oimm_burstlength_minus1;
    master_oimm_byteenable          <= slave_oimm_byteenable_held         when slave_oimm_waitrequest_signal = '1' else slave_oimm_byteenable;
    master_oimm_requestvalid_signal <= slave_oimm_requestvalid_held       when slave_oimm_waitrequest_signal = '1' else slave_oimm_requestvalid;
    master_oimm_readnotwrite        <= slave_oimm_readnotwrite_held       when slave_oimm_waitrequest_signal = '1' else slave_oimm_readnotwrite;
    master_oimm_writedata           <= slave_oimm_writedata_held          when slave_oimm_waitrequest_signal = '1' else slave_oimm_writedata;
    master_oimm_writelast           <= slave_oimm_writelast_held          when slave_oimm_waitrequest_signal = '1' else slave_oimm_writelast;

    process(clk)
    begin
      if rising_edge(clk) then
        --When coming out of reset, need to put waitrequest down
        if slave_oimm_requestvalid_held = '0' then
          slave_oimm_waitrequest_signal <= '0';
        end if;

        if master_oimm_waitrequest = '0' then
          slave_oimm_waitrequest_signal <= '0';
        end if;

        if slave_oimm_waitrequest_signal = '0' then
          slave_oimm_address_held            <= slave_oimm_address;
          slave_oimm_burstlength_held        <= slave_oimm_burstlength;
          slave_oimm_burstlength_minus1_held <= slave_oimm_burstlength_minus1;
          slave_oimm_byteenable_held         <= slave_oimm_byteenable;
          slave_oimm_requestvalid_held       <= slave_oimm_requestvalid;
          slave_oimm_readnotwrite_held       <= slave_oimm_readnotwrite;
          slave_oimm_writedata_held          <= slave_oimm_writedata;
          slave_oimm_writelast_held          <= slave_oimm_writelast;
          slave_oimm_waitrequest_signal      <= master_oimm_waitrequest and slave_oimm_requestvalid;
        end if;

        if reset = '1' then
          slave_oimm_requestvalid_held  <= '0';
          slave_oimm_waitrequest_signal <= '1';
        end if;
      end if;
    end process;

    register_idle <= not slave_oimm_waitrequest_signal;  --idle is state-only
  end generate light_request_register_gen;

  --Full register; breaks waitrequest/stall combinational path and address/etc.
  --path. Always adds one cycle of latency but does not reduce throughput.
  full_request_register_gen : if REQUEST_REGISTER = FULL generate
    signal registered_oimm_address            : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    signal registered_oimm_burstlength        : std_logic_vector(LOG2_BURSTLENGTH downto 0);
    signal registered_oimm_burstlength_minus1 : std_logic_vector(LOG2_BURSTLENGTH-1 downto 0);
    signal registered_oimm_byteenable         : std_logic_vector((DATA_WIDTH/8)-1 downto 0);
    signal registered_oimm_requestvalid       : std_logic;
    signal registered_oimm_readnotwrite       : std_logic;
    signal registered_oimm_writedata          : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal registered_oimm_writelast          : std_logic;
  begin
    process(clk)
    begin
      if rising_edge(clk) then
        --When coming out of reset, need to put waitrequest down
        if registered_oimm_requestvalid = '0' then
          slave_oimm_waitrequest_signal <= '0';
        end if;

        if master_oimm_waitrequest = '0' then
          master_oimm_requestvalid_signal <= '0';
          if registered_oimm_requestvalid = '1' then
            master_oimm_address             <= registered_oimm_address;
            master_oimm_burstlength         <= registered_oimm_burstlength;
            master_oimm_burstlength_minus1  <= registered_oimm_burstlength_minus1;
            master_oimm_byteenable          <= registered_oimm_byteenable;
            master_oimm_readnotwrite        <= registered_oimm_readnotwrite;
            master_oimm_requestvalid_signal <= registered_oimm_requestvalid;
            master_oimm_writedata           <= registered_oimm_writedata;
            master_oimm_writelast           <= registered_oimm_writelast;
            registered_oimm_requestvalid    <= '0';
            slave_oimm_waitrequest_signal   <= '0';
          else
            master_oimm_address             <= slave_oimm_address;
            master_oimm_burstlength         <= slave_oimm_burstlength;
            master_oimm_burstlength_minus1  <= slave_oimm_burstlength_minus1;
            master_oimm_byteenable          <= slave_oimm_byteenable;
            master_oimm_readnotwrite        <= slave_oimm_readnotwrite;
            master_oimm_requestvalid_signal <= slave_oimm_requestvalid and (not slave_oimm_waitrequest_signal);
            master_oimm_writedata           <= slave_oimm_writedata;
            master_oimm_writelast           <= slave_oimm_writelast;
          end if;
        else
          if slave_oimm_waitrequest_signal = '0' then
            if master_oimm_requestvalid_signal = '1' then
              registered_oimm_address            <= slave_oimm_address;
              registered_oimm_burstlength        <= slave_oimm_burstlength;
              registered_oimm_burstlength_minus1 <= slave_oimm_burstlength_minus1;
              registered_oimm_byteenable         <= slave_oimm_byteenable;
              registered_oimm_requestvalid       <= slave_oimm_requestvalid;
              registered_oimm_readnotwrite       <= slave_oimm_readnotwrite;
              registered_oimm_writedata          <= slave_oimm_writedata;
              registered_oimm_writelast          <= slave_oimm_writelast;
              slave_oimm_waitrequest_signal      <= slave_oimm_requestvalid;
            else
              master_oimm_address             <= slave_oimm_address;
              master_oimm_burstlength         <= slave_oimm_burstlength;
              master_oimm_burstlength_minus1  <= slave_oimm_burstlength_minus1;
              master_oimm_byteenable          <= slave_oimm_byteenable;
              master_oimm_readnotwrite        <= slave_oimm_readnotwrite;
              master_oimm_requestvalid_signal <= slave_oimm_requestvalid;
              master_oimm_writedata           <= slave_oimm_writedata;
              master_oimm_writelast           <= slave_oimm_writelast;
            end if;
          end if;
        end if;

        if reset = '1' then
          master_oimm_requestvalid_signal <= '0';
          registered_oimm_requestvalid    <= '0';
          slave_oimm_waitrequest_signal   <= '1';
        end if;
      end if;
    end process;

    register_idle <= not master_oimm_requestvalid_signal;  --idle is state-only
  end generate full_request_register_gen;

  -----------------------------------------------------------------------------
  -- Optional Data Memory Return Register
  -----------------------------------------------------------------------------
  no_return_register_gen : if not RETURN_REGISTER generate
    slave_oimm_readdata      <= master_oimm_readdata;
    slave_oimm_readdatavalid <= master_oimm_readdatavalid;
  end generate no_return_register_gen;
  return_register_gen : if RETURN_REGISTER generate
    process(clk)
    begin
      if rising_edge(clk) then
        slave_oimm_readdata      <= master_oimm_readdata;
        slave_oimm_readdatavalid <= master_oimm_readdatavalid;
      end if;
    end process;
  end generate return_register_gen;

end architecture rtl;
