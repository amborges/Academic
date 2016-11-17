library IEEE;
library SegmentedSpline;
library Registers;
--use ieee.float_pkg_c.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity SS_pipe2_f2i is
	port(
		clk:     in std_logic;
		vin:  in STD_logic_vector(31 downto 0);
		
		vout: out STD_logic_vector(31 downto 0)
	);
end SS_pipe2_f2i; 

architecture ssh of SS_pipe2_f2i is 

	--type f32 is array (33 downto 0) of STD_logic_vector;
	subtype f32 is STD_logic_vector(31 downto 0);
	
	signal pow_add1, pow_add2, pow_add3                               : f32;
	signal pow_sub1, pow_sub2, pow_sub3, pow_sub4, pow_sub5           : f32;
	signal pow_mult1, pow_mult2, pow_mult3                            : f32;
	signal pow_div1                                                   : f32;
	signal pow_demux1                                                 : bit;     
	signal pow_demux2, pow_demux3, pow_demux4, pow_demux5             : f32;
	signal pow_f2i_in                                                 : f32;
	signal pow_out  : f32;
	signal pow_f2i_slv : f32;
	signal f2i_00      : f32 := (others => '0');
	signal f2i_01      : f32 := (others => '0');
	signal f2i_02      : f32 := (others => '0');
	signal f2i_03      : f32 := (others => '0');
	signal f2i_04      : f32 := (others => '0');
	signal f2i_05      : f32 := (others => '0');
	signal f2i_06      : f32 := (others => '0');
	signal f2i_07      : f32 := (others => '0');
	signal f2i_08      : f32 := (others => '0');
	signal f2i_09      : f32 := (others => '0');
	signal f2i_10      : f32 := (others => '0');
	signal f2i_11      : f32 := (others => '0');
	signal f2i_12      : f32 := (others => '0');
	signal f2i_13      : f32 := (others => '0');
	signal f2i_14      : f32 := (others => '0');
	signal f2i_15      : f32 := (others => '0');
	signal f2i_16      : f32 := (others => '0');
	signal f2i_17      : f32 := (others => '0');
	signal f2i_18      : f32 := (others => '0');
	signal f2i_19      : f32 := (others => '0');
	signal f2i_20      : f32 := (others => '0');
	signal f2i_21      : f32 := (others => '0');
	signal f2i_22      : f32 := (others => '0');
	signal f2i_23      : f32 := (others => '0');
	signal f2i_24      : f32 := (others => '0');
	signal f2i_25      : f32 := (others => '0');
	signal f2i_26      : f32 := (others => '0');
	signal f2i_27      : f32 := (others => '0');
	signal f2i_28      : f32 := (others => '0');
	signal f2i_29      : f32 := (others => '0');
	signal f2i_30      : f32 := (others => '0');
	signal f2i_31      : f32 := (others => '0');
	signal f2i_or1     : STD_logic_vector( 4 downto 0) := (others => '0');
	signal f2i_e       : STD_logic_vector(30 downto 23) := (others => '0');
	signal f2i_m       : STD_logic_vector(22 downto 0) := (others => '0');
	signal f2i_or2     : f32 := (others => '0');
	signal f2i_demux1  : f32 := (others => '0');
	signal f2i_demux2  : f32 := (others => '0');
	signal f2i_demux3  : f32;
	signal f2i_f32     : f32;

	constant zero        : f32 := "00000000000000000000000000000000";
	constant three       : f32 := "01000000010000000000000000000000";
	constant one         : f32 := "00111111100000000000000000000000";
	constant two         : f32 := "01000000000000000000000000000000";
	constant four        : f32 := "01000000100000000000000000000000";
	constant pc2         : f32 := "01000000010101001001101001111000";
	constant five        : f32 := "01000000101000000000000000000000";
	constant six         : f32 := "01000000110000000000000000000000";
	constant seven       : f32 := "01000000111000000000000000000000";
	constant eight       : f32 := "01000001000000000000000000000000";
	constant nine        : f32 := "01000001000100000000000000000000";
	constant ten         : f32 := "01000001001000000000000000000000";
	constant eleven      : f32 := "01000001001100000000000000000000";
	constant twelve      : f32 := "01000001010000000000000000000000";
	constant thirteen    : f32 := "01000001010100000000000000000000";
	constant pc3         : f32 := "01000000100110101111010111111000";
	constant pc4         : f32 := "01000001110111011101001011111110";
	constant pc5         : f32 := "00111111101111101011110010001101";
	constant pc6         : f32 := "01000010111100101000110001010101";
	constant pc7         : f32 := "01001011000000000000000000000000";

