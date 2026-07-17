/// --------------------------------------------------------
/// controller.sv
/// Ken The Nugget
/// 16/07/2026
/// RV32I Control Unit
/// --------------------------------------------------------

module controller import common_pkg::*; (
    // Instruction Type
    input   logic   r_type_i,
    input   logic   i_type_i,
    input   logic   s_type_i,
    input   logic   b_type_i,
    input   logic   u_type_i,
    input   logic   j_type_i,

    // Instruction Fields
    input   logic       funct7_bit5_i,
    input   logic [2:0] funct3_i,
    input   logic [6:0] opcode_i,

    // Control Interface
    output  logic       pc_sel_o,       // PC MUX Select ? JMP TGT : PC + 4
    output  logic       op1_sel_o,      // ALU OP-A MUX Select ? PC : RS1
    output  logic       op2_sel_o,      // ALU OP-B MUX Select ? IMM : RS2
    output  logic       data_req_o,     // Data Memory Request Flag
    output  logic       data_wr_o,      // Data Memory WR/RD Select
    output  logic       zero_extnd_o,   // ZERO Extend Flag for Data Memory
    output  logic       rf_wr_en_o,     // Register File WR/RD Select
    output  logic [1:0] data_byte_o,    // Data RD/WR Length Select
    output  logic [1:0] rf_wr_src_o,    // Register File Write Data Source Select
    output  logic [3:0] alu_func_o      // ALU Function Select
);


    // --------------------------------------------------------
    // Internal Signal List
    // --------------------------------------------------------
    logic [3:0] r_instr_code;
    logic [3:0] i_instr_code;
    ctrl_packet_t r_instr_ctrl;
    ctrl_packet_t i_instr_ctrl;
    ctrl_packet_t s_instr_ctrl;
    ctrl_packet_t b_instr_ctrl;
    ctrl_packet_t u_instr_ctrl;
    ctrl_packet_t j_instr_ctrl;
    ctrl_packet_t mux_instr_ctrl;

    // --------------------------------------------------------
    // R-Type Handling
    // --------------------------------------------------------
    assign r_instr_code = {funct7_bit5_i, funct3_i};
    always_comb begin
        r_instr_ctrl = '0;
        r_instr_ctrl.rf_wr_en = 1'b1;
        case (r_instr_code)
            ADD:        r_instr_ctrl.alu_func = ALU_ADD;
            SUB:        r_instr_ctrl.alu_func = ALU_SUB;
            SLL:        r_instr_ctrl.alu_func = ALU_SLL;
            SLT:        r_instr_ctrl.alu_func = ALU_SLT;
            SLTU:       r_instr_ctrl.alu_func = ALU_SLTU;
            XOR:        r_instr_ctrl.alu_func = ALU_XOR;
            SRL:        r_instr_ctrl.alu_func = ALU_SRL;
            SRA:        r_instr_ctrl.alu_func = ALU_SRA;
            OR:         r_instr_ctrl.alu_func = ALU_OR;
            AND:        r_instr_ctrl.alu_func = ALU_AND;
            default:    r_instr_ctrl.alu_func = ALU_ADD;
        endcase
    end

    // --------------------------------------------------------
    // I-Type Handling
    // --------------------------------------------------------
    assign i_instr_code = {opcode_i[4], funct3_i};
    always_comb begin
        i_instr_ctrl = '0;
        i_instr_ctrl.rf_wr_en = 1'b1;
        case (i_instr_code)
            LB: begin
                i_instr_ctrl.data_req   = 1'b1;
                i_instr_ctrl.data_byte  = BYTE;
                i_instr_ctrl.rf_wr_src  = MEM;
            end
            LH: begin
                i_instr_ctrl.data_req   = 1'b1;
                i_instr_ctrl.data_byte  = HALF;
                i_instr_ctrl.rf_wr_src  = MEM;
            end
            LW: begin
                i_instr_ctrl.data_req   = 1'b1;
                i_instr_ctrl.data_byte  = WORD;
                i_instr_ctrl.rf_wr_src  = MEM;
            end
            LBU: begin
                i_instr_ctrl.data_req 	= 1'b1;
                i_instr_ctrl.data_byte  = BYTE;
                i_instr_ctrl.rf_wr_src  = MEM;
                i_instr_ctrl.zero_extnd = 1'b1;
            end
            LHU: begin
                i_instr_ctrl.data_req   = 1'b1;
                i_instr_ctrl.data_byte  = HALF;
                i_instr_ctrl.rf_wr_src  = MEM;
                i_instr_ctrl.zero_extnd = 1'b1;
            end
            ADDI:		i_instr_ctrl.alu_func = ALU_ADD;
            SLTI:		i_instr_ctrl.alu_func = ALU_SLT;
            SLTIU:		i_instr_ctrl.alu_func = ALU_SLTU;
            XORI:		i_instr_ctrl.alu_func = ALU_XOR;
            ORI:		i_instr_ctrl.alu_func = ALU_OR;
            ANDI:		i_instr_ctrl.alu_func = ALU_AND;
            SLLI:		i_instr_ctrl.alu_func = ALU_SLL;
            SRXI:	    i_instr_ctrl.alu_func = (instr_funct7_bit5_i) ? ALU_SRA : ALU_SRL;
            default:    i_instr_ctrl = '0;
        endcase

        if ((instr_opcode_i == I_TYPE_2)) begin
            i_instr_ctrl.rf_wr_src  = PC;
            i_instr_ctrl.pc_sel     = 1'b1;
            i_instr_ctrl.alu_func   = ALU_ADD;
        end  
    end

    // --------------------------------------------------------
    // S-Type Handling
    // --------------------------------------------------------
    always_comb begin
        s_instr_ctrl            = '0;
        s_instr_ctrl.data_req   = 1'b1;
        s_instr_ctrl.data_wr	= 1'b1;
        s_instr_ctrl.op2_sel	= 1'b1;
        case (instr_funct3_i)
            SB:	        s_instr_ctrl.data_byte = BYTE;
            SH:	        s_instr_ctrl.data_byte = HALF;
            SW:	        s_instr_ctrl.data_byte = WORD;
            default:    s_instr_ctrl = '0;
        endcase
    end

    // --------------------------------------------------------
    // B-Type Handling
    // --------------------------------------------------------
    always_comb begin
        b_instr_ctrl            = '0;
        b_instr_ctrl.alu_func   = ALU_ADD;
        b_instr_ctrl.op1_sel	= 1'b1;
        b_instr_ctrl.op2_sel	= 1'b1;
    end

    // --------------------------------------------------------
    // U-Type Handling
    // --------------------------------------------------------
    always_comb begin
        u_instr_ctrl            = '0;
        u_instr_ctrl.rf_wr_en   = 1'b1;
        case (instr_opcode_i)
            AUIPC:   	{u_instr_ctrl.op2_sel, u_instr_ctrl.op1_sel} = {1'b1, 1'b1};
            LUI:   		u_instr_ctrl.rf_wr_src = IMM;
            default:    u_instr_ctrl = '0;
        endcase
    end

    // --------------------------------------------------------
    // J-Type Handling
    // --------------------------------------------------------
    always_comb begin
        j_instr_ctrl            = '0;
        j_instr_ctrl.rf_wr_en   = 1'b1;
        j_instr_ctrl.rf_wr_src  = PC;
        j_instr_ctrl.op2_sel    = 1'b1;
        j_instr_ctrl.op1_sel    = 1'b1;
        j_instr_ctrl.pc_sel     = 1'b1;
    end

    // --------------------------------------------------------
    // Instruction Control Multiplexing
    // --------------------------------------------------------
    assign mux_instr_ctrl = is_r_type_i ? r_instr_ctrl :
                            is_i_type_i ? i_instr_ctrl :
                            is_s_type_i ? s_instr_ctrl :
                            is_b_type_i ? b_instr_ctrl :
                            is_u_type_i ? u_instr_ctrl :
                            is_j_type_i ? j_instr_ctrl :
                                        '0;

    // --------------------------------------------------------
    // Output Assignments
    // --------------------------------------------------------
    assign pc_sel_o     = mux_instr_ctrl.pc_sel;
    assign op1sel_o     = mux_instr_ctrl.op1_sel;
    assign op2sel_o     = mux_instr_ctrl.op2_sel;
    assign alu_func_o   = mux_instr_ctrl.alu_func;
    assign rf_wr_en_o   = mux_instr_ctrl.rf_wr_en;
    assign data_req_o   = mux_instr_ctrl.data_req;
    assign data_byte_o  = mux_instr_ctrl.data_byte;
    assign data_wr_o    = mux_instr_ctrl.data_wr;
    assign zero_extnd_o = mux_instr_ctrl.zero_extnd;
    assign rf_wr_data_o = mux_instr_ctrl.rf_wr_src;

endmodule
