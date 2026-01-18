module Debounce ( input clk, input btn_in, output reg btn_out );
    localparam DELAY = 270_000; reg [18:0] counter; reg state;
    always @(posedge clk) begin
        if (state != ~btn_in) begin counter <= counter + 1; if (counter >= DELAY) begin state <= ~btn_in; counter <= 0; end end 
        else counter <= 0;
        btn_out <= state;
    end
endmodule