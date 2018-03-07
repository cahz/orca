library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.rv_components.all;
use work.utils.all;

--Sets waitrequest on the slave if too many outstanding requests are in flight.
--This is needed for certain interconnect tools that want a bounded number of
--requests in progress.
entity oimm_throttler is
  generic (
    MAX_OUTSTANDING_REQUESTS : natural;
    READ_WRITE_FENCE         : boolean
    );
  port (
    clk   : in std_logic;
    reset : in std_logic;

    throttler_idle : out std_logic;

    --ORCA-internal memory-mapped slave
    slave_oimm_requestvalid : in  std_logic;
    slave_oimm_readnotwrite : in  std_logic;
    slave_oimm_writelast    : in  std_logic;
    slave_oimm_waitrequest  : out std_logic;

    --ORCA-internal memory-mapped master
    master_oimm_requestvalid  : out std_logic;
    master_oimm_readcomplete  : in  std_logic;
    master_oimm_writecomplete : in  std_logic;
    master_oimm_waitrequest   : in  std_logic
    );
end entity oimm_throttler;

architecture rtl of oimm_throttler is
  signal slave_oimm_waitrequest_signal : std_logic;
  signal outstanding_are_reads         : std_logic;
  signal request_accepted              : std_logic;
  signal throttle                      : std_logic;
begin
  slave_oimm_waitrequest        <= slave_oimm_waitrequest_signal;
  master_oimm_requestvalid      <= slave_oimm_requestvalid and (not throttle);
  slave_oimm_waitrequest_signal <= master_oimm_waitrequest or throttle;
  process (clk) is
  begin
    if rising_edge(clk) then
      if slave_oimm_requestvalid = '1' and slave_oimm_waitrequest_signal = '0' then
        outstanding_are_reads <= slave_oimm_readnotwrite;
      end if;
    end if;
  end process;
  request_accepted <=
    slave_oimm_requestvalid and (slave_oimm_readnotwrite or slave_oimm_writelast) and (not slave_oimm_waitrequest_signal);

  dont_throttle_gen : if MAX_OUTSTANDING_REQUESTS = 0 generate
    throttle       <= '0';
    throttler_idle <= '1';
  end generate dont_throttle_gen;
  throttle_gen : if MAX_OUTSTANDING_REQUESTS > 0 generate
    one_outstanding_request_gen : if MAX_OUTSTANDING_REQUESTS = 1 generate
      signal outstanding_request : std_logic;
    begin
      process (clk) is
      begin
        if rising_edge(clk) then
          if master_oimm_readcomplete = '1' or master_oimm_writecomplete = '1' then
            outstanding_request <= '0';
            throttler_idle      <= '1';
          end if;
          if request_accepted = '1' then
            outstanding_request <= '1';
            throttler_idle      <= '0';
          end if;

          if reset = '1' then
            outstanding_request <= '0';
            throttler_idle      <= '1';
          end if;
        end if;
      end process;

      --No need to worry about READ_WRITE_FENCE; since only one access can be in
      --flight a read must return before a write is accepted and vice-versa
      throttle <= outstanding_request and (not (master_oimm_readcomplete or master_oimm_writecomplete));
    end generate one_outstanding_request_gen;
    multiple_outstanding_requests_gen : if MAX_OUTSTANDING_REQUESTS > 1 generate
      signal outstanding_requests         : unsigned(log2(MAX_OUTSTANDING_REQUESTS+1)-1 downto 0);
      signal change_in_requests           : signed(log2(MAX_OUTSTANDING_REQUESTS+1)-1 downto 0);
      signal next_outstanding_requests    : unsigned(log2(MAX_OUTSTANDING_REQUESTS+1)-1 downto 0);
      signal outstanding_requests_eq_zero : std_logic;
      signal outstanding_requests_eq_max  : std_logic;
      signal change_select_vector         : std_logic_vector(2 downto 0);
    begin
      change_select_vector <= request_accepted & master_oimm_readcomplete & master_oimm_writecomplete;
      with change_select_vector select
        change_in_requests <=
        to_signed(-2, change_in_requests'length) when "011",
        to_signed(-1, change_in_requests'length) when "111"|"010"|"001",
        to_signed(1, change_in_requests'length)  when "100",
        to_signed(0, change_in_requests'length)  when others;

      next_outstanding_requests <= outstanding_requests + unsigned(change_in_requests);

      --Note that 'throttle' is based on outstanding requests only (not using
      --readcomplete or writecomplete combinationally) to avoid a combinational
      --path from the master back to the slave.  This means, however, that for
      --a fully pipelined slave with fixed latency you will need
      --MAX_OUTSTANDING_REQUESTS to be request latency + 1 to get full
      --throughput.
      process (clk) is
      begin
        if rising_edge(clk) then
          outstanding_requests <= next_outstanding_requests;
          if next_outstanding_requests = to_unsigned(MAX_OUTSTANDING_REQUESTS, next_outstanding_requests'length) then
            outstanding_requests_eq_max <= '1';
          else
            outstanding_requests_eq_max <= '0';
          end if;

          if next_outstanding_requests = to_unsigned(0, next_outstanding_requests'length) then
            outstanding_requests_eq_zero <= '1';
          else
            outstanding_requests_eq_zero <= '0';
          end if;

          if reset = '1' then
            outstanding_requests         <= to_unsigned(0, outstanding_requests'length);
            outstanding_requests_eq_max  <= '0';
            outstanding_requests_eq_zero <= '1';
          end if;
        end if;
      end process;
      throttler_idle <= outstanding_requests_eq_zero;

      no_rw_fence_gen : if not READ_WRITE_FENCE generate
        throttle <= outstanding_requests_eq_max;
      end generate no_rw_fence_gen;
      rw_fence_gen : if READ_WRITE_FENCE generate
        throttle <= outstanding_requests_eq_max or ((not outstanding_requests_eq_zero) and (outstanding_are_reads xor slave_oimm_readnotwrite));
      end generate rw_fence_gen;
    end generate multiple_outstanding_requests_gen;
  end generate throttle_gen;

end architecture rtl;
