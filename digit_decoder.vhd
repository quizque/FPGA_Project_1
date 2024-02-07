library ieee;
use ieee.std_logic_1164.all;

entity digit_decoder is port (
	sw_in : in std_logic_vector(4 downto 0);
	enabled : in std_logic;
	ss_seg_out : out std_logic_vector(13 downto 0)
);
end entity digit_decoder;

architecture decoder of digit_decoder is
	constant ss_0 : std_logic_vector(6 downto 0) := "1000000";
	constant ss_1 : std_logic_vector(6 downto 0) := "1111001";
	constant ss_2 : std_logic_vector(6 downto 0) := "0100100";
	constant ss_3 : std_logic_vector(6 downto 0) := "0110000";
	constant ss_4 : std_logic_vector(6 downto 0) := "0011001";
	constant ss_5 : std_logic_vector(6 downto 0) := "0010010";
	constant ss_6 : std_logic_vector(6 downto 0) := "0000010";
	constant ss_7 : std_logic_vector(6 downto 0) := "1111000";
	constant ss_8 : std_logic_vector(6 downto 0) := "0000000";
	constant ss_9 : std_logic_vector(6 downto 0) := "0011000";
	constant ss_dash : std_logic_vector(6 downto 0) := "0111111";
begin
	with (enabled & sw_in) select
	-- Convert binary to seven segment
	ss_seg_out <= (ss_0 & ss_0) when "100000", -- 0
		(ss_0 & ss_1) when "100001", -- 1
		(ss_0 & ss_2) when "100010", -- 2
		(ss_0 & ss_3) when "100011", -- 3
		(ss_0 & ss_4) when "100100", -- 4
		(ss_0 & ss_5) when "100101", -- 5
		(ss_0 & ss_6) when "100110", -- 6
		(ss_0 & ss_7) when "100111", -- 7
		(ss_0 & ss_8) when "101000", -- 8
		(ss_0 & ss_9) when "101001", -- 9
		(ss_1 & ss_0) when "101010", -- 10
		(ss_1 & ss_1) when "101011", -- 11
		(ss_1 & ss_2) when "101100", -- 12
		(ss_1 & ss_3) when "101101", -- 13
		(ss_1 & ss_4) when "101110", -- 14
		(ss_1 & ss_5) when "101111", -- 15
		(ss_1 & ss_6) when "110000", -- 16
		(ss_1 & ss_7) when "110001", -- 17
		(ss_1 & ss_8) when "110010", -- 18
		(ss_1 & ss_9) when "110011", -- 19
		(ss_2 & ss_0) when "110100", -- 20
		(ss_2 & ss_1) when "110101", -- 21
		(ss_2 & ss_2) when "110110", -- 22
		(ss_2 & ss_3) when "110111", -- 23
		(ss_2 & ss_4) when "111000", -- 24
		(ss_2 & ss_5) when "111001", -- 25
		(ss_2 & ss_6) when "111010", -- 26
		(ss_2 & ss_7) when "111011", -- 27
		(ss_2 & ss_8) when "111100", -- 28
		(ss_2 & ss_9) when "111101", -- 29
		(ss_3 & ss_0) when "111110", -- 30
		(ss_3 & ss_1) when "111111", -- 31
		(ss_dash & ss_dash) when others;
		
end architecture decoder;