
module Vector_Multiplication 
  #(parameter FEATURE_COLS = 96,    // Number of elements in the vectors
    parameter FEATURE_WIDTH = 5,      // Bit width of each element in the vectors
    parameter DOT_PROD_WIDTH = 16  // Bit width of the result (to handle overflow)
   )
(
  input logic clk,
  input logic reset,
  input logic enable,
  input logic [FEATURE_WIDTH-1:0] feature_vector [0:FEATURE_COLS-1], // Input feature vector data_in
  input logic [FEATURE_WIDTH-1:0] weight_vector [0:FEATURE_COLS-1],  // Input weight vector weight_col_out
  output logic [DOT_PROD_WIDTH-1:0] dot_product             // Output dot product result
 // output logic done_multiplier                                               // Done signal
);


/*
  // Internal variables for accumulation
  logic [DOT_PROD_WIDTH-1:0] accumulator;
 // logic [6:0] count; // Counter for indexing into vectors

  // Sequential logic to compute the dot product
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
   //   count <= 0;
      accumulator <= 0;
      dot_product <= 0;
	end else if(enable) begin
	 for ( integer count = 0; count < FEATURE_COLS ; count = count + 1)begin
	   accumulator <= accumulator + feature_vector[count] * weight_vector[count];
      end  begin
		dot_product <= accumulator;
		accumulator <= 0;
      end
    end
  end

//	 logic [DOT_PROD_WIDTH-1:0] accumulator;
*/
  // Internal variable for accumulation
  logic [DOT_PROD_WIDTH-1:0] partial_sum [0:FEATURE_COLS-1];
  logic [DOT_PROD_WIDTH-1:0] accumulator;

  // Combinational logic for the dot product calculation
  always_comb begin
    accumulator = 0;
    for (int i = 0; i < FEATURE_COLS; i = i + 1) begin
      partial_sum[i] = feature_vector[i] * weight_vector[i];
      accumulator += partial_sum[i];
    end
  end

  // Sequential logic to store the final result
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      dot_product <= 0;
    end else if (enable) begin
      dot_product <= accumulator;
    end
  end
















endmodule


