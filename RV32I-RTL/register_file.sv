/// --------------------------------------------------------
/// instr_decoder.sv
/// Ken The Nugget
/// 14/07/2026
/// RV32I Register File
/// --------------------------------------------------------

module register_file (
    input   logic   clk,
    input   logic   reset_n,

    // Read Interface
    input   logic [4:0]     rs1_addr_i,
    input   logic [4:0]     rs2_addr_i,

    output  logic [31:0]    rs1_data_o,
    output  logic [31:0]    rs2_data_o,

    // Write Interface
    input   logic           wr_en_i,
    input   logic [4:0]     rd_addr_i,
    input   logic [31:0]    wr_data_i
);

    // 2D-Array Register File
    logic [31:0] [31:0] regfile;

    // Hardwire X0 to 0 As described by ISA
    always_ff (negedge reset_n) begin
        regfile[0] <= 32'h0;
    end

    // Generate Block for rest of the registers
    generate
        for (genvar i = 1; i < 32; i++) begin
            logic wr_en;
            assign wr_en = wr_en_i & (rd_addr_i == i[4:0]);
            always_ff (posedge clk) begin
                regfile[i] <= wr_data_i;
            end
        end
    endgenerate

    // Read Outputs
    assign rs1_data_o = regfile[rs1_addr_i];
    assign rs2_data_o = regfile[rs2_addr_i];
endmodule