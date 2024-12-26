`include "Scratch_Pad.sv"
`include "Vector_Multiplication.sv"
`include "Transformation_FSM.sv"
`include "counter.sv"
`include "Matrix_FM_WM_Memory.sv"



`timescale 1ns / 1ps

module Transformation_Block
   #(
 //  parameter DATA_WIDTH = 5,
 //    parameter NUM_FEATURES = 5,
     parameter FEATURE_COLS = 96,
     parameter ADDRESS_WIDTH = 13,
     parameter WEIGHT_ROWS = 96,
     parameter FEATURE_ROWS = 6,
     parameter WEIGHT_COLS = 3,
     parameter DOT_PROD_WIDTH = 16,
     parameter FEATURE_WIDTH = 5,
     parameter WEIGHT_WIDTH = 5,
 //    parameter VECTOR_SIZE = 96,
     parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
     parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS)
   )
(
    input logic clk,
    input logic reset,
    input logic start,
    //input logic [NUM_FEATURES-1:0][DATA_WIDTH-1:0] data_in,
    input [WEIGHT_WIDTH-1:0] data_in [0:WEIGHT_ROWS-1],
	output logic enable_read,
    output logic done_trans,
    output logic [ADDRESS_WIDTH-1:0] read_address,
	output logic [DOT_PROD_WIDTH - 1:0] FM_WM_Row [0:WEIGHT_COLS-1]
);

    // Internal signals
    logic enable_write_fm_wm_prod;
   // logic enable_read; // read_weight_data / feature_data
    logic enable_write;
    logic enable_scratch_pad; // Scratch_Pad
    logic enable_weight_counter;
    logic enable_feature_counter;
    logic read_feature_or_weight;

//    logic done_multiplier; 
    // Internal signal from counter
//    logic [FEATURE_WIDTH-1:0] write_row;
//    logic [WEIGHT_WIDTH-1:0] write_col;
    logic [COUNTER_FEATURE_WIDTH - 1:0] read_row;

    // Scratch_pad signals
    logic [WEIGHT_WIDTH-1:0] weight_col_out [0:WEIGHT_ROWS-1];
    logic [DOT_PROD_WIDTH-1:0] fm_wm_in;
    logic [COUNTER_WEIGHT_WIDTH-1:0] weight_count;
    logic [COUNTER_FEATURE_WIDTH-1:0] feature_count;

 //   logic [DOT_PROD_WIDTH - 1:0] FM_WM_Row [0:WEIGHT_COLS-1];
   
   
   
   
   
    // Scratch_Pad instance
    Scratch_Pad #(
        .WEIGHT_ROWS(WEIGHT_ROWS),
        .WEIGHT_WIDTH(WEIGHT_WIDTH)
    ) scratch_pad_inst(
        .clk(clk),
        .reset(reset),
        .write_enable(enable_scratch_pad),
        .weight_col_in(data_in), // Using multi-dimensional array directly
        .weight_col_out(weight_col_out) // Using multi-dimensional array directly
    );

    // Vector_Multiplication instance
    Vector_Multiplication #(
	    .FEATURE_COLS(FEATURE_COLS),
        .FEATURE_WIDTH(FEATURE_WIDTH),
    //    .DATA_WIDTH(DATA_WIDTH),
        .DOT_PROD_WIDTH(DOT_PROD_WIDTH)
    ) vector_mult_inst (
        .clk(clk),
        .reset(reset),
      //  .enable(enable_write_fm_wm_prod), // connected to FSM signal
	    .enable(read_feature_or_weight),    //  !!!!!
        .feature_vector(data_in),  // Using multi-dimensional array directly
        .weight_vector(weight_col_out),   // Using weight_col_out directly
        .dot_product(fm_wm_in)
   //     .done_multiplier(done_trans) // Removed done_trans to avoid multiple drivers
    );

    // FM_WM_mem_instance
    Matrix_FM_WM_Memory #(
        .FEATURE_ROWS(FEATURE_ROWS),
        .WEIGHT_COLS(WEIGHT_COLS),
        .DOT_PROD_WIDTH(DOT_PROD_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
		.WEIGHT_WIDTH($clog2(WEIGHT_COLS)),
        .FEATURE_WIDTH($clog2(FEATURE_ROWS))
    ) fm_wm_mem_inst (
       .clk(clk),
       .rst(reset),
       .write_row(feature_count), // 
       .write_col(weight_count), // 
       .read_row(read_row),       // 
       .wr_en(enable_write_fm_wm_prod),  // Connected to FSM signal
       .fm_wm_in(fm_wm_in),       // Output of Vector Multiplication
       .fm_wm_row_out(FM_WM_Row)  // Output from FM_WM_mem
    );

    // Counters and address generation
    counter #(
        .FEATURE_ROWS(FEATURE_ROWS),
        .WEIGHT_COLS(WEIGHT_COLS),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),   
        .COUNTER_WEIGHT_WIDTH($clog2(WEIGHT_COLS)),
        .COUNTER_FEATURE_WIDTH($clog2(FEATURE_ROWS))
    ) counter_inst(
        .clk(clk),
        .reset(reset),
        .enable_feature_counter(enable_feature_counter),
        .enable_weight_counter(enable_weight_counter),
        .read_feature_or_weight(read_feature_or_weight),
        .read_address(read_address),
        .feature_count(feature_count),
        .weight_count(weight_count),
		.read_row(read_row) //?
    );

    // FSM instance
    Transformation_FSM #(
        .FEATURE_ROWS(FEATURE_ROWS),
        .WEIGHT_COLS(WEIGHT_COLS),
        .COUNTER_WEIGHT_WIDTH($clog2(WEIGHT_COLS)),
        .COUNTER_FEATURE_WIDTH($clog2(FEATURE_ROWS))
    ) fsm_inst (
        .clk(clk),
        .reset(reset),
        .weight_count(weight_count),
        .feature_count(feature_count),
        .start(start),
        .enable_write_fm_wm_prod(enable_write_fm_wm_prod),
        .enable_read(enable_read),
        .enable_write(enable_write),
        .enable_scratch_pad(enable_scratch_pad),
        .enable_weight_counter(enable_weight_counter),
        .enable_feature_counter(enable_feature_counter),
        .read_feature_or_weight(read_feature_or_weight), 
        .done(done_trans)    
    );








endmodule

