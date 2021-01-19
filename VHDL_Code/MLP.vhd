library ieee;
Use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_signed.all;
library std;



entity MLP is
generic (
         N : integer := 9;       	-- input
	       H : integer := 20;		     -- Hidden
	       M : integer := 1;		      -- Outputs
	       m_q : integer := 4;		    -- For Qm.n
	       n_q : integer := 4       -- For Qm.n	
	       );	
	
  port (SI : in std_logic_vector( m_q+n_q downto 0 );
        --SI : in std_logic;
        SE : in std_logic;
        clk: in std_logic;
        u : in std_logic_vector(N*(m_q+n_q+1) - 1 downto 0);      -- Input figure
	      yhat : out std_logic_vector(M*(m_q+n_q+1) - 1 downto 0)); -- output
  end MLP;

architecture Behavioral of MLP is

  -- Component Declaration
  component mult is
	 port(
	 a		:in	std_logic_vector(m_q+n_q downto 0);
	 b		:in	std_logic_vector(m_q+n_q downto 0);
	 out_mul		:out	std_logic_vector(m_q+n_q downto 0)
	 );
  end component;
  
  
  component relu is
	port( 
	     in_relu		:in	std_logic_vector(m_q+n_q downto 0);
	     out_relu		:out	std_logic_vector(m_q+n_q downto 0)
	    );
  end component;
  
  -- Signal Declaration
  type input_wts is array(1 to (N+1)*H ) of std_logic_vector(m_q+n_q downto 0);	--Input layer weights (Should be 200)
  type for_each_node_in_input is array(1 to N+1) of std_logic_vector(m_q+n_q downto 0);
  type for_each_node_in_hidden is array(1 to H) of for_each_node_in_input;
  type hidden_wts is array(1 to (H+1)*M ) of std_logic_vector(m_q+n_q downto 0);	--Hidden layer weights (Should be 21)
  type hidden_nodes is array(1 to H*M ) of std_logic_vector(m_q +n_q downto 0);	--Hidden nodes (i.e. input weights * input nodes and then activated)
  type for_each_activated_hidden_node is array(1 to H+1) of std_logic_vector(m_q+n_q downto 0);
  type hidden_to_output is array(1 to M) of for_each_activated_hidden_node;
  type output_nodes is array(1 to M) of std_logic_vector(m_q +n_q downto 0);
  
  type sum is array(1 to (N+1)+1) of std_logic_vector(m_q +n_q downto 0); 
  type add_input_mult is array(1 to H) of sum;

  type sum_hidden is array(1 to (H+1)+1) of std_logic_vector(m_q +n_q downto 0); 
  type add_hidden_mult is array(1 to M) of sum_hidden;
  
  --signal input_layer_mult : input_wts;       --To save the result of multiplication from input layer and input wts.
  signal inputWeights          : input_wts;
  signal input_layer_mult      : for_each_node_in_hidden;
  signal hidden_layer_mult     : hidden_to_output;
  signal hiddenWeights         : hidden_wts;
  signal bias                  : std_logic_vector(m_q+n_q downto 0) := "000010000";
  signal hiddenNodes           : hidden_nodes;
  signal hiddenNodes_Activated : hidden_nodes;
  signal outputNodes           : output_nodes;
  signal outputNodes_Activated : output_nodes;
  --signal u_sig  : std_logic_vector(N*(m_q+n_q+1) - 1 downto 0);
  signal input_add : add_input_mult := (others => (others => "000000000"));  
  signal hidden_add : add_hidden_mult := (others => (others => "000000000"));
  signal endRead : std_logic := '0';
  signal inputCounter : integer := 1;
  
