`include "src/define.v"

module pc_reg (
    input wire clk,
    input wire rst,
    output reg[`InstAddrBus] pc,
    output reg ce
);

    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            ce <= `ChipDisable; //重設的時候指令記憶體停用
        end else begin
            ce <= `ChipEnable;  // 重設結束後,指令記憶體啟用
        end
    end

    always @ (posedge clk) begin
        if (ce == `ChipDisable) begin
            pc <= 32'h00000000; //指令記憶體停用的時候,PC為0
        end else begin
            pc <= pc + 4'h4;    //指令記憶體啟用的時候,PC的值每時鐘週期加4
        end
    end
    
endmodule













