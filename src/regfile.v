`include "src/define.v"

module regfile (
    input wire clk,
    input wire rst,
    // 寫入連接埠
    input wire we,
    input wire [`RegAddrBus] waddr,
    input wire [`RegBus] wdata,
    // 讀取連接埠1
    input wire re1,
    input wire [`RegAddrBus] raddr1,
    output reg [`RegBus] rdata1,
    // 讀取連接埠2
    input wire re2,
    input wire [`RegAddrBus] raddr2,
    output reg[`RegBus] rdata2
);



// 第一段:定義32個32位元暫存器
reg[`RegBus] regs[0: `RegNum-1];



// 第二段:寫入操作
    always @ (posedge clk) begin
        if (rst == `RstDisable) begin
            if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
                regs[waddr] <= wdata;
            end
        end
    end



// 第三段:讀取埠1的讀取操作
    always @ (*) begin
        if(rst == `RstEnable) begin
            rdata1 <= `ZeroWord;
        end else if(raddr1 == `RegNumLog2'h0) begin
            rdata1 <= `ZeroWord;
        end else if((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin
            rdata1 <= wdata;
        end else if(re1 == `ReadEnable) begin
            rdata1 <= regs[raddr1];
        end else begin
            rdata1 <= `ZeroWord;
        end
    end



// 第四段:讀取連接埠2的讀取操作
    always @ (*) begin
        if (rst == `RstEnable) begin
            rdata2 <= `ZeroWord;
        end else if (raddr2 == `RegNumLog2'h0) begin
            rdata2 <= `ZeroWord;
        end else if ((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) begin
            rdata2 <= wdata;
        end else if(re2 == `ReadEnable) begin
            rdata2 <= regs[raddr2];
        end else begin
            rdata2 <= `ZeroWord;
        end
    end

endmodule
