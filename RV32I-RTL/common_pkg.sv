/// --------------------------------------------------------
/// common_pkg.sv
/// Ken The Nugget
/// 14/07/2026
/// RV32I Common ENUMS, Structs, etc
/// --------------------------------------------------------

package common_pkg;

    // Instruction Types
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

    // ALU Operations
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

    // Memory Access Types
    typedef enum logic [1:0] {
        BYTE,
        HALF,
        RSVD,
        WORD
    } mem_access_t;

    // R-Type Instructions
    // Format: {funct7[5], funct3}
    typedef enum logic [3:0] {
        ADD		= 4'b0000,
        SUB		= 4'b1000,
        SLL		= 4'b0001,
        SLT		= 4'b0010,
        SLTU 	= 4'b0011,
        XOR		= 4'b0100,
        SRL		= 4'b0101,
        SRA		= 4'b1101,
        OR		= 4'b0110,
        AND		= 4'b0111
    } r_inst_t;

    // I-Type Instruction
    // Format: {opcode[4], funct3}
    typedef enum logic [3:0] {
        LB		= 4'b0000,
        LH		= 4'b0001,
        LW		= 4'b0010,
        LBU		= 4'b0100,
        LHU		= 4'b0101,
        ADDI	= 4'b1000,
        SLTI	= 4'b1010,
        SLTIU	= 4'b1011,
        XORI	= 4'b1100,
        ORI		= 4'b1110,
        ANDI	= 4'b1111,
        SLLI	= 4'b1001,
        SRXI	= 4'b1101
    } i_inst_t;
  
    // S-Type Instruction
    typedef enum logic [2:0] {
        SB		= 3'b000,
        SH		= 3'b001,
        SW		= 3'b010
    } s_inst_t;
  
    // B-Type Instruction
    typedef enum logic [2:0] {
        BEQ		=	3'b000,
        BNE		=	3'b001,
        BLT		=	3'b100,
        BGE		=	3'b101,
        BLTU	=	3'b110,
        BGEU	=	3'b111
    } b_inst_t;
  
    // U-Type Instruction
    typedef enum logic [6:0] {
        AUIPC	= 7'b0010111,
        LUI		= 7'b0110111
    } u_inst_t;
  
    // j-Type Instruction
    typedef enum logic [5:0] {
        JAL 	= 6'h3
    } j_inst_t;
  
    // Register File Write Source
    typedef enum logic [1:0] {
        ALU,
        MEM,
        IMM,
        PC
    } rf_wr_src_t;
  
    // Instruction Control Packet
    typedef struct packed {
        logic 		pc_sel;
        logic		op1_sel;
        logic		op2_sel;
        logic		data_req;
        logic		data_wr;
        logic		zero_extnd;
        logic		rf_wr_en;
        logic [1:0]	data_byte;
        logic [1:0]	rf_wr_src;
        logic [3:0] alu_func;
    } ctrl_packet_t;

endpackage
