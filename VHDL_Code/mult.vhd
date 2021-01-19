library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.std_logic_signed.all;
--Use ieee.std_logic_unsigned.all;

entity mult is
  generic(n : integer := 4; m : integer := 4);
	port(
	a		:in	std_logic_vector(m+n downto 0);
	b		:in	std_logic_vector(m+n downto 0);
	out_mul		:out	std_logic_vector(m+n downto 0)
	);
end entity;

architecture A of mult is 

signal temp1	 :std_logic_vector( (2*(m+n) + 1) downto 0);

begin			 	
	temp1 <=  std_logic_vector(shift_right(signed(a) * signed(b),n));
	out_mul <= std_logic_vector(temp1(m+n downto 0));
	
end architecture;

