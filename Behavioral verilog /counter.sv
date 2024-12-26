module counter
  #(
    parameter FEATURE_ROWS = 6,
    parameter WEIGHT_COLS = 3,
    parameter ADDRESS_WIDTH = 13,   // Width of the read address
    parameter COUNTER_WEIGHT_WIDTH = $clog2(WEIGHT_COLS),
    parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS)
  )
(
	input logic clk,
	input logic reset,
	input logic enable_feature_counter,
	input logic enable_weight_counter,
	input logic read_feature_or_weight,
	
	output logic [ADDRESS_WIDTH-1:0] read_address, // Address output for data read
    output logic [COUNTER_FEATURE_WIDTH-1:0] feature_count, // Feature counter value
    output logic [COUNTER_WEIGHT_WIDTH-1:0] weight_count,  // Weight counter value
	output logic [COUNTER_FEATURE_WIDTH-1:0] read_row  // New signal for read_row
);

//feature counter
always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
		  feature_count <= 0;
		end else if (enable_feature_counter && read_feature_or_weight)begin
		  feature_count <= feature_count+1;
		  if (feature_count == FEATURE_ROWS - 1)begin
		    feature_count<=0;
		  end
		end
	end
	
//weight counter
always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
		  weight_count <= 0;
		end else if (enable_weight_counter && !read_feature_or_weight)begin
		  weight_count <= weight_count+1;
		  if (weight_count == WEIGHT_COLS - 1)begin
		    weight_count<=0;
		  end
		end
	end
//read address generation
always_comb begin
	if(read_feature_or_weight) begin
	// read address for feature data
		read_address = 10'b10_0000_0000 + feature_count;
	end else begin
	// read address for weight data
		read_address = weight_count;
	end
  end


// Read row assignment
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        read_row <= 0;
    end else if (enable_feature_counter) begin
        read_row <= feature_count;  // Use feature_count as read_row
    end
end



 
endmodule
		  
