-- The MIPS Processor Project, by Mengxi Liu
-- Auto-generated memory init file (for APPLICATION)

library ieee;
use ieee.std_logic_1164.all;

package MIPS_application_image is

  type application_init_image_t is array (0 to 65535) of std_ulogic_vector(15 downto 0);
  constant application_init_image : application_init_image_t := (
    00000000 => x"34011100",
    00000001 => x"34210020",
    00000002 => x"34214400",
    00000003 => x"34210044",
    others => x"00000000"
  );

end MIPS_application_image;
