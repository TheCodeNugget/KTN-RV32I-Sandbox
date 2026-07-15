/// --------------------------------------------------------
/// data_memory.sv
/// Ken The Nugget
/// 15/07/2026
/// RV32I Data Memory Manager
/// --------------------------------------------------------

module data_memory (
    input   logic   clk,
    input   logic   reset_n,
    
    // Instruction Control Interface
    input   logic           data_req_i,
    input   logic           data_zero_extnd_i,
    input   logic           data_wr_i,
    input   logic [1:0]     data_byte_en_i,
    input   logic [31:0]    data_addr_i,
    input   logic [31:0]    data_wr_data_i,

    // Memory Unit Interface
    output  logic           data_mem_req_o,
    output  logic           data_mem_wr_o,
    output  logic [1:0]     data_mem_byte_en_o,
    output  logic [31:0]    data_mem_addr_o,
    output  logic [31:0]	data_mem_wr_data_o,
    input   logic [31:0]    mem_rd_data_i,

    // Data output
    output  logic [31:0]    data_mem_rd_data_o
);

    // --------------------------------------------------------
    // Internal Signal List
    // --------------------------------------------------------

    logic [31:0] mem_rd_data_z_extend;
    logic [31:0] mem_rd_data_s_extend;
    logic [31:0] mem_rd_data_processed;

    // --------------------------------------------------------
    // Data Handling
    // --------------------------------------------------------
  
    always_comb begin
        case (data_byte_en_i)
            BYTE: mem_rd_data_z_extend 		= {24'h0, mem_rd_data_i[7:0]};
            HALF: mem_rd_data_z_extend 		= {16'h0, mem_rd_data_i[15:0]};
            WORD: mem_rd_data_z_extend 		= mem_rd_data_i;
            default: mem_rd_data_z_extend   = 32'h0;
        endcase
    
        case (data_byte_en_i)
            BYTE: mem_rd_data_s_extend		= {{24{mem_rd_data_i[7]}} ,mem_rd_data_i[7:0]};
            HALF: mem_rd_data_s_extend 		= {{16{mem_rd_data_i[15]}} ,mem_rd_data_i[15:0]};
            WORD: mem_rd_data_s_extend 		= mem_rd_data_i;
            default: mem_rd_data_s_extend   = 32'h0;
        endcase
    end
  
    assign mem_rd_data_processed = (data_zero_extnd_i) ? mem_rd_data_z_extend : mem_rd_data_s_extend;

    // --------------------------------------------------------
    // Output Assignments
    // --------------------------------------------------------

    assign data_mem_wr_o		= data_wr_i;
    assign data_mem_req_o		= data_req_i;
    assign data_mem_addr_o	    = data_addr_i;
    assign data_mem_byte_en_o   = data_byte_en_i;
    assign data_mem_wr_data_o   = data_wr_data_i;

    assign data_mem_rd_data_o   = mem_rd_data_processed;

endmodule
