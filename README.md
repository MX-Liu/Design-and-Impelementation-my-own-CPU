# Design-and-Impelementation-my-own-CPU


The project is based on ncremental development model.

- At rtl4, a primary five-stage pipeline is realized and the first instruction ori is implemented.

- At rtl5, logical and shift instructions are realized, besides, the nop instruction is also realized.

- At rtl6, the move instructions are implemented.

- At rtl7, Arithmetric instruction and pipeline stall are realized.

- At rtl8, jump instruction and delay slot are realized.

- At rtl9, load and store instructions are realized.


## Create Compiler Environment of the MIPS processor

Before designing this processor, I have planed it should be compatible with the architecture of MIPS32 instrustion set. Therefore, the existing GNU development tool chain under the MIPS32 architecture can be used.

1. Operation System
Ubuntu 16.04

2. Install GNU tool chain
You can download the prebuilt package, unpack it, set your path to it’s top level bin directory and begin to use it. If you unpack the package to a folder different from “/opt“, you will have to manually point to the sysroot folder using “–sysroot” command line option on each gcc invocation.

 - Download this tar file: Mips_linux_toolchain_bin-1.1.tar.bz2(https://www.mips.com/files/mips-linux-toolchain-bin-1-1-tar-bz2/);
 - Unpack the tar file to the /opt folder:
 
        cd /opt
        tar vfxj Mips_linux_toolchain_bin-1.1.tar.bz2
         
 - Add the bin folder to the path:
 Open a hidden file .bash under home folder, add this command:
 
       export PATH=/opt/mips_linux_toolchain/bin:$PATH
     
- Test
Open Terminal, input:

      mips-sde-elf-

Then, double click TAB. If it is installed succesfully, then it outputs as followed picture: 

![alt text](https://github.com/MX-Liu/Design-and-Impelementation-my-own-CPU/tree/master/pictures/mips_compiler_test.png)
                
<img src=“https://github.com/MX-Liu/Design-and-Impelementation-my-own-CPU/tree/master/pictures/mips_compiler_test.png">            
 
      

 









