-- Quando itera, estou pulando de ler a primeira linha

LIBRARY ieee;
	USE ieee.std_logic_1164.ALL;
	USE ieee.std_logic_unsigned.all;
	USE ieee.numeric_std.ALL;
	USE std.textio.ALL;
library SegmentedSpline;
	
ENTITY tester IS
    
END tester;

ARCHITECTURE behavior OF tester IS 

component SS_pipe2 is
	port(
		clk:		in std_logic;
		vin_slv: 	in STD_logic_vector(31 downto 0);
		
		vout:	out STD_logic_vector(31 downto 0)
	); 
end component;

	function str_to_stdvec(inp: string) return std_logic_vector is
		variable temp: std_logic_vector(inp'range);
		begin
			for i in inp'range loop
				if (inp(i) = '1') then
					temp(i) := '1';
				elsif (inp(i) = '0') then
					temp(i) := '0';
				end if;
			end loop;
		return temp;
	end function str_to_stdvec;

	function stdvec_to_str(inp: std_logic_vector) return string is
		variable temp: string(inp'left+1 downto 1);
		begin
			for i in inp'reverse_range loop
				if (inp(i) = '1') then
					temp(i+1) := '1';
				elsif (inp(i) = '0') then
					temp(i+1) := '0';
				end if;
			end loop;
		return temp;
	end function stdvec_to_str;

	--Inputs
	
	
	SIGNAL clk :  std_logic := '0';
	SIGNAL reset :  std_logic := '0';

	--signal a: float32;--std_logic_vector(31 downto 0);
	--signal result_log : float32;--std_logic_vector(32 downto 0);

	signal a: std_logic_vector(31 downto 0);
	signal result_log : std_logic_vector(31 downto 0);

	
	file filea, out_log: text;
	
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut1: SS_pipe2 port map(clk, a, result_log);
	
	
	clock :PROCESS 
	BEGIN
  		clk <= '1', '0' AFTER 100 ns;
  		WAIT FOR 200 ns;
	END PROCESS;
	
	   
	reset <= '1','0' after 300 ns;
		
	stimulus_in: process 
	variable inline: line;
	--
	variable out0: std_logic_vector(32 downto 1);
	variable str_out0: string(33 downto 1);
	variable outline: line;	
		--
	variable sample: string(32 downto 1);
	variable contaloop: integer;
	variable contawhile: integer;
	
    	begin
    		

		--FILE_OPEN(filea, "filea.txt", READ_MODE);
		FILE_OPEN(filea, "simpleIN100.txt", READ_MODE);
		FILE_OPEN(out_log, "simpleOUT.txt", WRITE_MODE);
	
		--wait until (reset = '0');
		while not endfile(filea) loop
			readline(filea, inline);
			read(inline, sample);
			--a <= to_float(str_to_stdvec(sample));
			a <= str_to_stdvec(sample);
	
			wait until(clk'event and clk = '1');
			wait until(clk'event and clk = '1');
			--wait until(clk'event and clk = '1');
			--wait until(clk'event and clk = '1');
	
			--1
			--out0 := to_std_logic_vector(result_log);
			out0 := result_log;
			str_out0 := stdvec_to_str(out0);
			write(outline, str_out0);
			writeline(out_log, outline);
			contaloop := contaloop + 1;
		end loop;
		
		file_close(filea);
		file_close(out_log);
		writeline(out_log, outline); --vai dar erro, mas para o processo
	end process;
END;
