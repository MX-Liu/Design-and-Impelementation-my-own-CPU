-- The NEO430 Processor Project, by Stephan Nolting
-- Auto-generated memory init file (for APPLICATION)

library ieee;
use ieee.std_logic_1164.all;

package mips_application_image is

  type application_init_image_t is array (0 to 65535) of std_ulogic_vector(31 downto 0);
  constant application_init_image : application_init_image_t := (
    00000000 => x"3c010000",
    00000001 => x"3c02ffff",
    00000002 => x"3c030505",
    00000003 => x"3c040000",
    00000004 => x"0041200a",
    00000005 => x"0061200b",
    00000006 => x"0062200b",
    00000007 => x"0043200a",
    00000008 => x"00000011",
    00000009 => x"00400011",
    00000010 => x"00600011",
    00000011 => x"00002010",
    00000012 => x"00600013",
    00000013 => x"00400013",
    00000014 => x"00200013",
    00000015 => x"00002012",
    others => x"00000000"
    
  );

end mips_application_image;
