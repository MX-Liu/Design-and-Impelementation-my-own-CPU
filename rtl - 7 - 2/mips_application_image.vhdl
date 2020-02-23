-- The NEO430 Processor Project, by Stephan Nolting
-- Auto-generated memory init file (for APPLICATION)

library ieee;
use ieee.std_logic_1164.all;

package mips_application_image is

  type application_init_image_t is array (0 to 65535) of std_ulogic_vector(31 downto 0);
  constant application_init_image : application_init_image_t := (
    00000000 => x"3402ffff",
    00000001 => x"00021400",
    00000002 => x"3442fff1",
    00000003 => x"34030011",
    00000004 => x"0043001a",
    00000005 => x"0043001b",
    00000006 => x"0062001a",
    others => x"00000000"
    
  );

end mips_application_image;
