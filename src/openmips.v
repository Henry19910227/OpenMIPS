`include "src/define.v"
`include "src/id.v"
`include "src/regfile.v"

module openmips (
    input wire              clk,
    input wire              rst,
    input wire [`RegBus]    rom_data_i,
    output wire [`RegBus]   rom_addr_o,
    output wire             rom_ce_o
);

    // 連接IF/ID模組與譯碼階段ID模組的變數
    wire [`InstAddrBus] pc;
    wire [`InstAddrBus] id_pc_i;
    wire [`InstBus]     id_inst_i;

    //連接譯碼階段ID模組輸出與ID/EX模組的輸入的變數
    wire [`AluOpBus]    id_aluop_o;
    wire [`AluSelBus]   id_alusel_o;
    wire [`RegBus]      id_reg1_o;
    wire [`RegBus]      id_reg2_o;
    wire                id_wreg_o;
    wire [`RegAddrBus]  id_wd_o;

    // 連接 ID/EX模組輸出與執行階段EX模組的輸入的變數
    wire [`AluOpBus]    ex_aluop_i;
    wire [`AluSelBus]   ex_alusel_i;
    wire [`RegBus]      ex_reg1_i;
    wire [`RegBus]      ex_reg2_i;
    wire                ex_wreg_i;
    wire [`RegAddrBus]  ex_wd_i;

    //連接執行階段EX模組的輸出與EX/MEM模組的輸入的變數
    wire                ex_wreg_o;
    wire [`RegAddrBus]  ex_wd_o;
    wire [`RegBus]      ex_wdata_o;

    //連接EX/MEM模組的輸出與訪存階段 MEM模組的輸入的變數
    wire                mem_wreg_i;
    wire [`RegAddrBus]  mem_wd_i;
    wire [`RegBus]      mem_wdata_i;

    //連接訪存階段MEM模組的輸出與MEM/WB模組的輸入的變數
    wire                mem_wreg_o;
    wire [`RegAddrBus]  mem_wd_o;
    wire [`RegBus]      mem_wdata_o;

    //連接MEM/WB模組的輸出與回寫階段的輸入的變數
    wire                wb_wreg_i;
    wire [`RegAddrBus]  wb_wd_i;
    wire [`RegBus]      wb_wdata_i;

    //連接譯碼階段ID模組與通用暫存器 Regfile 模組的變數
    wire                reg1_read;
    wire                reg2_read;
    wire [`RegBus]      reg1_data;
    wire [`RegBus]      reg2_data;
    wire [`RegAddrBus]  reg1_addr;
    wire [`RegAddrBus]  reg2_addr;

    // pc_reg 實例化
    pc_reg pc_reg0 ( 
        .clk(clk), 
        .rst(rst), 
        .pc(pc), 
        .ce(rom_ce_o)
    ); 

    assign rom_addr_o = pc; //指令記憶體的輸入位址就是pc的值

    // IF/ID 模組實例化
    if_id if_id0 (
        .clk(clk), 
        .rst(rst), 
        .if_pc(pc), 
        .if_inst(rom_data_i), 
        .id_pc(id_pc_i),  
        .id_inst(id_inst_i)
    );

    // 譯碼階段 ID模組例化
    id id0 (
        .rst(rst), 
        .pc_i(id_pc_i), 
        .inst_i(id_inst_i),
        // 來自 Regfile 模組的輸入
        .reg1_data_i(reg1_data), 
        .reg2_data_i(reg2_data),
        // 送到 regfile 模組的訊息
        .reg1_read_o(reg1_read), 
        .reg1_addr_o(reg1_addr),
        .reg2_read_o(reg2_read), 
        .reg2_addr_o(reg2_addr),
        //送到ID/EX模組的訊息
        .aluop_o(id_aluop_o), 
        .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o),  
        .reg2_o(id_reg2_o),
        .wd_o(id_wd_o), 
        .wreg_o(id_wreg_o)
    );

    // 通用暫存器 Regfile 模組例化
    regfile regfile1 (
        .clk(clk),
        .we(wb_wreg_i),
        .wdata(wb_wdata_i),
        .raddr1(reg1_addr),
        .re2(reg2_read),
        .rst(rst),
        .waddr(wb_wd_i),
        .re1(reg1_read),
        .rdata1(reg1_data),
        .raddr2(reg2_addr),
        .rdata2(reg2_data)
    );

    // ID/EX模組例化
    id_ex id_ex0 (
        .clk(clk),
        .rst(rst),
        // 從譯碼階段ID模組傳遞過來的訊息
        .id_aluop(id_aluop_o),
        .id_reg1(id_reg1_o),
        .id_wd(id_wd_o),
        //傳遞到執行階段EX模組的訊息
        .ex_aluop(ex_aluop_i),
        .ex_reg1(ex_reg1_i),
        .ex_wd(ex_wd_i),
        .id_alusel(id_alusel_o),
        .id_reg2(id_reg2_o),
        .id_wreg(id_wreg_o),
        .ex_alusel(ex_alusel_i),
        .ex_reg2(ex_reg2_i),
        .ex_wreg(ex_wreg_i) 
    );

    // EX模組例化
    ex ex0 (
        .rst(rst),
        //從ID/EX模組傳遞過來的訊息
        .aluop_i(ex_aluop_i),
        .regl_i(ex_regl_i),
        .wd_i(ex_wd_i),
        //輸出到EX/MEM模組的訊息
        .wd_o(ex_wd_o),
        .wdata_o(ex_wdata_o)
    );


    // EX/MEM模組例化
    ex_mem ex_mem0 (
        .clk(clk),
        // 來自執行階段EX模組的訊息
        .ex_wd(ex_wd_o),
        .ex_wdata(ex_wdata_o),
        //送到訪存階段MEM模組的訊息
        .mem_wd(mem_wd_i),
        .mem_wdata(mem_wdata_i),
        .alusel_i(ex_alusel_i),
        .reg2_i(ex_reg2_i),
        .wreg_i(ex_wreg_i),
        .wreg_o(ex_wreg_o),
        .rst(rst),
        .ex_wreg(ex_wreg_o),
        .mem_wreg(mem_wreg_i)
    );

    // MEM模組例化
    mem mem0 (
        .rst(rst),
        // 來自EX/MEM模組的訊息
        .wd_i(mem_wd_i), 
        .wdata_i(mem_wdata_i), 
        .wreg_i(mem_wreg_i),
        //送到MEM/WB模組的訊息
        .wd_o(mem_wd_o), 
        .wdata_o(mem_wdata_o),
        .wreg_o(mem_wreg_o)
    );

    // MEM/WB 模組例化
    mem_wb mem_wb0 (
        .clk(clk),
        .rst(rst),
        // 來自訪存階段MEM模組的訊息
        .mem_wd(mem_wd_o), 
        .mem_wreg(mem_wreg_o),
        .mem_wdata(mem_wdata_o),
        //送到回寫階段的訊息
        .wb_wd(wb_wd_i), 
        .wb_wreg(wb_wreg_i),
        .wb_wdata(wb_wdata_i)
    );

endmodule