/// --------------------------------------------------------
/// instr_fetch.sv
/// Ken The Nugget
/// 14/07/2026
/// RV32I Instruction Fetch - Single Cycle
/// --------------------------------------------------------

module instr_fetch (
    input   logic     clk,
    input   logic     reset_n,

    input   logic [31:0]    instr_pc_i,     // Program Counter Input
    input   logic [31:0]    mem_rd_data_i,  // Returned Instruction

    output  logic           instr_req_o,    // Instruction Request Flag
    output  logic [31:0]    instr_addr_o,   // Instruction Request Address
    output  logic [31:0]    instr_o         // Instruction Output
);

    logic instr_req_q;

    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) instr_req_q <= 1'b0;
        else instr_req_q <= 1'b1;
    end

    assign instr_req_o  = instr_req_q;
    assign instr_addr_o = instr_pc_i;
    assign instr_o      = mem_rd_data_i;
endmodule