begin
		
	-- FLOAT TO INT --
	pow_f2i_slv <= vin;
	f2i_00(          0) <= pow_f2i_slv(22          );
	f2i_01( 1 downto 0) <= pow_f2i_slv(22 downto 21);
	f2i_02( 2 downto 0) <= pow_f2i_slv(22 downto 20);
	f2i_03( 3 downto 0) <= pow_f2i_slv(22 downto 19);
	f2i_04( 4 downto 0) <= pow_f2i_slv(22 downto 18);
	f2i_05( 5 downto 0) <= pow_f2i_slv(22 downto 17);
	f2i_06( 6 downto 0) <= pow_f2i_slv(22 downto 16);
	f2i_07( 7 downto 0) <= pow_f2i_slv(22 downto 15);
	f2i_08( 8 downto 0) <= pow_f2i_slv(22 downto 14);
	f2i_09( 9 downto 0) <= pow_f2i_slv(22 downto 13);
	f2i_10(10 downto 0) <= pow_f2i_slv(22 downto 12);
	f2i_11(11 downto 0) <= pow_f2i_slv(22 downto 11);
	f2i_12(12 downto 0) <= pow_f2i_slv(22 downto 10);
	f2i_13(13 downto 0) <= pow_f2i_slv(22 downto  9);
	f2i_14(14 downto 0) <= pow_f2i_slv(22 downto  8);
	f2i_15(15 downto 0) <= pow_f2i_slv(22 downto  7);
	f2i_16(16 downto 0) <= pow_f2i_slv(22 downto  6);
	f2i_17(17 downto 0) <= pow_f2i_slv(22 downto  5);
	f2i_18(18 downto 0) <= pow_f2i_slv(22 downto  4);
	f2i_19(19 downto 0) <= pow_f2i_slv(22 downto  3);
	f2i_20(20 downto 0) <= pow_f2i_slv(22 downto  2);
	f2i_21(21 downto 0) <= pow_f2i_slv(22 downto  1);
	f2i_22(22 downto 0) <= pow_f2i_slv(22 downto  0);
	f2i_23(23 downto 1) <= pow_f2i_slv(22 downto  0);
	f2i_24(24 downto 2) <= pow_f2i_slv(22 downto  0);
	f2i_25(25 downto 3) <= pow_f2i_slv(22 downto  0);
	f2i_26(26 downto 4) <= pow_f2i_slv(22 downto  0);
	f2i_27(27 downto 5) <= pow_f2i_slv(22 downto  0);
	f2i_28(28 downto 6) <= pow_f2i_slv(22 downto  0);
	f2i_29(29 downto 7) <= pow_f2i_slv(22 downto  0);
	f2i_30(30 downto 8) <= pow_f2i_slv(22 downto  0);
	f2i_31(31 downto 9) <= pow_f2i_slv(22 downto  0);
	f2i_or1(4 downto 0) <= pow_f2i_slv(27 downto 23);
	f2i_demux1 <= f2i_00 when(f2i_or1 = "00000") else
							  f2i_01 when(f2i_or1 = "00001") else
							  f2i_02 when(f2i_or1 = "00010") else
							  f2i_03 when(f2i_or1 = "00011") else
							  f2i_04 when(f2i_or1 = "00100") else
							  f2i_05 when(f2i_or1 = "00101") else
							  f2i_06 when(f2i_or1 = "00110") else
							  f2i_07 when(f2i_or1 = "00111") else
							  f2i_08 when(f2i_or1 = "01000") else
							  f2i_09 when(f2i_or1 = "01001") else
							  f2i_10 when(f2i_or1 = "01010") else
							  f2i_11 when(f2i_or1 = "01011") else
							  f2i_12 when(f2i_or1 = "01100") else
							  f2i_13 when(f2i_or1 = "01101") else
							  f2i_14 when(f2i_or1 = "01110") else
							  f2i_15 when(f2i_or1 = "01111") else
							  f2i_16 when(f2i_or1 = "10000") else
							  f2i_17 when(f2i_or1 = "10001") else
							  f2i_18 when(f2i_or1 = "10010") else
							  f2i_19 when(f2i_or1 = "10011") else
							  f2i_20 when(f2i_or1 = "10100") else
							  f2i_21 when(f2i_or1 = "10101") else
							  f2i_22 when(f2i_or1 = "10110") else
							  f2i_23 when(f2i_or1 = "10111") else
							  f2i_24 when(f2i_or1 = "11000") else
							  f2i_25 when(f2i_or1 = "11001") else
							  f2i_26 when(f2i_or1 = "11010") else
							  f2i_27 when(f2i_or1 = "11011") else
							  f2i_28 when(f2i_or1 = "11100") else
							  f2i_29 when(f2i_or1 = "11101") else
							  f2i_30 when(f2i_or1 = "11110") else
							  f2i_31;-- when(f2i_or1 = "11111")
	f2i_demux2(31 downto 0)	 <= "00000000000000000000000000000010" 
										when(f2i_or1 = "00000") else
								"00000000000000000000000000000100" 
										when(f2i_or1 = "00001") else 
								"00000000000000000000000000001000" 
										when(f2i_or1 = "00010") else 
								"00000000000000000000000000010000" 
										when(f2i_or1 = "00011") else 
								"00000000000000000000000000100000" 
										when(f2i_or1 = "00100") else 
								"00000000000000000000000001000000" 
										when(f2i_or1 = "00101") else 
								"00000000000000000000000010000000" 
										when(f2i_or1 = "00110") else 
								"00000000000000000000000100000000" 
										when(f2i_or1 = "00111") else 
								"00000000000000000000001000000000" 
										when(f2i_or1 = "01000") else 
								"00000000000000000000010000000000" 
										when(f2i_or1 = "01001") else 
								"00000000000000000000100000000000" 
										when(f2i_or1 = "01010") else 
								"00000000000000000001000000000000" 
										when(f2i_or1 = "01011") else 
								"00000000000000000010000000000000" 
										when(f2i_or1 = "01100") else 
								"00000000000000000100000000000000" 
										when(f2i_or1 = "01101") else 
								"00000000000000001000000000000000" 
										when(f2i_or1 = "01110") else 
								"00000000000000010000000000000000" 
										when(f2i_or1 = "01111") else 
								"00000000000000100000000000000000" 
										when(f2i_or1 = "10000") else 
								"00000000000001000000000000000000" 
										when(f2i_or1 = "10001") else 
								"00000000000010000000000000000000" 
										when(f2i_or1 = "10010") else 
								"00000000000100000000000000000000" 
										when(f2i_or1 = "10011") else 
								"00000000001000000000000000000000" 
										when(f2i_or1 = "10100") else 
								"00000000010000000000000000000000" 
										when(f2i_or1 = "10101") else 
								"00000000100000000000000000000000" 
										when(f2i_or1 = "10110") else 
								"00000001000000000000000000000000" 
										when(f2i_or1 = "10111") else 
								"00000010000000000000000000000000" 
										when(f2i_or1 = "11000") else 
								"00000100000000000000000000000000" 
										when(f2i_or1 = "11001") else 
								"00001000000000000000000000000000" 
										when(f2i_or1 = "11010") else 
								"00010000000000000000000000000000" 
										when(f2i_or1 = "11011") else 
								"00100000000000000000000000000000" 
										when(f2i_or1 = "11100") else 
								"01000000000000000000000000000000" 
										when(f2i_or1 = "11101") else 
								"10000000000000000000000000000000" 
										when(f2i_or1 = "11110") else  
								"00000000000000000000000000000001";-- when(f2i_or1 = "11111")
	f2i_or2 <= f2i_demux1 or f2i_demux2;
	f2i_e   <= pow_f2i_slv(30 downto 23);
	f2i_m   <= pow_f2i_slv(22 downto  0);
	vout <= zero when ((f2i_e="00000000")and (f2i_m="00000000000000000000000")) else
			one  when ( f2i_e="01111111") else
			f2i_or2; 
				-- FLOAT TO INT --

ssh : process (clk)	
	begin
		if rising_edge(clk) then
			
		end if; -- rising_edge(clk)
	end process ssh;
end ssh;
