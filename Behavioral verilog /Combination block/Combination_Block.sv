`include "Combination_FSM.sv"
`include "counter_comb.sv"
`include "Matrix_FM_WM_ADJ_Memory.sv"
`include "Vector_Multiplication_ADJ_FM_WM.sv"
`include "coo_to_adj.sv"
`include "Argmax_ADJ_FM_WM.sv"
`timescale 1ns/1ps

module Combination_Block
   #(
     //scratch_Pad
	 parameter FEATURE_ROWS = 6,
	 parameter DOT_PROD_WIDTH = 16,
	 //FSM instance

	 parameter WEIGHT_COLS = 3,
	 parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS),
	 parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
	 parameter COO_NUM_OF_COLS = 6,
     parameter COO_NUM_OF_ROWS = 2,
     parameter COO_BW = $clog2(COO_NUM_OF_COLS), // Bit width to represent node index
     parameter NUM_OF_NODES = 6, // Number of nodes in the graph
	 parameter MAX_ADDRESS_WIDTH = 2




)
(
	input logic clk,
	input logic reset,
	input logic start,
	input  [DOT_PROD_WIDTH-1:0] fm_wm_vector [0:WEIGHT_COLS-1],
	input logic [COO_BW - 1:0] coo_in [0:1], 
//	input  logic [COUNTER_FEATURE_WIDTH-1:0] row_select, //argmax
	output logic [MAX_ADDRESS_WIDTH-1:0] max_addi_answer [0:FEATURE_ROWS-1],
	output logic [COO_BW - 1:0] col_address, 
    output	logic done_comb,
    output logic [DOT_PROD_WIDTH - 1:0] fm_wm_adj_out [0:FEATURE_ROWS-1][0:WEIGHT_COLS-1],
	output logic  done
);
	//internal signals
	//fsm
	
	
	logic [COUNTER_FEATURE_WIDTH-1:0] adj_count; // adj counter value
    logic [COUNTER_WEIGHT_WIDTH-1:0] fm_wm_count;  // fm_wm counter value
	logic enable_decode;
//	logic enable_scratch_pad;
	logic enable_read;
	logic enable_write_adj_fm_wm_pad;
	logic enable_adj_counter;
	logic enable_fm_wm_counter;
	logic enable_vector;   // 

    //scratch pad
//    logic [DOT_PROD_WIDTH - 1:0] fm_wm_col_out  [0:WEIGHT_COLS-1];


    //decode_block
    logic  [NUM_OF_NODES-1:0][NUM_OF_NODES-1:0] adj_matrix ;
//	logic [COO_BW-1:0] col_address;

    logic  [DOT_PROD_WIDTH-1:0] fm_wm_adj_row_in  [0:WEIGHT_COLS-1];
	//memory
//    logic [COUNTER_FEATURE_WIDTH-1:0] write_row;
    logic [COUNTER_FEATURE_WIDTH-1:0] read_row ;



always_ff @(posedge clk) begin
    if (reset) begin
        col_address <= 0;  // Reset the column address to 0
    end else if (col_address < (COO_NUM_OF_COLS - 1)) begin
        col_address <= col_address + 1;  // Increment column address
    end else begin
        col_address <= 0;  // Reset column address when it reaches max
    end  
end





//FSM instance
 Combination_FSM#(
	  .FEATURE_ROWS(FEATURE_ROWS),
	  .WEIGHT_COLS(WEIGHT_COLS),
	  .COUNTER_FEATURE_WIDTH($clog2(FEATURE_ROWS)),
	  .COUNTER_WEIGHT_WIDTH($clog2(WEIGHT_COLS))
) fsm_inst  (	
    .clk(clk),
	.reset(reset),
	.adj_count(adj_count),
	.fm_wm_count(fm_wm_count),
	.start(start),	//together
	
	.enable_decode(enable_decode),
//	.enable_scratch_pad(enable_scratch_pad),
	.enable_read(enable_read),
	.enable_write_adj_fm_wm_pad(enable_write_adj_fm_wm_pad),
	.enable_adj_counter(enable_adj_counter),
    .enable_fm_wm_counter(enable_fm_wm_counter),
	.enable_vector(enable_vector),
	.done(done_comb)
);

//counter 
  counter_comb #(
	.FEATURE_ROWS(FEATURE_ROWS), 
	.WEIGHT_COLS(WEIGHT_COLS), 
	.COUNTER_FEATURE_WIDTH($clog2(FEATURE_ROWS)),
	.COUNTER_WEIGHT_WIDTH($clog2(WEIGHT_COLS))
) counter_inst(	 
 .clk(clk),
 .reset(reset),
 .enable_adj_counter(enable_adj_counter),
 .enable_fm_wm_counter(enable_fm_wm_counter),
 .adj_count(adj_count), // adj counter value
 .fm_wm_count(fm_wm_count),  // fm_wm counter value
 .read_row(read_row)  // New signal for read_row
); 

 
 //FM_WM_ADJ_mem_instance
Matrix_FM_WM_ADJ_Memory #(
	.FEATURE_ROWS(FEATURE_ROWS), 
    .WEIGHT_COLS(WEIGHT_COLS), 
    .DOT_PROD_WIDTH(DOT_PROD_WIDTH), 
    .COUNTER_WEIGHT_WIDTH($clog2(WEIGHT_COLS)),
    .COUNTER_FEATURE_WIDTH($clog2(FEATURE_ROWS))
)  fm_wm_adj_inst (

    .clk(clk),
    .rst(reset),
    .write_row(adj_count),//connect to count
    .read_row(read_row),
    .wr_en(enable_write_adj_fm_wm_pad),
    .fm_wm_adj_row_in(fm_wm_adj_row_in),     //output of vector multiplication
    .fm_wm_adj_out(fm_wm_adj_out)
); 


 
 //vector multiplication
  Vector_Multiplication_ADJ_FM_WM #(
      .NUM_OF_NODES(NUM_OF_NODES) ,
	  .WEIGHT_COLS(WEIGHT_COLS),
	  .DOT_PROD_WIDTH(DOT_PROD_WIDTH), 
	  .COUNTER_WEIGHT_WIDTH($clog2(WEIGHT_COLS)),
      .COUNTER_FEATURE_WIDTH($clog2(FEATURE_ROWS))  
	  	  
)   vector_block(
	 .clk(clk),
	 .reset(reset),
	// .enable(enable_vector ),//?????not sure
	  .enable(enable_write_adj_fm_wm_pad),
	 .write_row(adj_count),
	 .read_row(adj_count),
	 .adj_vector( adj_matrix),                     //output of AdjMat
	 .fm_wm_vector(fm_wm_vector),      
     .dot_product(fm_wm_adj_row_in)    //output of vector multiplication
);


//coo_to_adj
   coo_to_adj #(
   .COO_NUM_OF_COLS(COO_NUM_OF_COLS) ,
   .COO_NUM_OF_ROWS(COO_NUM_OF_ROWS) ,
   .COO_BW($clog2(COO_NUM_OF_COLS)), // Bit width to represent node index
   .NUM_OF_NODES(NUM_OF_NODES)  // Number of nodes in the graph
)  decode_block (
      .clk(clk),
      .coo_in(coo_in), // Input COO formatted data
      .reset(reset),
	  .adj_matrix(adj_matrix)	  // Output adjacency matrix
  //    .coo_address(col_address)
);

//Argmax
  Argmax_ADJ_FM_WM#(
    .FEATURE_ROWS(FEATURE_ROWS),    // Number of rows in ADJ_FM_WM
    .WEIGHT_COLS(WEIGHT_COLS) ,     // Number of columns in ADJ_FM_WM
    .DOT_PROD_WIDTH(DOT_PROD_WIDTH), // Bit-width of each matrix value
    .MAX_ADDRESS_WIDTH(MAX_ADDRESS_WIDTH),
	.COUNTER_FEATURE_WIDTH($clog2(FEATURE_ROWS))
) argmax_block (
    .clk(clk),
    .reset(reset),
	.done_comb(done_comb),
    .fm_wm_adj_row_in(fm_wm_adj_out) , // Input row of 3 columns !!!!
 //   .row_select(row_select), // Row selection signal (one-hot or binary)
    .done(done),
    .max_addi_answer(max_addi_answer) // Output: column index of max value in the row
);








endmodule
