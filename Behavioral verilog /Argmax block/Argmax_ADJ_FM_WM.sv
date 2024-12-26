module Argmax_ADJ_FM_WM   
  #(parameter FEATURE_ROWS = 6,    // Number of rows in ADJ_FM_WM
    parameter WEIGHT_COLS = 3,     // Number of columns in ADJ_FM_WM
    parameter DOT_PROD_WIDTH = 16, // Bit-width of each matrix value
    parameter MAX_ADDRESS_WIDTH = 2, // Width of the max column index
    parameter COUNTER_FEATURE_WIDTH = $clog2(FEATURE_ROWS)
  )
(
    input  logic clk,
    input  logic reset,
    input  logic [DOT_PROD_WIDTH-1:0] fm_wm_adj_row_in [0:FEATURE_ROWS-1][0:WEIGHT_COLS-1], // Input matrix
    input  logic done_comb, // Signal to start computation
	output logic done,
    output logic [MAX_ADDRESS_WIDTH-1:0] max_addi_answer [0:FEATURE_ROWS-1] // Output array: max column index per row
);

  // Internal registers
  logic [COUNTER_FEATURE_WIDTH-1:0] row_select; // Internally generated row index
  logic [DOT_PROD_WIDTH-1:0] max_value; // Holds the maximum value in the row
  logic [MAX_ADDRESS_WIDTH-1:0] max_index; // Holds the column index of the maximum value

  // Internal counter for row selection
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      row_select <= 0;
	//  done < = 0;
    end else if (done_comb) begin
      if (row_select < FEATURE_ROWS - 1) begin
        row_select <= row_select + 1;
      end else begin
        row_select <= 0; // Reset to the first row after the last row
	//	done <= 1;
      end
    end
  end

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      // Reset all output values
      for (int i = 0; i < FEATURE_ROWS; i++) begin
        max_addi_answer[i] <= 0;
      end
      max_value <= 0;
      max_index <= 0;
    end else if (done_comb) begin
      // Process the row selected by `row_select`
      max_value = fm_wm_adj_row_in[row_select][0];
      max_index = 0;

      // Find the maximum value and column index in the selected row
      for (int col = 1; col < WEIGHT_COLS; col++) begin
        if (fm_wm_adj_row_in[row_select][col] > max_value) begin
          max_value = fm_wm_adj_row_in[row_select][col];
          max_index = col[1:0]; // Extract 2-bit column index
        end
      end

      // Store the result in `max_addi_answer` for the corresponding row
      max_addi_answer[row_select] <= max_index;
    end
  end

  // Generate the done signal
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      done <= 0; // Reset the done signal
    end else if (done_comb && (row_select == FEATURE_ROWS - 1)) begin
      done <= 1; // Assert done signal after the last row is processed
    end else begin
      done <= 0; // De-assert done signal otherwise
    end
  end



endmodule			
     