begin
	
	--Input Layer
	process(clk,SE) is
    begin
      if (rising_edge(clk)) then
        if (endRead = '0' and SE = '1') then
          if inputCounter < (N+1)*H + 1 then              -- < 201 i.e. 200
            inputWeights(inputCounter) <= SI;
            inputCounter <= inputCounter + 1;      
          elsif inputCounter < (N+1)*H +(H+1)*M + 1 then  -- 201 to 221
            hiddenWeights(inputCounter - (N+1)*H) <= SI;
            inputCounter <= inputCounter + 1;
          else 
            endRead <= '1'; 
          end if;
        end if;
      end if;
  end process; 
  
  
	--Loop to generate multiplier for input layer
	Mult_Node: for i in 1 to H generate
	  Mult_Wts_For_Each_Node: for j in 1 to N+1 generate
	    
	        Bias_Node : if j = 1 generate
	                       mult_bias : entity work.mult port map( a => bias,
	                                                              b => inputWeights((N+1)*(i-1) + j), ---Since every 10th entry in input wts is weight for bias.
	                                                              out_mul => input_layer_mult(i)(j) );
	        end generate Bias_Node;
	        
	        Rest_Nodes : if j > 1 generate
	                       mult_rest : entity work.mult port map( a => u( (N*(m_q+n_q+1) - (j-2)*(m_q+n_q+1) - 1) downto ( (N-1)*(m_q+n_q+1) - (j-2)*(m_q+n_q+1)) ),
	                                                              b => inputWeights((N+1)*(i-1) + j),
	                                                              --out_mul => input_layer_mult( ((N+1)*(i-1)) + j ) );
	                                                              out_mul => input_layer_mult(i)(j) );
	        end generate Rest_Nodes;
	    
	 end generate Mult_Wts_For_Each_Node;
	end generate Mult_Node;
	
	
	Add1: for i in 1 to H generate
	  Add2: for j in 1 to N+1 generate
	       input_add(i)(j+1) <=  std_logic_vector( signed(input_add(i)(j)) + signed(input_layer_mult(i)(j)) );
	       addAssign : if j = N+1 generate
	         hiddenNodes(i) <= input_add(i)(j+1);
	       end generate addAssign;
	 end generate Add2;
	end generate Add1;
	

	--Loop to generate ReLU for input layer
	Relu_Node: for i in 1 to H generate
	               relu: entity work.relu port map( in_relu => hiddenNodes(i),
	                                                out_relu => hiddenNodes_Activated(i));
  end generate Relu_Node;
	
	
	--Loop to generate multiplier for hidden layer
	Mult_Node1: for i in 1 to M generate
	  Mult_Wts_For_Each_Node1: for j in 1 to H+1 generate
	    
	        Bias_Node1 : if j = 1 generate
	                       mult_bias : entity work.mult port map( a => bias,
	                                                              b => hiddenWeights((H+1)*(i-1) + j), ---Since every 10th entry in input wts is weight for bias.
	                                                              out_mul => hidden_layer_mult(i)(j) );
	        end generate Bias_Node1;
	        	        
	        Rest_Nodes1 : if j > 1 generate
	                       mult_rest : entity work.mult port map( a => hiddenNodes_Activated(i),
	                                                              b => hiddenWeights((H+1)*(i-1) + j),
	                                                              out_mul => hidden_layer_mult(i)(j) );
	        end generate Rest_Nodes1;
	    
	 end generate Mult_Wts_For_Each_Node1;
	end generate Mult_Node1;
	
	
	--Loop to add product of hidden layer and hidden weights
	Add3: for i in 1 to M generate
	  Add4: for j in 1 to H+1 generate
	       hidden_add(i)(j+1) <=  std_logic_vector( signed(hidden_add(i)(j)) + signed(hidden_layer_mult(i)(j)) );
	       
	       addAssignHid : if j = H+1 generate
	         outputNodes(i) <= hidden_add(i)(j+1);
	       end generate addAssignHid;
	 
	 end generate Add4;
	end generate Add3;
	
	
	--Loop to generate ReLU for hidden layer
	Relu_Node1: for i in 1 to M generate
	               relu: entity work.relu port map( in_relu => outputNodes(i),
	                                                out_relu => outputNodes_Activated(i));
  end generate Relu_Node1;
	
	
	--Loop throught outputNodes_Activated and add each entry to yhat (where yhat is a long st logic vector)
	process(outputNodes_Activated) is
	  begin
	  for i in outputNodes_Activated'range loop                                                             ---Not sure if i starts at 0 or 1
	     	yhat( (M*(m_q+n_q+1) - (i-1)*(m_q+n_q+1) - 1)  downto ( (M-1)*(m_q+n_q+1) - (i-1)*(m_q+n_q+1)) ) <= outputNodes_Activated(i);    --Assuming i=1
	  end loop;
	end process;
end Behavioral;

