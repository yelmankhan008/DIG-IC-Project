library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_signed.all;
Use ieee.std_logic_unsigned.all;

entity relu is
  generic(n : integer := 4; m : integer := 4);
	port( 
	     in_relu		:in	std_logic_vector(m+n downto 0);
	     out_relu		:out	std_logic_vector(m+n downto 0)
	    );
end entity;

architecture A of relu is 
begin
			 	
  out_relu <= "000000000" when signed(in_relu) < 0 else in_relu;

end architecture;