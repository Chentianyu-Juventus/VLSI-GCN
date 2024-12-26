`include "Transformation_Block.sv"
`include "Combination_Block.sv"

module GCN
  #(parameter FEATURE_COLS = 96,
    parameter WEIGHT_ROWS = 96,
    parameter FEATURE_ROWS = 6,
    parameter WEIGHT_COLS = 3,
    parameter FEATURE_WIDTH = 5,
    parameter WEIGHT_WIDTH = 5,
    parameter DOT_PROD_WIDTH = 16,
    parameter ADDRESS_WIDTH = 13,
    parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
    parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS),
    parameter MAX_ADDRESS_WIDTH = 2,
    parameter NUM_OF_NODES = 6,			 
    parameter COO_NUM_OF_COLS = 6,			
    parameter COO_NUM_OF_ROWS = 2,			
    parameter COO_BW = $clog2(COO_NUM_OF_COLS)	
)
(
  input logic clk,	// Clock
  input logic reset,	// Reset 
  input logic start,
  input logic [WEIGHT_WIDTH-1:0] data_in [0:WEIGHT_ROWS-1], //FM and WM Data
  input logic [COO_BW - 1:0] coo_in [0:1], //row 0 and row 1 of the COO Stream

  output logic [COO_BW - 1:0] coo_address, // The column of the COO Matrix 
  output logic [ADDRESS_WIDTH-1:0] read_address, // The Address to read the FM and WM Data
  output logic enable_read, // Enabling the Read of the FM and WM Data
  output logic done, // Done signal indicating that all the calculations have been completed
  output logic [MAX_ADDRESS_WIDTH - 1:0] max_addi_answer [0:FEATURE_ROWS - 1] // The answer to the argmax and matrix multiplication 
); 

 // logic [COUNTER_FEATURE_WIDTH-1:0] row_select; //argmax
  logic [DOT_PROD_WIDTH - 1:0] fm_wm_adj_out [0:FEATURE_ROWS-1][0:WEIGHT_COLS-1];     
  logic  done_comb;           //internal logic
  logic  done_trans;
  logic [DOT_PROD_WIDTH - 1:0] FM_WM_Row [0:WEIGHT_COLS-1];

  








///////////Transformation_Block
  Transformation_Block #(
  //  .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .WEIGHT_ROWS(WEIGHT_ROWS),
    .FEATURE_ROWS(FEATURE_ROWS),
    .WEIGHT_COLS(WEIGHT_COLS),
    .DOT_PROD_WIDTH(DOT_PROD_WIDTH),
    .FEATURE_WIDTH(FEATURE_WIDTH),
    .WEIGHT_WIDTH(WEIGHT_WIDTH),
  //  .VECTOR_SIZE(VECTOR_SIZE),
    .COUNTER_WEIGHT_WIDTH($clog2(WEIGHT_COLS)),
    .COUNTER_FEATURE_WIDTH($clog2(FEATURE_ROWS))
   ) trans_block(
    .clk(clk),
    .reset(reset),
    .start(start),
    //input logic [NUM_FEATURES-1:0][DATA_WIDTH-1:0] data_in,
    .data_in(data_in) ,
    .enable_read(enable_read),
    .done_trans(done_trans),
    .read_address(read_address),
	.FM_WM_Row(FM_WM_Row)
);


//Combination Block
Combination_Block #(
     //scratch_Pad
	  .FEATURE_ROWS(FEATURE_ROWS),
	  .DOT_PROD_WIDTH(DOT_PROD_WIDTH),
	 //FSM instance

	  .WEIGHT_COLS(WEIGHT_COLS) ,
	  .COUNTER_FEATURE_WIDTH($clog2(FEATURE_ROWS)),
	  .COUNTER_WEIGHT_WIDTH($clog2(WEIGHT_COLS)),
	  .COO_NUM_OF_COLS(COO_NUM_OF_COLS),
      .COO_NUM_OF_ROWS(COO_NUM_OF_ROWS),
      .COO_BW($clog2(COO_NUM_OF_COLS)), // Bit width to represent node index
      .NUM_OF_NODES(NUM_OF_NODES), // Number of nodes in the graph
      .MAX_ADDRESS_WIDTH(MAX_ADDRESS_WIDTH)




) comb_block(
	.clk(clk),
	.reset(reset),
	.start(start),
	.fm_wm_vector(FM_WM_Row) ,
	.coo_in(coo_in) , 
//	.row_select(row_select), //argmax internal
	.max_addi_answer(max_addi_answer),
    .col_address(coo_address), 
    .done_comb(done_comb),           //internal logic
    .fm_wm_adj_out(fm_wm_adj_out),    //internal logic
	.done(done)                   //done all calculations
);



endmodule
