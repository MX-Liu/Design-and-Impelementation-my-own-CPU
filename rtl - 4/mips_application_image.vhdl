-- The NEO430 Processor Project, by Stephan Nolting
-- Auto-generated memory init file (for APPLICATION)

library ieee;
use ieee.std_logic_1164.all;

package mips_application_image is

  type application_init_image_t is array (0 to 65535) of std_ulogic_vector(31 downto 0);
  constant application_init_image : application_init_image_t := (
    000000 => x"34011100",
    000001 => x"34020020",
    000002 => x"3403ff00",
    000003 => x"3404ffff",
    others => x"00000000"
  );

end mips_application_image;
