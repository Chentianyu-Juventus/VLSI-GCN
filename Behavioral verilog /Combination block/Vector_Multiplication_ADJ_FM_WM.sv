
module Vector_Multiplication_ADJ_FM_WM
	#(parameter NUM_OF_NODES = 6,
	  parameter WEIGHT_COLS = 3,
	  parameter DOT_PROD_WIDTH = 16,
	  parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
      parameter COUNTER_FEATURE_WIDTH = $clog2(NUM_OF_NODES)
)

(
	input  logic  clk,
	input  logic reset,
	input  logic enable,
	
    input  logic [COUNTER_FEATURE_WIDTH-1:0] write_row,  // Row address to write into memory
    input  logic [COUNTER_FEATURE_WIDTH-1:0] read_row,  // Row address to read from memory
	
	
	input  logic  [NUM_OF_NODES-1:0][NUM_OF_NODES-1:0] adj_vector , // Output adjacency matrix
	input  logic [DOT_PROD_WIDTH-1:0] fm_wm_vector [0:WEIGHT_COLS -1 ],
	output logic  [DOT_PROD_WIDTH-1:0] dot_product  [0:WEIGHT_COLS -1 ]
);


//internal buffer for fm_wm matrix
logic [DOT_PROD_WIDTH-1:0] fm_wm_buffer[0:NUM_OF_NODES-1][0:WEIGHT_COLS-1];
//logic  [NUM_OF_NODES-1:0] [NUM_OF_NODES-1:0] adj_buffer;





//reset and Initialize
always_ff @(posedge clk or posedge reset) begin
	if(reset) begin
	
		//clear buffers
		for (int i = 0;i<NUM_OF_NODES;i++) begin
			for (int j = 0;j<WEIGHT_COLS; j++) begin
				fm_wm_buffer[i][j] <= 0;
	    end
	end
	
	end else if (enable) begin
		
	
	//load the current row of fm_wm into the buffer
	for (int j = 0;j<WEIGHT_COLS;j++) begin
		fm_wm_buffer[ write_row][j] <= fm_wm_vector[j];
	end
  end
 end



always_comb begin

for (int j = 0;j< WEIGHT_COLS;j++) begin
	dot_product[j] = 0;
end

for (int j = 0;j<WEIGHT_COLS;j++) begin
	for(int k = 0;k<NUM_OF_NODES;k++) begin
//	fm_wm_col = fm_wm_buffer[k][j];
	dot_product[j] = dot_product[j] + adj_vector[read_row][k] * fm_wm_buffer[k][j];
	end
end
    
end

endmodule
