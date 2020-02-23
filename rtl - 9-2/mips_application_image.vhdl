-- The NEO430 Processor Project, by Stephan Nolting
-- Auto-generated memory init file (for APPLICATION)

library ieee;
use ieee.std_logic_1164.all;

package mips_application_image is

  type application_init_image_t is array (0 to 65535) of std_ulogic_vector(31 downto 0);
  constant application_init_image : application_init_image_t := (
    00000000 => x"34011234",
    00000001 => x"ac010000",
    00000002 => x"34015678",
    00000003 => x"e0010000",
    00000004 => x"8c010000",
    00000005 => x"00000000",
    00000006 => x"34010000",
    00000007 => x"c0010000",
    00000008 => x"00000000",
    00000009 => x"20210001",
    00000010 => x"e0010000",
    00000011 => x"8c010000",
    00000012 => x"0800000c",
    00000013 => x"00000000",
    others => x"00000000"
    
  );

end mips_application_image;
