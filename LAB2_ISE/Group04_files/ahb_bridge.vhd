----------------------------------------------------------------------
--- Group Num: 4 
--- Author: QINGYU ZHANG(vn22984), SHURAN YANG(rw22242), HAIBO LIAN(tb22111)
--- Date: 22/10/2022 
----------------------------------------------------------------------

--  type ahb_dma_in_type is record
--    address         : std_logic_vector(31 downto 0);
--    wdata           : std_logic_vector(AHBDW-1 downto 0);
--    start           : std_ulogic;
--    burst           : std_ulogic;
--    write           : std_ulogic;
--    busy            : std_ulogic;
--    irq             : std_ulogic;
--    size            : std_logic_vector(2 downto 0);
--  end record;
--
--  type ahb_dma_out_type is record
--    start           : std_ulogic;
--    active          : std_ulogic;
--    ready           : std_ulogic;
--    retry           : std_ulogic;
--    mexc            : std_ulogic;
--    haddr           : std_logic_vector(9 downto 0);
--    rdata           : std_logic_vector(AHBDW-1 downto 0);
--  end record;

---- AHB master inputs
--  type ahb_mst_in_type is record
--    hgrant	: std_logic_vector(0 to NAHBMST-1);     -- bus grant
--    hready	: std_ulogic;                         	-- transfer done
--    hresp	: std_logic_vector(1 downto 0); 	-- response type
--    hrdata	: std_logic_vector(AHBDW-1 downto 0); 	-- read data bus
--    hcache	: std_ulogic;                         	-- cacheable
--    hirq  	: std_logic_vector(NAHBIRQ-1 downto 0);	-- interrupt result bus
--    testen	: std_ulogic;                         	-- scan test enable
--    testrst	: std_ulogic;                         	-- scan test reset
--    scanen 	: std_ulogic;                         	-- scan enable
--    testoen 	: std_ulogic;                         	-- test output enable 
--  end record;
--
---- AHB master outputs
--  type ahb_mst_out_type is record
--    hbusreq	: std_ulogic;                         	-- bus request
--    hlock	: std_ulogic;                         	-- lock request
--    htrans	: std_logic_vector(1 downto 0); 	-- transfer type
--    haddr	: std_logic_vector(31 downto 0); 	-- address bus (byte)
--    hwrite	: std_ulogic;                         	-- read/write
--    hsize	: std_logic_vector(2 downto 0); 	-- transfer size
--    hburst	: std_logic_vector(2 downto 0); 	-- burst type
--    hprot	: std_logic_vector(3 downto 0); 	-- protection control
--    hwdata	: std_logic_vector(AHBDW-1 downto 0); 	-- write data bus
--    hirq   	: std_logic_vector(NAHBIRQ-1 downto 0);	-- interrupt bus
--    hconfig 	: ahb_config_type;	 		-- memory access reg.
--    hindex  	: integer range 0 to NAHBMST-1;	 	-- diagnostic use only
--  end record;

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

-- The second interface for the AHB bridge
entity ahb_bridge is
  port(
    -- Clock and Reset 
    clkm : in std_logic;
    rstn : in std_logic;
    -- AHB Master records 
    ahbmi : in ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;
    -- ARM Cortex-M0 AHB-Lite signals 
    HADDR : in std_logic_vector (31 downto 0);    -- AHB transaction address
    HSIZE : in std_logic_vector (2 downto 0);     -- AHB size: byte, half-word or word
    HTRANS : in std_logic_vector (1 downto 0);    -- AHB transfer: non-sequential only
    HWDATA : in std_logic_vector (31 downto 0);   -- AHB write-data
    HWRITE : in std_logic; -- AHB write control
    HRDATA : out std_logic_vector (31 downto 0);  -- AHB read-data
    HREADY : out std_logic -- AHB stall signal
  );
end;

----------------------------------------------------------------------
architecture structural of ahb_bridge is
----------------------------
--declare a component
--declare a component for state_machine
-- Two state
-- idle state
-- HREADY <= '1' idle state AHB-Lite bus is ready to accept an address-phase
-- If we forget to do this then the processor will not do anything
-- instr_fetch state
-- HREADY <= '0' instr_fetch
component state_machine is
  port(
    clkm : in std_logic;
    rstn : in std_logic;
    HADDR : in std_logic_vector (31 downto 0);
    HSIZE : in std_logic_vector (2 downto 0);
    HTRANS : in std_logic_vector (1 downto 0);
    HWDATA : in std_logic_vector (31 downto 0);
    HWRITE : in std_logic;
    HREADY : out std_logic;
		dmai : out ahb_dma_in_type;
		dmao : in ahb_dma_out_type
	);
end component;

--declare a component for ahbmst
component ahbmst is
  generic (
    hindex  : integer := 0;
    hirq    : integer := 0;
    venid   : integer := VENDOR_GAISLER;
    devid   : integer := 0;
    version : integer := 0;
    chprot  : integer := 3;
    incaddr : integer := 0); 
  port(
    rst  : in  std_ulogic;
    clk  : in  std_ulogic;
    dmai : in ahb_dma_in_type;
    dmao : out ahb_dma_out_type;
    ahbi : in  ahb_mst_in_type;
    ahbo : out ahb_mst_out_type 
	);
end component;

--declare a component for data_swapper
component data_swapper is
  port(
    clkm : in std_logic;
    rstn : in std_logic;
    HRDATA : out std_logic_vector (31 downto 0);
    dmao : in ahb_dma_out_type
	);
end component;

----------------------------
-- the define of signal
signal dmai : ahb_dma_in_type;
signal dmao : ahb_dma_out_type;


----------------------------
-- the begin of action
begin

--instantiate state_machine component and make the connections
  u_state_machine : state_machine
  port map(
    clkm => clkm,
    rstn => rstn,
    HADDR => HADDR,
    HSIZE => HSIZE,
    HTRANS => HTRANS,
    HWDATA => HWDATA,
    HWRITE => HWRITE,
    HREADY => HREADY,
		dmai => dmai,
		dmao => dmao
  );

--instantiate the ahbmst component and make the connections
  u_ahbmst : ahbmst
  port map(
    clk => clkm,
    rst => rstn,
  	dmai => dmai,
		dmao => dmao,
		ahbi => ahbmi,
		ahbo => ahbmo
  );

--instantiate the data_swapper component and make the connections
  u_data_swapper : data_swapper
  port map(
    clkm => clkm,
    rstn => rstn,
    HRDATA => HRDATA,
    dmao => dmao
  );

end structural;