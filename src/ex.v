`include "src/define.v"

module ex (
    input wire                  rst,
    //譯碼階段送到執行階段的訊息
    input wire [`AluOpBus]      aluop_i,
    input wire [`AluSelBus]     alusel_i,
    input wire [`RegBus]        reg1_i,
    input wire [`RegBus]        reg2_i,
    input wire [`RegAddrBus]    wd_i,
    input wire                  wreg_i,

    //執行的結果
    output reg [ `RegAddrBus]   wd_o,
    output reg                  wreg_o,
    output reg[`RegBus]         wdata_o
);

// 保存邏輯運算結果
    reg[`RegBus]                logicout;

/**********************************************************************************
**          第一段:依據aluop_i指示的運算子類型進行運算,此處只有邏輯「或」運算             **
**********************************************************************************/
always @ (*) begin
    if(rst == `RstEnable) begin
        logicout <= `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_OR_OP: begin
                logicout <= reg1_i | reg2_i;
            end
            default:    begin
                logicout <= `ZeroWord;
            end
        endcase
    end
end

/**********************************************************************************
**          第二段:依據 alusel_i所指示的運算類型,選擇一個運算結果作為最終結果             **
**          此處只有邏輯運算結果                                                    **   
**********************************************************************************/
always @ (*) begin
    wd_o <= wd_i;                   // wd_o等於wd_i,要寫的目的暫存器位址
    wreg_o <= wreg_i;               // wreg_o等於wreg_i,表示是否要寫目的暫存器
    case ( alusel_i )
        `EXE_RES_LOGIC: begin
            wdata_o <= logicout;    // wdata_o中存放運算結果
        end
        default:        begin
            wdata_o <= `ZeroWord;
        end
    endcase
end

endmodule