-- The NEO430 Processor Project, by Stephan Nolting
-- Auto-generated memory init file (for APPLICATION)

library ieee;
use ieee.std_logic_1164.all;

package mips_application_image is

  type application_init_image_t is array (0 to 65535) of std_ulogic_vector(31 downto 0);
  constant application_init_image : application_init_image_t := (
    00000000 => x"3c020404",
    00000001 => x"34420404",
    00000002 => x"34070007",
    00000003 => x"34050005",
    00000004 => x"34080008",
    00000005 => x"0000000f",
    00000006 => x"00021200",
    00000007 => x"00e21004",
    00000008 => x"00021202",
    00000009 => x"00a21006",
    00000010 => x"00000000",
    00000011 => x"000214c0",
    00000012 => x"00000040",
    00000013 => x"00021403",
    00000014 => x"01021007",
    others => x"00000000"
    
  );

end mips_application_image;
