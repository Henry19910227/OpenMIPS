`include "src/define.v"

module if_id (
    input wire clk,
    input wire rst,
    //來自取指階段的訊號,其中巨集定義 InstBus 表示指令寬度,為32            
    input wire [`InstAddrBus] if_pc,
    input wire [`InstBus] if_inst,
    //對應解碼階段的訊號
    output reg [`InstAddrBus] id_pc,
    output reg [`InstBus] id_inst
);
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            id_pc <= `ZeroWord;         //重設的時候pc為0
            id_inst <= `ZeroWord;       //重設的時候指令也為0,實際上是空指令
        end else begin
            id_pc <= if_pc;
            id_inst <= if_inst;         // 其餘時刻向下傳遞取指階段的值
        end
    end
endmodule