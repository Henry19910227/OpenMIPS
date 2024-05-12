//**************** 全局 ****************//
`define RstEnable           1'b1                //復位信號有效
`define RstDisable          1'b0                //復位信號無效
`define ZeroWord            32'h00000000        //32位的數值0
`define WriteEnable         1'b1                //使能寫
`define WriteDisable        1'b0                //禁止寫
`define ReadEnable          1'b1                //使能讀
`define ReadDisable         1'b0                //禁止讀
`define AluOpBus            7:0                 //譯碼階段輸出 aluop_o 的寬度
`define AluSelBus           2:0                 //譯碼階段輸出 alusel_o 的寬度
`define InstValid           1'b1                //指令有效
`define InstInvalid         1'b0                //指令無效
`define True_v              1'b1                //邏輯'真'
`define False_v             1'b0                //邏輯'假'
`define ChipEnable          1'b1                //芯片使能
`define ChipDisable         1'b0                //芯片禁止


//**************** 指令 ****************//
`define EXE_ORI             6'b001101           //ori指令碼
`define EXE_NOP             6'b000000           //ori指令碼

//AluOp
`define EXE_OR_OP           8'b00100101      
`define EXE_NOP_OP          8'b00000000

//AluSel
`define EXE_RES_LOGIC       3'b001

`define EXE_RES_NOP         3'b000



//**************** ROM ****************//
`define InstAddrBus         31:0                //ROM的地址總線寬度
`define InstBus             31:0                //ROM的數據總線寬度
`define InstMemNum          131071              //ROM的實際大小為128KB
`define InstMemNumLog2      17                  //ROM實際使用的位址線寬度


//**************** Regfile ****************//
`define RegAddrBus          4:0                 //Regfile 模組的位址線寬度
`define RegBus              31:0                //Regfile 模組的資料線寬度
`define RegWidth            32                  //通用暫存器的寬度
`define DoubleRegWidth      64                  //兩倍的通用暫存器的寬度
`define DoubleRegBus        63:0                //兩倍的通用暫存器的資料線寬度
`define RegNum              32                  //通用暫存器的數量
`define RegNumLog2          5                   //尋址通用暫存器使用的位址位數
`define NOPRegAddr          5'b00000








