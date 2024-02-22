`timescale 1ns / 1ps

// This script will order coffee from all 4 types
// and sizes until each low indicator comes on.

module coffee_machine_tb_full_order ();

	reg sw_confirm;
	reg sw_dispense;
	reg [1:0] sw_size;
	reg [1:0] sw_type;
	reg sw_empty;
	reg reset;
	reg clk;
	
	wire [3:0] leds_low_coffee;
	wire [6:0] hex_type_1;
	wire [6:0] hex_type_2;
	wire [6:0] hex_quantity_1;
	wire [6:0] hex_quantity_2;
	wire [6:0] hex_size;
	wire admin_mode;
	
	coffee_machine U1 (
		.i_input({sw_dispense, sw_confirm, sw_empty, sw_size, sw_type}),
		.i_reset(reset), // Shmit trigger is inverted
		.i_clk(clk), // Shmit trigger is inverted
		
		.o_low_coffee_indicators(leds_low_coffee),
		.o_coffee_type({hex_type_1, hex_type_2}),
		.o_available_quantity({hex_quantity_1, hex_quantity_2}),
		.o_cup_size({hex_size}),
		.o_admin_mode(admin_mode)
	);
	
	// Fire clock every 10ns 
	always
	begin
		#10 clk <= ~clk;
	end
	
	// Primary test
	initial
	begin
		// Reset system
		clk <= 1'b0;
		reset <= 1'b0;
		sw_confirm <= 1'b0;
		sw_dispense <= 1'b0;
		sw_empty <= 0;
		sw_size <= 2'b00;
		sw_type <= 2'b00;
		
		#5
		
		#20 reset <= 1'b1;
		#20 reset <= 1'b0;
		
		///////////////////////////////////////////////////////
		// Americano large
		sw_size <= 2'b10;
		sw_type <= 2'b00;
		#20
		sw_confirm <= 1'b1;
		#20
		sw_dispense <= 1'b1;
		#20
		// Wait a bunch with the switch/confirm on so it will keep dispensing
		#380
		
		///////////////////////////////////////////////////////
		// Espresso medium
		sw_size <= 2'b01;
		sw_type <= 2'b10;
		#20
		sw_confirm <= 1'b1;
		#20
		sw_dispense <= 1'b1;
		#20
		// Wait a bunch with the switch/confirm on so it will keep dispensing
		#460
		
		///////////////////////////////////////////////////////
		// Switch to admin mode and reset Americano
		sw_confirm <= 1'b1;
		sw_dispense <= 1'b1;
		sw_size <= 2'b11;
		sw_type <= 2'b11;
		sw_empty <= 1'b1;
		
		reset <= 1'b1;
		#2
		reset <= 1'b0;
		#2
		
		sw_confirm <= 1'b0;
		sw_dispense <= 1'b0;
		sw_size <= 2'b00;
		sw_type <= 2'b00;
		sw_empty <= 1'b0;
		#36
		
		// select and reset
		sw_type <= 2'b00;
		#20
		sw_confirm <= 1'b1;
		#20
		sw_dispense <= 1'b1;
		#20
		
		// Go back to user mode
		reset <= 1'b1;
		#2
		reset <= 1'b0;
		#2
		#16
		
		
		$stop;
	end

endmodule