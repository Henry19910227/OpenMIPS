`include "src/define.v"

module inst_rom(
    input wire                  ce,
    input wire [`InstAddrBus]   addr,
    output reg [`InstBus]       inst
);
    //定義一個陣列,大小是InstMemNum,元素寬度是 InstBus
    reg[`InstBus] inst_mem[0: `InstMemNum-1];

    // 使用檔案 inst_rom.data 初始化指令記憶體
    initial $readmemh ("inst_rom.data", inst_mem);
    
    //當重設訊號無效時,依據輸入的位址,給出指令記憶體 ROM中對應的元素
    always @ (*) begin
        if (ce == `ChipDisable) begin
            inst <= `ZeroWord;
        end else begin
            inst <= inst_mem [addr[`InstMemNumLog2+1:2]];
        end
    end

endmodule