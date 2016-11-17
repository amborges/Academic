------------------------------------------------
---- CHAMADA ABSTRATA DA SOMA
------------------------------------------------
library ieee;
library fplib;
library SegmentedSpline;
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use fplib.pkg_fplib.ALL;


entity soma is
	port(
		clk:  in std_logic;
		Ain:  in STD_logic_vector(31 downto 0);
		Bin:  in STD_logic_vector(31 downto 0);
		
		Cout: out STD_logic_vector(31 downto 0)
	);
end soma; 

architecture sum of soma is 
	component Add_Clk is
		generic (
			fmt: format;
			wE : positive := 8;
			wF : positive := 23;
			reg: boolean := true
		);
		port ( 
			nA : in STD_logic_vector(wE+wF+2 downto 0);
			nB : in STD_logic_vector(wE+wF+2 downto 0);
			nR : out STD_logic_vector(wE+wF+2 downto 0);
			clk: in STD_logic
    );
	end component;
	
	signal A, B, C: STD_logic_vector(33 downto 0) := (others => '0');
	
begin
	
	A <= "01" & Ain;
	B <= "01" & Bin;
	ADD: Add_Clk generic map ( fmt => FP, wE  => 8, wF  => 23, reg => false)
		port map (	nA => A,
					nB => B,
					nR => C,
					clk => clk);
	Cout <= C(31 downto 0);
	
	sum : process (clk)	begin
		if rising_edge(clk) then
			
		end if; -- rising_edge(clk)
	end process sum;
end sum;










------------------------------------------------
---- CHAMADA ABSTRATA DA SUBTRACAO
------------------------------------------------
library ieee;
library fplib;
library SegmentedSpline;
use fplib.pkg_fplib.ALL;
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity subtracao is
	port(
		clk:  in std_logic;
		Ain:  in STD_logic_vector(31 downto 0);
		Bin:  in STD_logic_vector(31 downto 0);
		
		Cout: out STD_logic_vector(31 downto 0)
	);
end subtracao; 

architecture sub of subtracao is 
	component Add_Clk is
		generic (
			fmt: format;
			wE : positive := 8;
			wF : positive := 23;
			reg: boolean := true
		);
		port ( 
			nA : in STD_logic_vector(wE+wF+2 downto 0);
			nB : in STD_logic_vector(wE+wF+2 downto 0);
			nR : out STD_logic_vector(wE+wF+2 downto 0);
			clk: in STD_logic
    );
	end component;
	
	signal A, B, B1, B2, C: STD_logic_vector(33 downto 0) := (others => '0');
	signal s : std_logic;
	
begin
	
	A <= "01" & Ain;
	B1 <= "010" & Bin(30 downto 0);
	B2 <= "011" & Bin(30 downto 0);
	s <= Bin(31);
	B <= B1 when(s = '1') else B2;
	SBT: Add_Clk generic map ( fmt => FP, wE  => 8, wF  => 23, reg => false)
		port map (	nA => A,
					nB => B,
					nR => C,
					clk => clk);
	Cout <= C(31 downto 0);
	
	sub : process (clk)	begin
		if rising_edge(clk) then
	
		end if; -- rising_edge(clk)
	end process sub;
end sub;










------------------------------------------------
---- CHAMADA ABSTRATA DA MULTIPLICACAO
------------------------------------------------
library ieee;
library fplib;
library SegmentedSpline;
use fplib.pkg_fplib.ALL;
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity multiplicacao is
	port(
		clk:  in std_logic;
		Ain:  in STD_logic_vector(31 downto 0);
		Bin:  in STD_logic_vector(31 downto 0);
		
		Cout: out STD_logic_vector(31 downto 0)
	);
end multiplicacao;

architecture mult of multiplicacao is 
	component Mul_Clk is
		generic (
			fmt: format;
			wE : positive := 8;
			wF : positive := 23;
			reg: boolean := true
		);
		port ( 
			nA : in STD_logic_vector(wE+wF+2 downto 0);
			nB : in STD_logic_vector(wE+wF+2 downto 0);
			nR : out STD_logic_vector(wE+wF+2 downto 0);
			clk: in STD_logic
    );
	end component;
	
	signal A, B, C: STD_logic_vector(33 downto 0) := (others => '0');
	
begin

	A <= "00" & Ain;
	B <= "00" & Bin;		
	MLT: Mul_Clk generic map ( fmt => FP, wE  => 8, wF  => 23, reg => false)
		port map (	nA => A,
					nB => B,
					nR => C,
					clk => clk);
	Cout <= C(31 downto 0);
	
	mult : process (clk)	begin
		if rising_edge(clk) then
			
		end if; -- rising_edge(clk)
	end process mult;
end mult;









------------------------------------------------
---- CHAMADA ABSTRATA DA DIVISAO
------------------------------------------------
library ieee;
library fplib;
library SegmentedSpline;
use fplib.pkg_fplib.ALL;
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity divisao is
	port(
		clk:  in std_logic;
		Ain:  in STD_logic_vector(31 downto 0);
		Bin:  in STD_logic_vector(31 downto 0);
		
		Cout: out STD_logic_vector(31 downto 0)
	);
end divisao; 

architecture div of divisao is 
	component Div_Clk is
		generic (
			fmt: format;
			wE : positive := 8;
			wF : positive := 23;
			reg: boolean := true
		);
		port ( 
			nA : in STD_logic_vector(wE+wF+2 downto 0);
			nB : in STD_logic_vector(wE+wF+2 downto 0);
			nR : out STD_logic_vector(wE+wF+2 downto 0);
			clk: in STD_logic
    );
	end component;
	
	signal A, B, C: STD_logic_vector(33 downto 0) := (others => '0');
	
begin

	A <= "00" & Ain;
	B <= "00" & Bin;		
	DVD: Div_Clk generic map ( fmt => FP, wE  => 8, wF  => 23, reg => false)
		port map (	nA => A,
					nB => B,
					nR => C,
					clk => clk);
	Cout <= C(31 downto 0);
	
	div : process (clk)	begin
		if rising_edge(clk) then
			
		end if; -- rising_edge(clk)
	end process div;
end div;
