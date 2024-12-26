`timescale 1ns / 1ps

module Transformation_Block_tb

  // Parameters
  #(parameter FEATURE_COLS = 96,
    parameter DATA_WIDTH = 5,
//	parameter NUM_FEATURES = 5,
	parameter ADDRESS_WIDTH = 13,
	parameter WEIGHT_ROWS = 96,
	parameter FEATURE_ROWS = 6,
	parameter WEIGHT_COLS = 3,
	parameter DOT_PROD_WIDTH = 16,
	parameter FEATURE_WIDTH = 5,
	parameter WEIGHT_WIDTH = 5,
	parameter VECTOR_SIZE = 96,
	parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
    parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS)
)
();

  string feature_filename = "C:/Users/chent/OneDrive/Desktop/EEE525 VLSI Design/lab/lab4/Data/feature_data.txt"; // modify the path to the files to match your case
  string weight_filename = "C:/Users/chent/OneDrive/Desktop/EEE525 VLSI Design/lab/lab4/Data/weight_data.txt";
  
  logic [WEIGHT_WIDTH-1:0] data_in [0:WEIGHT_ROWS-1];
//  logic [NUM_FEATURES-1:0][DATA_WIDTH-1:0] data_in;
  logic enable_read;
  logic [FEATURE_WIDTH - 1:0] feature_matrix_mem [0:FEATURE_ROWS - 1][0:FEATURE_COLS - 1];
  logic [WEIGHT_WIDTH - 1:0] weight_matrix_mem [0:WEIGHT_COLS - 1][0:WEIGHT_ROWS - 1];
  logic [ADDRESS_WIDTH-1:0] read_address_mem;
 // logic [ADDER_WIDTH-1:0] read_address;
 // logic [ADDRESS_WIDTH-1:0][2:0] FM_WM_Row;
 // logic [DOT_PROD_WIDTH-1:0][2:0] FM_WM_Row;  //?not sure
  logic [DOT_PROD_WIDTH - 1:0] FM_WM_Row  [0:FEATURE_ROWS-1][0:WEIGHT_COLS-1] ;
  initial $readmemb(feature_filename, feature_matrix_mem);
  initial $readmemb(weight_filename, weight_matrix_mem);
  
always @(read_address_mem or enable_read) begin
	if (enable_read) begin
		if(read_address_mem >= 10'b10_0000_0000) begin
			data_in = feature_matrix_mem[read_address_mem - 10'b10_0000_0000];
		end 
		else begin
			data_in = weight_matrix_mem[read_address_mem];
		end 
	end
end 

/*
  // Assign data based on read address
  always @(read_address_mem or enable_read) begin
    if (enable_read) begin
      if (read_address_mem >= 10'b10_0000_0000) begin
        // Assign feature_matrix_mem to data_in
        for (int i = 0; i < NUM_FEATURES; i++) begin
          data_in[i] = feature_matrix_mem[read_address_mem - 10'b10_0000_0000][i];
        end
      end else begin
        // Assign weight_matrix_mem to data_in
        for (int i = 0; i < NUM_FEATURES; i++) begin
          data_in[i] = weight_matrix_mem[read_address_mem][i];
        end
      end
    end
  end
*/










  // Inputs
  logic clk;
  logic reset;
  logic start;
  logic done_trans;
//  logic done_multiplier;
  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10 ns clock period
  end

  initial begin 
		#100000;
		$display("Simulation Time Expired");

		$finish;
  end 
  


  // Testbench sequence
  initial begin
    // Initialize inputs
    reset = 1;
    start = 0;
    data_in = '{default: 0};

    // Reset the DUT
    #10;
    reset = 0;

    // Start the transformation process
    #10;
    start = 1;
   // data_in = '{96'h0123456789ABCDEF, 96'hFEDCBA9876543210, 96'h1111111111111111, 96'h2222222222222222, 96'h3333333333333333};

    // Wait for done signal
  //  wait(done_multiplier);
      wait(done_trans);
    #100;

    // Stop the simulation
    $stop;
  end

  // Instantiate the Transformation_Block
  Transformation_Block #(
    .DATA_WIDTH(DATA_WIDTH),
  //  .NUM_FEATURES(NUM_FEATURES),
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .WEIGHT_ROWS(WEIGHT_ROWS),
    .FEATURE_ROWS(FEATURE_ROWS),
    .WEIGHT_COLS(WEIGHT_COLS)
  ) dut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .data_in(data_in),
    .done_trans(done_trans),
//	.done_multiplier(done_multiplier),
    .read_address(read_address_mem),
	.enable_read(enable_read),
    .FM_WM_Row(FM_WM_Row)
  );

endmodule
