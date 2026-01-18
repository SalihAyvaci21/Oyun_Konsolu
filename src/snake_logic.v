module snake_logic (
    input clk_pix, input rst_n, input game_active, 
    input btn_left, input btn_right,   
    input [9:0] draw_x, input [9:0] draw_y, 
    output reg is_body, output reg is_apple, output reg [6:0] score, output reg is_game_over 
);
    localparam CELL_SIZE = 10; localparam GRID_W = 48; localparam GRID_H = 27;
    localparam STATE_PLAY = 0; localparam STATE_GAMEOVER = 1;
    reg state;
    reg [5:0] head_x, head_y, apple_x, apple_y;
    reg [5:0] body_x [0:63]; reg [5:0] body_y [0:63];
    reg [5:0] length;
    reg [1:0] direction, next_direction;
    reg [23:0] speed_counter; 
    reg [15:0] lfsr;
    reg prev_btn_left, prev_btn_right;
    integer i;

    wire press_left = (btn_left && !prev_btn_left);
    wire press_right = (btn_right && !prev_btn_right);
    always @(*) is_game_over = (state == STATE_GAMEOVER);

    always @(posedge clk_pix or negedge rst_n) begin
        if (!rst_n) begin
            head_x <= 24; head_y <= 13; apple_x <= 10; apple_y <= 10;
            length <= 3; direction <= 1; next_direction <= 1;
            speed_counter <= 4000000; // YAVAŞ
            score <= 0; lfsr <= 16'hACE1; state <= STATE_PLAY;
            body_x[0] <= 23; body_y[0] <= 13; body_x[1] <= 22; body_y[1] <= 13; body_x[2] <= 21; body_y[2] <= 13;
            prev_btn_left <= 0; prev_btn_right <= 0;
        end else begin
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
            if (game_active) begin
                prev_btn_left <= btn_left; prev_btn_right <= btn_right;
                if (state == STATE_PLAY) begin
                    if (press_left) next_direction <= direction - 1;
                    else if (press_right) next_direction <= direction + 1;

                    if (speed_counter == 0) begin
                        speed_counter <= 4000000 - (score * 50000); 
                        if (speed_counter < 1000000) speed_counter <= 1000000;
                        direction <= next_direction;
                        for (i = 63; i > 0; i = i - 1) begin
                            if (i <= length) begin body_x[i] <= body_x[i-1]; body_y[i] <= body_y[i-1]; end
                        end
                        body_x[0] <= head_x; body_y[0] <= head_y;
                        case (next_direction)
                            0: if (head_y == 0) state <= STATE_GAMEOVER; else head_y <= head_y - 1;
                            1: if (head_x == GRID_W-1) state <= STATE_GAMEOVER; else head_x <= head_x + 1;
                            2: if (head_y == GRID_H-1) state <= STATE_GAMEOVER; else head_y <= head_y + 1;
                            3: if (head_x == 0) state <= STATE_GAMEOVER; else head_x <= head_x - 1;
                        endcase
                        for (i = 0; i < 63; i = i + 1) if (i < length && head_x == body_x[i] && head_y == body_y[i]) state <= STATE_GAMEOVER;
                        if (head_x == apple_x && head_y == apple_y) begin
                            score <= score + 1; if (length < 63) length <= length + 1;
                            apple_x <= (lfsr[5:0] >= GRID_W) ? (lfsr[5:0] - GRID_W) : lfsr[5:0];
                            apple_y <= (lfsr[10:6] >= GRID_H) ? (lfsr[10:6] - GRID_H) : lfsr[10:6];
                        end
                    end else speed_counter <= speed_counter - 1;
                end else begin
                    if (press_left || press_right) begin
                        head_x <= 24; head_y <= 13; length <= 3; score <= 0; direction <= 1; next_direction <= 1; state <= STATE_PLAY; speed_counter <= 4000000;
                        body_x[0] <= 23; body_y[0] <= 13; body_x[1] <= 22; body_y[1] <= 13; body_x[2] <= 21; body_y[2] <= 13;
                    end
                end
            end
        end
    end
    wire [5:0] cell_x = draw_x / CELL_SIZE; wire [5:0] cell_y = draw_y / CELL_SIZE;
    reg body_found; integer k;
    always @(*) begin
        is_apple = (cell_x == apple_x && cell_y == apple_y); body_found = 0;
        if (cell_x == head_x && cell_y == head_y) body_found = 1;
        else for (k = 0; k < 63; k = k + 1) if (k < length && cell_x == body_x[k] && cell_y == body_y[k]) body_found = 1;
        is_body = body_found;
    end
endmodule