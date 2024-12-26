module counter_comb
	#(
	parameter FEATURE_ROWS = 6,
	parameter WEIGHT_COLS = 3,
	parameter COUNTER_WEIGHT_WIDTH = $clog2(FEATURE_ROWS),
	parameter COUNTER_FEATURE_WIDTH = $clog2(WEIGHT_COLS)
)
(input logic clk,
 input logic reset,
 input logic enable_adj_counter,
 input logic enable_fm_wm_counter,
 
 output logic [COUNTER_FEATURE_WIDTH-1:0] adj_count, // adj counter value
 output logic [COUNTER_WEIGHT_WIDTH-1:0] fm_wm_count,  // fm_wm counter value
 output logic [COUNTER_FEATURE_WIDTH-1:0] read_row  // New signal for read_row
); 
 //adj counter
always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
		  adj_count <= 0;
		end else if (enable_adj_counter )begin
		  adj_count <= adj_count+1;
		  if (adj_count == FEATURE_ROWS - 1)begin
		    adj_count<=0;
		  end
		end
	end
	
//fm_wm_count
always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
		  fm_wm_count <= 0;
		end else if (enable_fm_wm_counter )begin
		  fm_wm_count <= fm_wm_count+1;
		  if (fm_wm_count == WEIGHT_COLS - 1)begin
		    fm_wm_count<=0;
		  end
		end
	end
	
//read row assignment
always_ff @(posedge clk or posedge reset) begin
	if(reset) begin
		read_row <= 0;
	end else if (enable_adj_counter) begin
		read_row <= adj_count;          //use adj_count as read_row
	end
end

endmodule
