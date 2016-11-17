library IEEE;
library SegmentedSpline;
library work;
library Registers;
--use ieee.float_pkg_c.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity SS_pipe2 is
	port(
		clk:     in std_logic;
		vin_slv:  in STD_logic_vector(31 downto 0);
		
		vout: out STD_logic_vector(31 downto 0)
	);
end SS_pipe2; 

architecture ssh of SS_pipe2 is 

	subtype f32 is STD_logic_vector(31 downto 0);

component reg32 is
	generic (length : integer := 32);
	port(
		d		: IN   std_logic_vector(length -1  DOWNTO 0);
		clk, WE	: IN   std_logic;
		q		: OUT  std_logic_vector(length -1 DOWNTO 0));
END component;

component SS_pipe2_prelog is
	port(
		clk:  in  std_logic;
		vin:  in  STD_logic_vector(31 downto 0);		
		vout: out STD_logic_vector(31 downto 0)
	);
end component;

component SS_pipe2_log is
	port(
		clk:  in  std_logic;
		vin:  in  STD_logic_vector(31 downto 0);		
		vout: out STD_logic_vector(31 downto 0)
	);
end component;

component SS_pipe2_mid is
	port(
		clk:  in  std_logic;
		vin:  in  STD_logic_vector(31 downto 0);		
		vout: out STD_logic_vector(31 downto 0)
	);
end component;

component SS_pipe2_pow is
	port(
		clk:  in  std_logic;
		vin:  in  STD_logic_vector(31 downto 0);		
		vout: out STD_logic_vector(31 downto 0)
	);
end component;

	signal vin, ilog10_in, log10_in, ilog10_out, log10_out, ipow_in, pow_in, ipow_out: f32 := (others => '0');

begin
	
	PIPE_00: reg32 	generic map  (length => 32)
					port map (d => vin_slv, clk => clk, WE => '1',
							  q => vin);
	
	PRELOG: SS_pipe2_prelog port map (	clk => clk,
										vin => vin,
										vout=> ilog10_in);
	
	PIPE_01: reg32 	generic map  (length => 32)
					port map (d => ilog10_in, clk => clk, WE => '1',
							  q => log10_in);
							  
	LOGARITHM: SS_pipe2_log port map (	clk => clk,
										vin => log10_in,
										vout=> ilog10_out);
	
	PIPE_02: reg32 	generic map  (length => 32)
					port map (d => ilog10_out, clk => clk, WE => '1',
							  q => log10_out);
							  
	MIDBLOCK: SS_pipe2_mid port map (clk => clk,
									vin => log10_out,
									vout=> ipow_in);
	
	PIPE_03: reg32 	generic map  (length => 32)
					port map (d => ipow_in, clk => clk, WE => '1',
							  q => pow_in);
							  
	POWER: SS_pipe2_pow port map (clk => clk,
								 vin => pow_in,
								 vout=> ipow_out);
	
	PIPE_04: reg32 	generic map  (length => 32)
					port map (d => ipow_out, clk => clk, WE => '1',
							  q => vout);
	
	
ssh : process (clk)
	
	begin
		if rising_edge(clk) then
			--vin <= vin_slv;
			--vout <= log10_in;
		end if; -- rising_edge(clk)
	end process ssh;
end ssh;
