----------------------------------------------------------------------
--- Group Num: 4 
--- Author: QINGYU ZHANG(vn22984), SHURAN YANG(rw22242), HAIBO LIAN(tb22111)
--- Date: 22/10/2022 
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;
library UNISIM;
use UNISIM.VComponents.all;


-- The data_wapper
entity data_swapper is
  port(
    clkm : in std_logic;
    rstn : in std_logic;
    HRDATA : out std_logic_vector (31 downto 0);
    dmao : in ahb_dma_out_type
  );
end;
----------------------------------------------------------------------
architecture structural of data_swapper is

-- define the signal
-- signal get_rdata_1 : std_logic_vector (31 downto 0);

begin
--  swapper:
--  process(dmao.rdata)
    -- define the variable
    -- variable get_rdata_2 : std_logic_vector (31 downto 0);
--  begin
    -- get_rdata_1 <= dmao.rdata; -- not work because of signal cannot refresh in the process
    -- get_rdata_2 := dmao.rdata; -- work but we do not need extra latch
--    HRDATA (31 downto 24) <= get_rdata_2 (7 downto 0);
--    HRDATA (23 downto 16) <= get_rdata_2 (15 downto 8);
--    HRDATA (15 downto 8) <= get_rdata_2 (23 downto 16);
--    HRDATA (7 downto 0) <= get_rdata_2 (31 downto 24);
--    HRDATA (31 downto 24) <= dmao.rdata (7 downto 0);
--    HRDATA (23 downto 16) <= dmao.rdata (15 downto 8);
--    HRDATA (15 downto 8) <= dmao.rdata (23 downto 16);
--    HRDATA (7 downto 0) <= dmao.rdata (31 downto 24);
--  end process;
 
  HRDATA (31 downto 24) <= dmao.rdata (7 downto 0);
  HRDATA (23 downto 16) <= dmao.rdata (15 downto 8);
  HRDATA (15 downto 8) <= dmao.rdata (23 downto 16);
  HRDATA (7 downto 0) <= dmao.rdata (31 downto 24);
  
end structural;

