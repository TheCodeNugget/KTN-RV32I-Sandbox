/// --------------------------------------------------------
/// alu.sv
/// Ken The Nugget
/// 15/07/2026
/// RV32I ALU Unit
/// --------------------------------------------------------

module alu import common_pkg::*; (
    // Source operands
    input   logic [31:0] opr_a_i,
    input   logic [31:0] opr_b_i,

    // ALU Operation
    input   logic [3:0]  op_sel_i,

    // ALU output
    output  logic [31:0] alu_res_o
);

    // --------------------------------------------------------
    // Internal Signal List
    // --------------------------------------------------------

    logic [31:0] twos_comp_a;
    logic [31:0] twos_comp_b;
    logic [31:0] alu_result;

    // --------------------------------------------------------
    // ALU Logic
    // --------------------------------------------------------
    
    assign twos_comp_a = opr_a_i[31] ? ~opr_a_i + 32'h1 : opr_a_i;
    assign twos_comp_b = opr_b_i[31] ? ~opr_b_i + 32'h1 : opr_b_i;

    always_comb begin
        alu_result = 32'h0;
        case (op_sel_i)
            ADD:    alu_result = opr_a_i + opr_b_i;
            SUB: 	alu_result = opr_a_i - opr_b_i;
            SLL:	alu_result = opr_a_i << opr_b_i[4:0];
            SRL: 	alu_result = opr_a_i >> opr_b_i[4:0];
            SRA: 	alu_result = $signed(opr_a_i) >>> opr_b_i[4:0];
            OR:     alu_result = opr_a_i | opr_b_i;
            AND: 	alu_result = opr_a_i & opr_b_i;
            XOR:	alu_result = opr_a_i ^ opr_b_i;
            SLTU:   alu_result = {31'h0, (opr_a_i < opr_b_i)};
            SLT: 	begin
                if (opr_a_i[31] == opr_b_i[31]) alu_result = {31'h0, twos_comp_a < twos_comp_b};
                else alu_result = {31'h0, opr_a_i[31]};
            end
            default: alu_result = 32'h0;
        endcase
    end

    // --------------------------------------------------------
    // Output Assignments
    // --------------------------------------------------------
  
    assign alu_res_o = alu_result;
  
endmodule
