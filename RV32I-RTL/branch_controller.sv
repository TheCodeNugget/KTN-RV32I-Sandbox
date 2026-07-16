/// --------------------------------------------------------
/// branch_controller.sv
/// Ken The Nugget
/// 16/07/2026
/// RV32I Branch Control Unit
/// --------------------------------------------------------

module yarp_branch_control import yarp_pkg::*; (
  // Source operands
  input  logic [31:0] opr_a_i,
  input  logic [31:0] opr_b_i,

  // Branch Type
  input  logic        b_type_i,
  input  logic [2:0]  funct3_i,

  // Branch outcome
  output logic        branch_taken_o
);

    // --------------------------------------------------------
    // Internal Signal List
    // --------------------------------------------------------
    logic branch_taken;
    logic [31:0] twos_comp_a;
    logic [31:0] twos_comp_b;

    // --------------------------------------------------------
    // Branch Evaluation
    // --------------------------------------------------------

    assign twos_comp_a = opr_a_i[31] ? ~opr_a_i + 32'h1 : opr_a_i;
    assign twos_comp_b = opr_b_i[31] ? ~opr_b_i + 32'h1 : opr_b_i;

    always_comb begin
        branch_taken = 1'b0;
        case (instr_func3_ctl_i)
            BEQ:	branch_taken = opr_a_i == opr_b_i;
            BNE:	branch_taken = opr_a_i != opr_b_i;
            BLT: begin
                if (opr_a_i[31] == opr_b_i[31]) branch_taken = twos_comp_a > twos_comp_b;
                else branch_taken = opr_a_i[31];
            end
            BGE:	begin
                if (opr_a_i[31] == opr_b_i[31]) branch_taken = twos_comp_a <= twos_comp_b;
                else branch_taken = opr_b_i[31];
            end
            BLTU:   branch_taken = opr_a_i < opr_b_i;
            BGEU:	branch_taken = opr_a_i >= opr_b_i;
            default: branch_taken = 1'b0;
        endcase
    end
    
    assign branch_taken_o = branch_taken & is_b_type_ctl_i;

endmodule
