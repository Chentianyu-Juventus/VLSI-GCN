`timescale 1ns/1ps
module Trans_Comb_tb

 // Parameters
  #(parameter FEATURE_COLS = 96,
    parameter DATA_WIDTH = 5,
	parameter ADDRESS_WIDTH = 13,
	parameter WEIGHT_ROWS = 96,
	parameter FEATURE_ROWS = 6,
	parameter WEIGHT_COLS = 3,
	parameter DOT_PROD_WIDTH = 16,
	parameter FEATURE_WIDTH = 5,
	parameter WEIGHT_WIDTH = 5,
	parameter VECTOR_SIZE = 96,
	parameter MAX_ADDRESS_WIDTH = 2,
	parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
    parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS),
	
	
	
    //comb
	
	 parameter FM_WM_WIDTH = 16,
	 parameter COO_NUM_OF_COLS = 6,
     parameter COO_NUM_OF_ROWS = 2,
     parameter COO_BW = $clog2(COO_NUM_OF_COLS), // Bit width to represent node index
     parameter NUM_OF_NODES = 6 // Number of nodes in the graph


)
();

 string feature_filename = "C:/Users/chent/OneDrive/Desktop/EEE525 VLSI Design/lab/lab4/Data/feature_data.txt"; // modify the path to the files to match your case
 string weight_filename = "C:/Users/chent/OneDrive/Desktop/EEE525 VLSI Design/lab/lab4/Data/weight_data.txt";
 string coo_filename = "C:/Users/chent/OneDrive/Desktop/EEE525 VLSI Design/lab/lab4/Data/coo_data.txt";
 
//transformation block
  logic [WEIGHT_WIDTH-1:0] data_in [0:WEIGHT_ROWS-1];
  logic enable_read;
  logic [FEATURE_WIDTH - 1:0] feature_matrix_mem [0:FEATURE_ROWS - 1][0:FEATURE_COLS - 1];
  logic [WEIGHT_WIDTH - 1:0] weight_matrix_mem [0:WEIGHT_COLS - 1][0:WEIGHT_ROWS - 1];
  logic [ADDRESS_WIDTH-1:0] read_address_mem;
  logic [DOT_PROD_WIDTH - 1:0] FM_WM_Row [0:WEIGHT_COLS-1];
  logic done_trans;
//combination block
  	 logic clk;
	 logic reset;
	 logic start;    //tongshi
	 logic done_comb; 

		 
//	logic [DOT_PROD_WIDTH-1:0] data_in [0:FEATURE_ROWS-1],  //FM_WM_ROW
    logic [COO_BW - 1:0] coo_matrix_mem [0:COO_NUM_OF_ROWS - 1][0:COO_NUM_OF_COLS - 1];
	logic [COO_BW - 1:0] col_address;
    logic [DOT_PROD_WIDTH - 1:0] fm_wm_adj_out [0:FEATURE_ROWS-1] [0:WEIGHT_COLS-1]; //output from comb mem
  
//argmax
     
	 logic [COUNTER_FEATURE_WIDTH-1:0]row_select;
	 logic [MAX_ADDRESS_WIDTH-1:0] max_addi_answer [0:FEATURE_ROWS-1];
	 
  
  
  
  initial $readmemb(feature_filename, feature_matrix_mem);
  initial $readmemb(weight_filename, weight_matrix_mem);
  initial $readmemb(coo_filename, coo_matrix_mem);
 
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
      wait(done_comb == 1'b1);
	  #20;
	  row_select = 'b000;
      $display(fm_wm_adj_out);
	  #20
	  row_select = 'b001;
	  $display(fm_wm_adj_out);
	  #20;
	  row_select = 'b010;
	  $display(fm_wm_adj_out);
	  #20;
	  row_select = 'b011;
	  $display(fm_wm_adj_out);
	  #20;
	  row_select = 'b100;
	  $display(fm_wm_adj_out);
	  #20;
	  row_select = 'b101;
	  $display(fm_wm_adj_out);
	  #20;
	//  row_select = 'b110;
	//  $display(fm_wm_adj_out);
	//  #50;
	  

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
  
  
  
//
Combination_Block #(
     //scratch_PadDOT_PROD_WIDTH
	 .FEATURE_ROWS(FEATURE_ROWS),
	 .DOT_PROD_WIDTH(DOT_PROD_WIDTH) ,
	 //FSM instance
	 .WEIGHT_COLS(WEIGHT_COLS) ,
	 .COUNTER_FEATURE_WIDTH($clog2(FEATURE_ROWS)),
	 .COUNTER_WEIGHT_WIDTH($clog2(WEIGHT_COLS)),
	 .COO_NUM_OF_COLS(COO_NUM_OF_COLS),
     .COO_NUM_OF_ROWS(COO_NUM_OF_ROWS) ,
     .COO_BW($clog2(COO_NUM_OF_COLS)), // Bit width to represent node index
     .NUM_OF_NODES(NUM_OF_NODES) // Number of nodes in the graph

)  comb (

	 .clk(clk),
	 .reset(reset),
	 .start(start),
	 .done_comb(done_comb),
	 .data_in(FM_WM_Row) ,
     .coo_in({coo_matrix_mem[0][col_address], coo_matrix_mem[1][col_address]}), 
	 .col_address(col_address), 
     .fm_wm_adj_out(fm_wm_adj_out),
	 .row_select(row_select), //argmax
     . max_addi_answer( max_addi_answer) //argmax
);

endmodule
