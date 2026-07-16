/// --------------------------------------------------------
/// instr_decoder.sv
/// Ken The Nugget
/// 14/07/2026
/// RV32I Common ENUMS, Structs, etc
/// --------------------------------------------------------

package common_pkg;

    typedef enum logic [6:0] {  
        R_TYPE      = 7'h33;
        I_TYPE_0    = 7'h03;
        I_TYPE_1    = 7'h13;
        I_TYPE_2    = 7'h67;
        S_TYPE      = 7'h23;
        B_TYPE      = 7'h63;
        U_TYPE_0    = 7'h37;
        U_TYPE_1    = 7'h17;
        J_TYPE      = 7'h6F;
    } riscv_op_t;

    typedef enum logic [3:0] {
        ALU_ADD,
        ALU_SUB,
        ALU_SLL,
        ALU_SRL,
        ALU_SRA,
        ALU_OR,
        ALU_AND,
        ALU_XOR,
        ALU_SLTU,
        ALU_SLT
    } alu_op_t;

    typedef enum logic [1:0] {
        BYTE,
        HALF,
        RSVD,
        WORD
    } mem_access_t;

endpackage
