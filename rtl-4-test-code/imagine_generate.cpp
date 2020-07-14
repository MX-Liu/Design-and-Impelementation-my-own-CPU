#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {

  if (argc != 4) {
  	printf("<<< MIPS executable image generator >>>\n"
	       "Three arguments are required.\n"
	       "1st: Option\n"
	       " -app_bin : Generate application executable binary (with header!) \n"
	       " -app_img : Generate application raw executable memory image (text file, no header!)\n"
	       " -bld_img : Generate bootloader raw executable memory image (text file, no header!)\n"
		     "2nd: Input file (raw binary image)\n"
		     "3rd: Output file (as selected)\n");
  	return 1;
  }

  FILE *input, *output;
  unsigned char buffer[2];
  uint16_t buffer_t[2];
  char tmp_string[512];
  uint32_t tmp = 0, size = 0, checksum = 0;
  int i = 0;
  int option = 0;

  if (strcmp(argv[1], "-app_bin") == 0)
    option = 1;
  else if (strcmp(argv[1], "-app_img") == 0)
    option = 2;
  else if (strcmp(argv[1], "-bld_img") == 0)
    option = 3;
  else {
  	printf("Invalid option!");
  	return 2;
  }

  // open input file
  input = fopen(argv[2], "rb");
  if(input == NULL){
    printf("Input file error!");
    return 3;
  }

  // open output file
  output = fopen(argv[3], "wb");
  if(output == NULL){
    printf("Output file error!");
    return 4;
  }



// ------------------------------------------------------------
// Generate APPLICATION's executable memory init file (no header!!!)
// ------------------------------------------------------------
  if (option == 2) {

	// header
    sprintf(tmp_string, "-- The MIPS Processor Project, by Mengxi Liu\r\n"
	 					"-- Auto-generated memory init file (for APPLICATION)\r\n"
						"\r\n"
						"library ieee;\r\n"
						"use ieee.std_logic_1164.all;\r\n"
						"\r\n"
						"package MIPS_application_image is\r\n"
						"\r\n"
						"  type application_init_image_t is array (0 to 65535) of std_ulogic_vector(15 downto 0);\r\n"
						"  constant application_init_image : application_init_image_t := (\r\n");
    fputs(tmp_string, output);

	// data
    buffer[0] = 0;
    buffer[1] = 0;
	buffer[2] = 0;
	buffer[3] = 0;
	
    i = 0;
    while(fread(&buffer, sizeof(unsigned char), 4, input) != 0) {
      
	  tmp = (((uint32_t)buffer[0] << 24) | (buffer[1]<<16)| (buffer[2]<<8)| buffer[3]);
	  
      sprintf(tmp_string, "    %08d => x\"%08x\",\r\n", i, tmp);
      fputs(tmp_string, output);
      buffer[0] = 0;
      buffer[1] = 0;
	  buffer[2] = 0;
	  buffer[3] = 0; 
      i++;
    }
	

    sprintf(tmp_string, "    others => x\"00000000\"\r\n");
    fputs(tmp_string, output);

	// end
    sprintf(tmp_string, "  );\r\n"
						"\r\n"
						"end MIPS_application_image;\r\n");
    fputs(tmp_string, output);
  }


  fclose(input);
  fclose(output);

  return 0;
}

