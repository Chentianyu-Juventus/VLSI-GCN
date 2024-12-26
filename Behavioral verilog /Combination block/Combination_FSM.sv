module Combination_FSM
	#(parameter FEATURE_ROWS = 6,
	  parameter WEIGHT_COLS = 3,
	  parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS), //FEATURE
	  parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS)	  //WEIGHT
)
(
	input logic clk,
	input logic reset,
	input logic [COUNTER_FEATURE_WIDTH-1:0]    adj_count,
	input logic [COUNTER_WEIGHT_WIDTH-1:0]    fm_wm_count,
	input logic      start,	//done_trans
	
	output logic enable_decode,
//	output logic enable_scratch_pad,
	output logic enable_read,
	output logic enable_write_adj_fm_wm_pad,
	output logic enable_adj_counter,
	output logic enable_fm_wm_counter,
	output logic enable_vector,//
	output logic done
	
);

	typedef enum logic [2:0] {
	START,
	DECODE_COO_ADJ,
	READ_ADJ_DATA,
	INCREMENT_ADJ_COUNTER,
	READ_FM_WM_DATA,
	INCREMENT_FM_WM_COUNTER,
	DONE
} state_t;

    state_t current_state, next_state;
	
	
   always_ff @(posedge clk or posedge reset)
    if (reset)
      current_state <= START;
    else
      current_state <= next_state;
	
   always_comb begin
	case (current_state)
		START: begin
		enable_decode = 1'b0;
	//	enable_scratch_pad = 1'b0;
		enable_read = 1'b0;
		enable_write_adj_fm_wm_pad = 1'b0;
		enable_adj_counter = 1'b0;
		enable_fm_wm_counter = 1'b0;
		done = 1'b0;
		
		if (start) begin
			next_state = DECODE_COO_ADJ;
		end
		else begin
			next_state = START;
		end
		end
	    DECODE_COO_ADJ: begin
		enable_decode = 1'b1;
	//	enable_scratch_pad = 1'b0;
		enable_read = 1'b0;
		enable_write_adj_fm_wm_pad = 1'b0;
		enable_adj_counter = 1'b0;
		enable_fm_wm_counter = 1'b0;
		enable_vector = 1'b0; 
		done = 1'b0;
			
		next_state = READ_FM_WM_DATA;
		end
		
		READ_FM_WM_DATA: begin
		enable_decode = 1'b0;
	//	enable_scratch_pad = 1'b1;
		enable_read = 1'b1;
		enable_write_adj_fm_wm_pad = 1'b0;
		enable_adj_counter = 1'b0;
		enable_fm_wm_counter = 1'b0;
		enable_vector = 1'b0; 
		done = 1'b0;

		next_state = READ_ADJ_DATA;
		end
		
		INCREMENT_FM_WM_COUNTER: begin  
		enable_decode = 1'b0;
	//	enable_scratch_pad = 1'b0;
		enable_read = 1'b0;
		enable_write_adj_fm_wm_pad = 1'b0;
		enable_adj_counter = 1'b0;
		enable_fm_wm_counter = 1'b1;
		enable_vector = 1'b0; 
		done = 1'b0;
		
		next_state = READ_FM_WM_DATA;
		end   
		
		READ_ADJ_DATA: begin
		enable_decode = 1'b0;
	//	enable_scratch_pad = 1'b0;
		enable_read = 1'b1;
		enable_vector = 1'b1;  // not sure 
		enable_write_adj_fm_wm_pad = 1'b0;
		enable_adj_counter = 1'b0;
		enable_fm_wm_counter = 1'b0;
		done = 1'b0;
		
		next_state = INCREMENT_ADJ_COUNTER;
		end
		
		INCREMENT_ADJ_COUNTER: begin
		enable_decode = 1'b0;
	//	enable_scratch_pad = 1'b0;
		enable_read = 1'b1;
		enable_write_adj_fm_wm_pad = 1'b1;
		enable_adj_counter = 1'b1;
		enable_fm_wm_counter = 1'b0;
		enable_vector = 1'b0; 
		done = 1'b0;

		if (adj_count == FEATURE_ROWS - 1 && fm_wm_count == WEIGHT_COLS - 1)begin
			next_state = DONE;
		end
		else if (adj_count == FEATURE_ROWS - 1) begin
			next_state  = INCREMENT_FM_WM_COUNTER;
		end
		else begin
			next_state  = READ_ADJ_DATA;
		end
	  end
	  
	  DONE: begin
	  	enable_decode = 1'b0;
	//	enable_scratch_pad = 1'b0;
		enable_read = 1'b0;
		enable_write_adj_fm_wm_pad = 1'b0;
		enable_adj_counter = 1'b0;
		enable_fm_wm_counter = 1'b0;
		enable_vector = 1'b0; 
		done = 1'b1;
		
		next_state = DONE;
	  end
	
	endcase
   end

endmodule
