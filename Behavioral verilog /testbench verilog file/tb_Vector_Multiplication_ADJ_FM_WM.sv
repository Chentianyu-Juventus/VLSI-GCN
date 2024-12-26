`timescale 1ns/1ps

module tb_Vector_Multiplication_ADJ_FM_WM;

    // Parameters
    parameter NUM_OF_NODES = 6;
    parameter WEIGHT_COLS = 3;
    parameter DOT_PROD_WIDTH = 16;
    parameter WEIGHT_WIDTH = $clog2(WEIGHT_COLS);
    parameter FEATURE_WIDTH = $clog2(NUM_OF_NODES);

    // Inputs
    reg clk;
    reg reset;
    reg enable;
    reg [FEATURE_WIDTH-1:0] write_row;
    reg [FEATURE_WIDTH-1:0] read_row;
    reg [NUM_OF_NODES-1:0][NUM_OF_NODES-1:0] adj_vector;
    reg [DOT_PROD_WIDTH-1:0] fm_wm_vector[0:WEIGHT_COLS-1];

    // Outputs
    wire [DOT_PROD_WIDTH-1:0] dot_product[0:WEIGHT_COLS-1];

    // Instantiate the DUT (Device Under Test)
    Vector_Multiplication_ADJ_FM_WM #(
        .NUM_OF_NODES(NUM_OF_NODES),
        .WEIGHT_COLS(WEIGHT_COLS),
        .DOT_PROD_WIDTH(DOT_PROD_WIDTH)
    ) dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .write_row(write_row),
        .read_row(read_row),
        .adj_vector(adj_vector),
        .fm_wm_vector(fm_wm_vector),
        .dot_product(dot_product)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Initial block
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        enable = 0;
        write_row = 0;
        read_row = 0;

        // Initialize adjacency matrix (ADJ_matrix)
        adj_vector = '{ 
            {0, 1, 0, 0, 0, 0},
            {1, 0, 1, 0, 0, 0},
            {0, 1, 0, 1, 0, 0},
            {0, 0, 1, 0, 1, 1},
            {0, 0, 0, 1, 0, 1},
            {0, 0, 0, 0, 1, 0}
        };

        // Initialize feature matrix (FM_WM_matrix)
        // Initialize feature-weight matrix (FM_WM_matrix)
        fm_wm_vector[0] = '{11488, 0, 0};      // Row 0
        fm_wm_vector[1] = '{ 6684, 0, 0};      // Row 1
        fm_wm_vector[2] = '{ 7687, 6093, 0};   // Row 2
        fm_wm_vector[3] = '{ 7687, 9853, 8976}; // Row 3
        fm_wm_vector[4] = '{ 0, 6684, 8976};   // Row 4
        fm_wm_vector[5] = '{ 0, 6093, 6093};   // Row 5

        // Reset
        #10 reset = 0;

        // Test case: Enable computation for each row
        for (int i = 0; i < NUM_OF_NODES; i++) begin
            enable = 1;
            write_row = i;
            #10; // Wait for computation to complete
        end

        // End simulation
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | write_row: %0d | dot_product: %p", $time, write_row, dot_product);
    end

endmodule
