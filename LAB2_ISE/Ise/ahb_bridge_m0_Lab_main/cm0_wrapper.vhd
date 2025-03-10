----------------------------------------------------------------------
--- Group Num: 4 
--- Author: QINGYU ZHANG, SHURAN YANG, HAIBO LIAN
--- Date: 17/10/2022 
----------------------------------------------------------------------

----------------------------------------------------------------------
-- what is the difference of the AHB and AHB-Lite:
-- AHB can use multiply master
-- AHB-Lite can only have one master, multiply slave
-- The main difference is arbitration section:
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

-- The top interface for the AHB bridge
entity cm0_wrapper is
  port(
    -- Clock and Reset
    clkm : in std_logic;
    rstn : in std_logic;
    -- AHB bus signals for master
    ahbmi : in ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;
    -- LED Test signal
    led_group04 : out std_logic
  );
end;


----------------------------------------------------------------------
architecture structural of cm0_wrapper is
----------------------------
--declare a component 
-- component of CORTEXM0DS
component CORTEXM0DS is
  port(
    -- CLOCK AND RESETS
    HCLK : in std_logic;
    HRESETn : in std_logic;
    -- AHB-LITE MASTER PORT
    HADDR : out std_logic_vector (31 downto 0);
    HBURST : out std_logic_vector (2 downto 0);
    HMASTLOCK : out std_logic;
    HPROT : out std_logic_vector (3 downto 0);
    HSIZE : out std_logic_vector (2 downto 0);
    HTRANS : out std_logic_vector (1 downto 0);
    HWDATA : out std_logic_vector (31 downto 0);
    HWRITE : out std_logic;
    HRDATA : in std_logic_vector (31 downto 0);
    HREADY : in std_logic;
    HRESP : in std_logic;
    -- MISCELLANEOUS
    NMI : in std_logic;
    IRQ : in std_logic_vector (15 downto 0);
    TXEV : out std_logic;
    RXEV : in std_logic;
    LOCKUP : out std_logic;
    SYSRESETREQ : out std_logic;
    -- POWER MANAGEMENT
    SLEEPING : out std_logic
  );
end component;

-- component of ahb_bridge
component ahb_bridge is
  port(
    -- Clock and Reset 
    clkm : in std_logic;
    rstn : in std_logic;
    -- AHB Master records 
    ahbmi : in ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;
    -- ARM Cortex-M0 AHB-Lite signals 
    HADDR : in std_logic_vector (31 downto 0);
    HSIZE : in std_logic_vector (2 downto 0);
    HTRANS : in std_logic_vector (1 downto 0);
    HWDATA : in std_logic_vector (31 downto 0);
    HWRITE : in std_logic;
    HRDATA : out std_logic_vector (31 downto 0);
    HREADY : out std_logic
    
  );
end component;

-- component detectorbus can be used to test implementation
component detectorbus is
  port(
    Clock : in std_logic;
    DataBus : in std_logic_vector (31 downto 0);
    Detector : out std_logic
  );
end component;
    
----------------------------
-- the define of signal
signal HADDR : std_logic_vector (31 downto 0);
signal HSIZE : std_logic_vector (2 downto 0);
signal HTRANS : std_logic_vector (1 downto 0);
signal HWDATA : std_logic_vector (31 downto 0);
signal HWRITE : std_logic;
signal HRDATA : std_logic_vector (31 downto 0);
signal HREADY : std_logic;

-- Those input should set to 0
--signal HRESP : std_logic;
--signal NMI : std_logic;
--signal IRQ : std_logic_vector (15 downto 0);
--signal RXEV : std_logic;

----------------------------
-- the begin of action

begin
  
  -- impl of CORTEXM0DS
  u_CORTEXM0DS : CORTEXM0DS
  port map(
    HCLK => clkm,
    HRESETn => rstn,
    -- AHB-LITE MASTER PORT
    HADDR => HADDR,
    HBURST => open,
    HMASTLOCK => open,
    HPROT => open,
    HSIZE => HSIZE,
    HTRANS => HTRANS,
    HWDATA => HWDATA,
    HWRITE => HWRITE,
    HRDATA => HRDATA,
    HREADY => HREADY,
    HRESP => '0',
    -- MISCELLANEOUS
    NMI => '0',
    IRQ => "0000000000000000",
    TXEV => open,
    RXEV => '0',
    LOCKUP => open,
    SYSRESETREQ => open,
    -- POWER MANAGEMENT
    SLEEPING => open
  );
  
  -- impl of ahb_bridge
  u_ahb_bridge : ahb_bridge
  port map(
    clkm => clkm,
    rstn => rstn,
    ahbmi => ahbmi,
    ahbmo => ahbmo,
    HADDR => HADDR,
    HSIZE => HSIZE,
    HTRANS => HTRANS,
    HWDATA => HWDATA,
    HWRITE => HWRITE,
    HRDATA  => HRDATA,
    HREADY => HREADY
  );
  
  -- impl of detectorbus
  u_detectorbus : detectorbus
  port map(
    Clock => clkm,
    DataBus => HRDATA,
    Detector => led_group04
  );
  
end structural;
