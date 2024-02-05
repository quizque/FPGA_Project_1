library ieee;
use ieee.std_logic_1164.all;

entity digit_decoder is port (
	sw_in : in std_logic_vector(4 downto 0);
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
begin
	with sw_in select
	-- Convert binary to seven segment
	ss_seg_out <= (ss_0 & ss_0) when "00000", -- 0
		(ss_0 & ss_1) when "00001", -- 1
		(ss_0 & ss_2) when "00010", -- 2
		(ss_0 & ss_3) when "00011", -- 3
		(ss_0 & ss_4) when "00100", -- 4
		(ss_0 & ss_5) when "00101", -- 5
		(ss_0 & ss_6) when "00110", -- 6
		(ss_0 & ss_7) when "00111", -- 7
		(ss_0 & ss_8) when "01000", -- 8
		(ss_0 & ss_9) when "01001", -- 9
		(ss_1 & ss_0) when "01010", -- 10
		(ss_1 & ss_1) when "01011", -- 11
		(ss_1 & ss_2) when "01100", -- 12
		(ss_1 & ss_3) when "01101", -- 13
		(ss_1 & ss_4) when "01110", -- 14
		(ss_1 & ss_5) when "01111", -- 15
		(ss_1 & ss_6) when "10000", -- 16
		(ss_1 & ss_7) when "10001", -- 17
		(ss_1 & ss_8) when "10010", -- 18
		(ss_1 & ss_9) when "10011", -- 19
		(ss_2 & ss_0) when "10100", -- 20
		(ss_2 & ss_1) when "10101", -- 21
		(ss_2 & ss_2) when "10110", -- 22
		(ss_2 & ss_3) when "10111", -- 23
		(ss_2 & ss_4) when "11000", -- 24
		(ss_2 & ss_5) when "11001", -- 25
		(ss_2 & ss_6) when "11010", -- 26
		(ss_2 & ss_7) when "11011", -- 27
		(ss_2 & ss_8) when "11100", -- 28
		(ss_2 & ss_9) when "11101", -- 29
		(ss_3 & ss_0) when "11110", -- 30
		(ss_3 & ss_1) when "11111"; -- 31
end architecture decoder;