`include "src/define.v"

module openmips_min_sopc (
    input wire clk,
    input wire rst
);
    //連接指令記憶體
    wire [`InstAddrBus] inst_addr;
    wire [`InstBus]     inst;
    wire                rom_ce;

    //例化處理器 OpenMIPS
    openmips openmips0 ( 
        .clk(clk), 
        .rst(rst), 
        .rom_addr_o(inst_addr),
        .rom_data_i(inst), 
        .rom_ce(rom_ce)
    );

    //例化指令記憶體 ROM
    inst_rom inst_rom0(
        .ce(rom_ce),
        .addr(inst_addr),
        .inst(inst)
    );

endmodule
