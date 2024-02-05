library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity coffee_machine is port (
	inpt : in std_logic_vector(6 downto 0);
	reset : in std_logic;
	clk	: in std_logic;
	
	low_coffee_indicators : out std_logic_vector(3 downto 0);
	coffee_type_ssegment  : out std_logic_vector(13 downto 0);
	available_quantity_ssegment : out std_logic_vector(13 downto 0);
	cup_size_ssegment 	 : out std_logic_vector(6 downto 0);
	admin_mode_indicator  : out std_logic
);
end entity coffee_machine;

architecture rtl of coffee_machine is

	-- Store the total amount of available coffee
	-- 00 -> Americano
	-- 01 -> Mocha
	-- 10 -> Espresso
	-- 11 -> Latte
	-- By default, store 30 in each
	type t_4_by_5_arr is array(0 to 3) of std_logic_vector(4 downto 0);
	signal coffee_availability : t_4_by_5_arr := ("11110", "11110", "11110", "11110");
	
	-- Store if we are in ADMIN mode
	-- By default, admin mode is disabled
	signal admin_mode : std_logic := '0';
	
	-- Store various bits of the 'input' for easier mangement
	signal coffee_type : std_logic_vector(1 downto 0);
	signal cup_size    : std_logic_vector(1 downto 0);
	signal confirm     : std_logic;
	signal dispense    : std_logic;
	
	-- Store the low coffee indicators
	signal lowi_americano : std_logic := '0';
	signal lowi_mocha     : std_logic := '0';
	signal lowi_espresso  : std_logic := '0';
	signal lowi_latte     : std_logic := '0';
	
	-- Constants for seven segments
	constant ss_A : std_logic_vector(6 downto 0) := "0001000";
	constant ss_M : std_logic_vector(6 downto 0) := "1101010";
	constant ss_O : std_logic_vector(6 downto 0) := "1000000";
	constant ss_E : std_logic_vector(6 downto 0) := "0000110";
	constant ss_S : std_logic_vector(6 downto 0) := "0010010";
	constant ss_L : std_logic_vector(6 downto 0) := "1000111";
	constant ss_dash : std_logic_vector(6 downto 0) := "0111111";
	
	component digit_decoder is
		Port( 
			sw_in : in std_logic_vector(4 downto 0);
		ss_seg_out : out std_logic_vector(13 downto 0));
	end component;
	
begin

	-- Assign internal signals to their respective outputs
	admin_mode_indicator <= admin_mode;
	
	-- Assign inputs to their respective internal singals
	
	confirm     <= inpt(5);
	dispense    <= inpt(6);
	
	-- Connect indicators to the output LEDs
	low_coffee_indicators <= (lowi_latte, lowi_espresso, lowi_mocha, lowi_americano);
	lowi_americano <= '1' when coffee_availability(0) <= "00011" else '0';
	lowi_mocha     <= '1' when coffee_availability(1) <= "00011" else '0';
	lowi_espresso  <= '1' when coffee_availability(2) <= "00011" else '0';
	lowi_latte     <= '1' when coffee_availability(3) <= "00011" else '0';
	
	-- Set the coffee type display
	with coffee_type select
		coffee_type_ssegment <= (ss_A & ss_M) when "00", -- "AM" Americano
										(ss_M & ss_O) when "01", -- "MO" Mocha
										(ss_E & ss_S) when "10", -- "ES" Espresso
										(ss_L & ss_A) when "11"; -- "LA" Latte
										
	with cup_size select
		cup_size_ssegment <= (ss_S) when "00", -- Small
									(ss_M) when "01", -- Medium
									(ss_L) when "10", -- Large
									(ss_dash) when others; -- Error
								
	seg_decoder : digit_decoder
		port map (sw_in => coffee_availability(to_integer(unsigned(coffee_type))),
					 ss_seg_out => available_quantity_ssegment);
									
	
	process (clk, reset)
	begin
		-- If the reset button is pressed, run reset code
		if rising_edge(reset) then
			
			if inpt = "1111111" then
				admin_mode <= '1';
			else
				admin_mode <= '0';
			end if;
		
		-- Otherwise, run the normal code on rising edge of the clock
		elsif rising_edge(clk) then
		
			--coffee_availability(0) <= std_logic_vector(unsigned(coffee_availability(0)) - 1);
		
			if confirm = '1' and dispense = '0' then
				coffee_type <= inpt(1 downto 0);
				cup_size    <= inpt(3 downto 2);
			end if;
			
		
			-- If we are in admin mode, process admin mode logic
			--if admin_mode = '1' then
			
			-- Otherwise, process usermode logic
			--else
			
			--end if;
		
		end if;
	end process;

end architecture rtl;