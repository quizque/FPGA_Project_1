library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity coffee_machine is port (
	i_input : in std_logic_vector(6 downto 0);
	i_reset : in std_logic;
	i_clk	: in std_logic;
	
	o_low_coffee_indicators : out std_logic_vector(3 downto 0);
	o_coffee_type           : out std_logic_vector(13 downto 0);
	o_available_quantity    : out std_logic_vector(13 downto 0);
	o_cup_size    : out std_logic_vector(6 downto 0);
	o_admin_mode  : out std_logic
);
end entity coffee_machine;

architecture rtl of coffee_machine is

	-----------------------------------------------------------------
	--- External Connections
	---
	
	-- Store various bits of the 'input' for easier mangement
	signal sw_coffee_type : std_logic_vector(1 downto 0);
	signal sw_cup_size    : std_logic_vector(1 downto 0);
	signal sw_confirm     : std_logic;
	signal sw_dispense    : std_logic;
	
	-- Store the low coffee indicators
	signal led_low_americano : std_logic := '0';
	signal led_low_mocha     : std_logic := '0';
	signal led_low_espresso  : std_logic := '0';
	signal led_low_latte     : std_logic := '0';
	
	
	-----------------------------------------------------------------
	--- Internal Variables
	---
	
	-- Store the total amount of available coffee
	-- 00 -> Americano
	-- 01 -> Mocha
	-- 10 -> Espresso
	-- 11 -> Latte
	-- By default, store 30 in each
	-- It is required to make an array type for 2d arrays in VHDL
	type t_4_by_5_arr is array(0 to 3) of std_logic_vector(4 downto 0);
	signal coffee_availability : t_4_by_5_arr := ("11110", "11110", "11110", "11110");
	
	-- Store if we are in ADMIN mode
	-- By default, admin mode is disabled
	signal admin_mode : std_logic := '0';
	
	-- Confirm state enabled
	signal confirm : std_logic := '0';
	
	-- Coffee type 
	signal coffee_type : std_logic_vector(1 downto 0);
	
	-- Cup type 
	signal cup_size : std_logic_vector(1 downto 0);
	
	-----------------------------------------------------------------
	--- Constants
	---
	
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
			enabled : in std_logic;
			ss_seg_out : out std_logic_vector(13 downto 0));
	end component;
	
begin

	-----------------------------------------------------------------
	---- External connections
	----
	-- Contains the code which connects (in/out)puts to the internals
	
	-- Attach switches to internal 
	sw_coffee_type <= i_input(1 downto 0);
	sw_cup_size    <= i_input(3 downto 2);
	sw_confirm     <= i_input(5);
	sw_dispense    <= i_input(6);
	
	-- Attach low quantity indicators to the LEDs
	o_low_coffee_indicators(0) <= led_low_americano;
	o_low_coffee_indicators(1) <= led_low_mocha;
	o_low_coffee_indicators(2) <= led_low_espresso;
	o_low_coffee_indicators(3) <= led_low_latte;
	
	-- Attach admin mode indicator
	o_admin_mode <= admin_mode;
	
	-----------------------------------------------------------------
	---- Constant logic
	----
	-- Logic that is always active (non-clocked)
	
	-- Automatic low quantity logic
	led_low_americano <= '1' when coffee_availability(0) <= "00011" else '0';
	led_low_mocha     <= '1' when coffee_availability(1) <= "00011" else '0';
	led_low_espresso  <= '1' when coffee_availability(2) <= "00011" else '0';
	led_low_latte     <= '1' when coffee_availability(3) <= "00011" else '0';
	
	-- Automatically display coffee type when confirm is active
	with (confirm & coffee_type) select
		o_coffee_type <= (ss_A & ss_M) when "100", -- "AM" Americano
							  (ss_M & ss_O) when "101", -- "MO" Mocha
							  (ss_E & ss_S) when "110", -- "ES" Espresso
							  (ss_L & ss_A) when "111", -- "LA" Latte
							  (ss_dash & ss_dash) when others;
	
	with (confirm & cup_size) select
		o_cup_size <= (ss_S) when "100", -- Small
						  (ss_M) when "101", -- Medium
						  (ss_L) when "110", -- Large
						  (ss_dash) when others; -- Error
						  
	seg_decoder : digit_decoder
		port map (sw_in => coffee_availability(to_integer(unsigned(coffee_type))),
					 enabled => (admin_mode and confirm),
					 ss_seg_out => o_available_quantity);
	
	-----------------------------------------------------------------
	---- Clocked logic
	----
	
	process (i_clk, i_reset) is
	begin
		
		-- We can't perform logic in the reset below
		-- because it would cause a latch to be infered
		-- (making "memory" where it shouldn't). This
		-- forces us to put the mode logic in here.
		if rising_edge(i_reset) then
			if i_input = "1111111" then
				admin_mode <= '1';
			else
				admin_mode <= '0';
			end if;
		end if;
	
		-- If reset is pressed, reset the confirm state
		if i_reset = '1' then
			confirm <= '0';
			
		-- Run only on the rising edge
		elsif rising_edge(i_clk) then
			
			-- Common mode logic
			-- Stuff that both modes use
			
			-- If the user turns of confirm from being in
			-- the confirm state, then we get out of the confirm
			-- state.
			if sw_confirm = '0' and confirm = '1' then
				confirm <= '0';
			end if;
		
			-- User mode logic
			if admin_mode = '0' then
				
				-- This is the primary "activation" statement.
				-- If the user has the confirm switch ACTIVE,
				-- that we currently AREN'T in confirm state,
				-- that the selected coffee aviable is more then the size requested,
				-- and that the size is valid. The 
				if sw_confirm = '1' and 
				   confirm = '0' and 
					unsigned(coffee_availability(to_integer(unsigned(sw_coffee_type)))) >= unsigned(sw_cup_size) + 1 and 
					sw_cup_size /= "11" then
					
					-- If all of that is true, then we can activate the confirm state 
					-- and store the coffee type and size.
					confirm <= '1';
					coffee_type <= sw_coffee_type;
					cup_size <= sw_cup_size;
				end if;
				
				-- If the user has the dispense switch on
				-- and is in the confirm state.
				if sw_dispense = '1' and confirm = '1'then
					-- Reset confirm back to zero
					confirm <= '0';
					
					-- Subtract the cup size from the selected coffee.
					-- This long statement just converts the bit vectors 
					-- into ints, does some math, and then convert them
					-- back into bit vectors. Why does VHDL have to make
					-- this so complex? The additional -1 is because the switches start at 0.
					coffee_availability(to_integer(unsigned(coffee_type))) <= std_logic_vector(unsigned(coffee_availability(to_integer(unsigned(coffee_type)))) - to_integer(unsigned(cup_size)) - 1);
				end if;
		
			-- Admin mode logic
			elsif admin_mode = '1' then
				
				-- If the confirm switch is on and we
				-- aren't in the confirm state, store
				-- the selected values and set the state.
				if sw_confirm = '1'and confirm = '0' then
					confirm <= '1';
					coffee_type <= sw_coffee_type;
					
					-- This is done since cup size doesn't matter in admin mode.
					-- It will force the display to show just a dash.
					cup_size <= "11";
				end if;
				
				-- If confirm is active and dispense is high,
				-- reset confirm and set quantity to 30
				if sw_dispense = '1' and confirm = '1' then
					confirm <= '0';
					coffee_availability(to_integer(unsigned(coffee_type))) <= "11110";
				end if;
			
			end if;
		end if;
		
	end process;

end architecture rtl;