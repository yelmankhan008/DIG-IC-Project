library ieee;
use std.textio.all;
use ieee.std_logic_textio.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use ieee.numeric_std.all;
library std;


entity MLP_tb is
         constant N : integer := 9;       	-- input
	       constant H : integer := 20;		     -- Hidden
	       constant M : integer := 1;		      -- Outputs
	       constant m_q : integer := 4;		    -- For Qm.n
	       constant n_q : integer := 4;       -- For Qm.n	
end MLP_tb;



architecture tb of MLP_tb is
  
  --Component Declaration
    component MLP is
      generic (
                N : integer := 9;       	-- input
	              H : integer := 20;		     -- Hidden
	              M : integer := 1;		      -- Outputs
	              m_q : integer := 4;		    -- For Qm.n
	              n_q : integer := 4       -- For Qm.n	
	            );	
	
      port (SI : in std_logic_vector( m_q+n_q downto 0 );
            SE : in std_logic;
            clk: in std_logic;
            u : in std_logic_vector(N*(m_q+n_q+1) - 1 downto 0);      -- Input figure
	          yhat : out std_logic_vector(M*(m_q+n_q+1) - 1 downto 0)); -- output
    end component;
  
  --Inputs
  signal SI :  std_logic_vector( m_q+n_q downto 0 );
  signal SE :  std_logic;
  signal clk:  std_logic;
  signal u  :  std_logic_vector(N*(m_q+n_q+1) - 1 downto 0);
  
  --Outputs
  signal yhat :  std_logic_vector(M*(m_q+n_q+1) - 1 downto 0);
  
  --Clock period definitions
  constant clk_in_period : time := 1 ns;
  constant inputSize : integer := 64516;
  
  --Signal for storing output
  type final_Output is array(1 to inputsize) of std_logic_vector(m_q +n_q downto 0);
  signal finalOutput : final_Output;
  
begin
  
  uut : MLP port map(SI=>SI,SE=>SE,clk=>clk,u=>u,yhat=>yhat);
  
  --Clock process definitions
  clk_in_process : process
  begin
      clk <= '1';
      wait for clk_in_period/2;
      clk <= '0';
      wait for clk_in_period/2;     
  end process;
  
  read_it: process is
    file txt_file   : text;
    variable line_v : line;
    variable hidden_wts : std_logic_vector(M*(m_q+n_q+1) - 1 downto 0);
    variable input_wts : std_logic_vector(M*(m_q+n_q+1) - 1 downto 0); --Should be N*
    variable u_input : std_logic_vector(N*(m_q+n_q+1) - 1 downto 0);
  
  begin
    

    wait for clk_in_period*10;
    
    SE <= '1';
    
    --wait for clk_in_period*10;
    
    file_open(txt_file, "/home/yxk7912/Downloads/inputWeights.txt", read_mode);
    
    for i in 1 to (N+1)*H loop
    
      readline(txt_file, line_v);
      read(line_v, input_wts);
      SI <= input_wts;
      wait for clk_in_period;
      --end if;
    end loop;
    
    file_close(txt_file);
    
  --wait for clk_in_period*10;
    
   SE <= '0';
  
   -------------------------------------------------------------
   wait for clk_in_period*100;
   -------------------------------------------------------------
    
   SE <= '1';
  
    file_open(txt_file, "/home/yxk7912/Downloads/hiddenWeights.txt", read_mode);
    
    for i in 1 to (H+1)*M loop
      readline(txt_file, line_v);
      read(line_v, hidden_wts);
      SI <= hidden_wts;
      wait for clk_in_period;
      --end if;
    end loop;
    
    file_close(txt_file);  
   
   --wait for clk_in_period*10;
    
    SE <= '0';
    
   -------------------------------------------------------------
   wait for clk_in_period*100;
   -------------------------------------------------------------
   
    --SE <= '1';
    
    file_open(txt_file, "/home/yxk7912/Downloads/input1.txt", read_mode);
    
    for i in 1 to inputSize loop
    
      readline(txt_file, line_v);
      read(line_v, u_input);
      u <= u_input;
      wait for 10*clk_in_period;
      finalOutput(i) <= yhat;
      
    end loop;
    
    file_close(txt_file);  
   
   --wait for clk_in_period*10;
    
    --SE <= '0';

    file_open(txt_file, "/home/yxk7912/Downloads/finalOutput.txt", write_mode);
    for i in 1 to inputSize loop
      write(line_v, finalOutput(i));
      writeline(txt_file,line_v);
    end loop;
    file_close(txt_file);

    wait;
  end process;
end tb;