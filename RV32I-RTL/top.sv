/// --------------------------------------------------------
/// top.sv
/// Ken The Nugget
/// 17/07/2026
/// RV32I CPU Top
/// --------------------------------------------------------

module top import common_pkg::*; (
    parameter RESET_PC = 32'h1000;
) (
    input   logic   clk,
    input   logic   reset_n,

    // Instruction Fetch Interface
    input   logic [31:0]    instr_fetch_rd_data_i,
    output  logic           instr_fetch_req_o,
    output  logic [31:0]    instr_fetch_addr_o,

    // Data Memory Interface
    input   logic [31:0]    data_mem_rd_data_i,
    output  logic           data_mem_wr_o,
    output  logic           data_mem_req_o,
    output  logic [1:0]     data_mem_byte_en_o,
    output  logic [31:0]    data_mem_addr_o,
    output  logic [31:0]    data_mem_wr_data_o
);

    // --------------------------------------------------------
    // Internal Signal List
    // --------------------------------------------------------
    
    // Top Level Signals
    logic           reset_seen;
    logic [31:0]	pc_q, pc_next, pc_next_seq;

    // Instruction Fetch Signals
    logic [31:0]    fetch_instr;

    // Instruction Decode Signals
    logic           r_type, i_type, s_type, b_type, u_type, j_type;
    logic [4:0]     dec_rs1_addr, dec_rs2_addr, dec_rd_addr;
    logic [6:0]     dec_opcode;
    logic [2:0]     dec_funct3;
    logic [6:0]     dec_funct7;
    logic [31:0]    dec_imm;

    // Register File Signals
    logic [31:0]    rf_wr_data_mux;
    logic [31:0]    rf_rs1_data, rf_rs2_data;

    // Control Unit Signals
    logic           ctrl_pc_sel;
    logic           ctrl_op1_sel;
    logic           ctrl_op2_sel;
    logic           ctrl_data_req;
    logic           ctrl_data_wr;
    logic           ctrl_zero_extnd;
    logic           ctrl_rf_wr_en;
    logic [1:0]     ctrl_data_byte;
    logic [1:0]     ctrl_rf_wr_src;
    logic [3:0]     ctrl_alu_func;


    // Branch Controller Signals
    logic           branch_taken;

    // ALU Signals
    logic [31:0]    alu_opa_mux, alu_opb_mux;
    logic [31:0]    alu_result;

    // Data Memory Signals
    logic [31:0]    dmem_rd_data;

    // --------------------------------------------------------
    // Top Level Logic
    // --------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) reset_seen <= 1'b0;
        else reset_seen <= 1'b1;
    end

    assign pc_next_seq <= pc_q + 32'h4;
    assign pc_next <= (branch_taken | ctrl_pc_sel) ? {alu_result[31:1], 1'b0} : pc_next_seq;
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) pc_q <= RESET_PC;
        else if (reset_seen) pc_q <= pc_next;
    end

    // --------------------------------------------------------
    // Instruction Fetch
    // --------------------------------------------------------

    instr_fetch u_instr_fetch (
        .clk                    (clk),
        .reset_n                (reset_n),
        .instr_pc_i             (pc_q),
        .mem_rd_data_i          (instr_fetch_rd_data_i),
        .instr_req_o            (instr_fetch_req_o),
        .instr_addr_o           (instr_fetch_addr_o),
        .instr_o                (fetch_instr)
    );

    // --------------------------------------------------------
    // Instruction Decode
    // --------------------------------------------------------
    
    instr_decoder u_instr_decoder (
        .instr_i                (fetch_instr),
        .rs1_o                  (dec_rs1_addr),
        .rs2_o                  (dec_rs2_addr),
        .rd_o                   (dec_rd_addr),
        .op_o                   (dec_opcode),
        .funct3_o               (dec_funct3),
        .funct7_o               (dec_funct7),
        .r_type_o               (r_type),
        .i_type_o               (i_type),
        .s_type_o               (s_type),
        .b_type_o               (b_type),
        .u_type_o               (u_type),
        .j_type_o               (j_type),
        .instr_imm_o            (dec_imm)
    );

    // --------------------------------------------------------
    // Register File
    // --------------------------------------------------------

    always_comb begin
        case(ctrl_rf_wr_src)
        ALU:    rf_wr_data_mux = alu_result;
        MEM:    rf_wr_data_mux = dmem_rd_data;
        IMM:    rf_wr_data_mux = dec_imm;
        PC:     rf_wr_data_mux = pc_next_seq;
    end

    register_file u_register_file (
        .clk                    (clk),
        .reset_n                (reset_n),
        .rs1_addr_i             (dec_rs1_addr),
        .rs2_addr_i             (dec_rs2_addr),
        .wr_en_i                (ctrl_rf_wr_en),
        .rd_addr_i              (rd_addr_i),
        .wr_data_i              (rf_wr_data_mux),
        .rs1_data_o             (rf_rs1_data),
        .rs2_data_o             (rf_rs2_data)
    );

    // --------------------------------------------------------
    // Control Unit
    // --------------------------------------------------------

    controller u_controller (
        .funct7_bit5_i          (dec_funct7[5]),
        .funct3_i               (dec_funct3),
        .opcode_i               (dec_opcode),
        .r_type_i               (r_type),
        .i_type_i               (i_type),
        .s_type_i               (s_type),
        .b_type_i               (b_type),
        .u_type_i               (u_type),
        .j_type_i               (j_type),
        .pc_sel_o               (ctrl_pc_sel),
        .op1_sel_o              (ctrl_op1_sel),
        .op2_sel_o              (ctrl_op2_sel),
        .data_req_o             (ctrl_data_req),
        .data_wr_o              (ctrl_data_wr),
        .zero_extnd_o           (ctrl_zero_extnd),
        .rf_wr_en_o             (ctrl_rf_wr_en),
        .data_byte_o            (ctrl_data_byte),
        .rf_wr_src_o            (ctrl_rf_wr_src),
        .alu_func_o             (ctrl_alu_func)
    );

    // --------------------------------------------------------
    // Branch Control
    // --------------------------------------------------------

    branch_controller u_branch_controller (
        .opr_a_i                (rf_rs1_data),
        .opr_b_i                (rf_rs2_data),
        .b_type_i               (b_type),
        .funct3_i               (dec_funct3),
        .branch_taken_o         (branch_taken)
    );

    // --------------------------------------------------------
    // ALU
    // --------------------------------------------------------

    assign alu_opa_mux = (ctrl_op1_sel) ? pc_q : rf_rs1_data;
    assign alu_opb_mux = (ctrl_op2_sel) ? dec_imm : rf_rs2_data;

    alu u_alu (
        .opr_a_i                (alu_opa_mux),
        .opr_b_i                (alu_opb_mux),
        .op_sel_i               (ctrl_alu_func),
        .alu_res_o              (alu_result)
    );

    // --------------------------------------------------------
    // Data Memory
    // --------------------------------------------------------

    data_memory u_data_memory (
        .clk                    (clk),
        .reset_n                (reset_n),
        .data_req_i             (ctrl_data_req),
        .data_zero_extnd_i      (ctrl_zero_extnd),
        .data_wr_i              (ctrl_data_wr),
        .data_byte_en_i         (ctrl_data_byte),
        .data_addr_i            (alu_result),
        .data_wr_data_i         (rf_rs2_data),
        .data_mem_req_o         (data_mem_req_o),
        .data_mem_wr_o          (data_mem_wr_o),
        .data_mem_byte_en_o     (data_mem_byte_en_o),
        .data_mem_addr_o        (data_mem_addr_o),
        .data_mem_wr_data_o     (data_mem_wr_data_o),
        .mem_rd_data_i          (data_mem_rd_data_i),
        .data_mem_rd_data_o     (dmem_rd_data)
    );

endmodule
