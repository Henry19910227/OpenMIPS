`include "src/define.v"


module id (
    input wire                      rst,
    input wire [`InstAddrBus]       pc_i,
    input wire [`InstBus]           inst_i,

    //  讀取的 Regfile 的值
    input wire [`RegBus]            reg1_data_i,
    input wire [`RegBus]            reg2_data_i,

    //  輸出到 Regfile 的訊息
    output reg                      reg1_read_o,
    output reg                      reg2_read_o,
    output reg [`RegAddrBus]        reg1_addr_o,
    output reg [`RegAddrBus]        reg2_addr_o,

    //  送到執行階段的訊息
    output reg [`AluOpBus]          aluop_o,
    output reg [`AluSelBus]         alusel_o,
    output reg [`RegBus]            reg1_o,
    output reg [`RegBus]            reg2_o,
    output reg [`RegAddrBus]        wd_o,
    output reg                      wreg_o
);

// 取得指令的指令碼,功能碼
// 對於ori 指令只需判斷第26-31bit的值,即可判斷是否為ori 指令
wire [5:0] op = inst_i[31:26];
wire [4:0] op2 = inst_i[10:6];
wire [5:0] op3 = inst_i[5:0];
wire [4:0] op4 = inst_i[20:16];
//儲存指令執行需要的立即數
reg [`RegBus] imm;
//指示指令是否有效
reg instvalid;

/***** 第一段:對指令進行解碼 *****/
always @ (*) begin
    if (rst == `RstEnable) begin
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o  <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        instvalid <= `InstValid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <= 32'h0;
    end else begin 
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= inst_i[15:11];
        wreg_o <= `WriteDisable;
        instvalid <= `InstInvalid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= inst_i[25:21]; //預設透過 Regfile讀取埠1讀取的暫存器位址
        reg2_addr_o <= inst_i[20:16]; //預設透過 Regfile 讀取埠2讀取的暫存器位址
        imm <= `ZeroWord;

        case (op)
            `EXE_ORI: begin           // 依據op 的值判斷是否為ori 指令
                // ori 指令需要將結果寫入目的暫存器,所以wreg_o為 WriteEnable
                wreg_o <= `WriteEnable;
                //運算的子型別是邏輯「或」運算
                aluop_o <= `EXE_OR_OP;
                //運算型別是邏輯運算
                alusel_o <= `EXE_RES_LOGIC;
                // 需要透過 Regfile 的讀取埠1讀取暫存器
                reg1_read_o <= 1'b1;
                //不需要透過Regfile 的讀取埠2讀取暫存器
                reg2_read_o <= 1'b0;
                // 指令執行所需的立即數
                imm <= {16'h0, inst_i[15:0]};
                //指令執行要寫的目的暫存器位址
                wd_o <= inst_i[20:16];
                // ori指令是有效指令
                instvalid <= `InstValid;
            end
            default:begin
            end
        endcase //case op
    end //if
end //always

/***** 第二段:確定運算操作數1 *****/
always @ (*) begin
    if (rst == `RstEnable) begin
        reg1_o <= `ZeroWord;
    end else if (reg1_read_o == 1'b1) begin
        reg1_o <= reg1_data_i; // Regfile 讀取埠1的輸出值
    end else if (reg1_read_o == 1'b0) begin
        reg1_o <= imm;           // 立即數
    end else begin
        reg1_o <= `ZeroWord;
    end
end

/***** 第三段:確定運算操作數2 *****/
always @ (*) begin
    if (rst == `RstEnable) begin
        reg2_o <= `ZeroWord;
    end else if (reg2_read_o == 1'b1) begin
        reg2_o <= reg2_data_i;   // Regfile 讀取埠2的輸出值
    end else if (reg2_read_o == 1'b0) begin
        reg2_o <= imm; // 立即數
    end else begin
        reg2_o <= `ZeroWord;
    end
end

endmodule