module pong_logic (
    input clk_pix, input rst_n, input game_active, input btn_up, input btn_down, 
    output reg [9:0] ball_x, output reg [9:0] ball_y, output reg [9:0] paddle_left_y, output reg [9:0] paddle_right_y,
    output reg [6:0] score_left, output reg [6:0] score_right  
);
    localparam SCREEN_W = 480; localparam SCREEN_H = 272; localparam BALL_SIZE = 10;
    localparam PADDLE_H = 60; localparam PADDLE_W = 10; localparam PADDLE_L_X = 20; localparam PADDLE_R_X = SCREEN_W - 20 - PADDLE_W; 
    reg [9:0] ball_dx; reg [9:0] ball_dy; localparam PADDLE_SPEED = 4; localparam AI_SPEED = 3;     
    reg [19:0] tick_counter; wire game_tick = (tick_counter == 0);

    always @(posedge clk_pix or negedge rst_n) begin
        if (!rst_n) tick_counter <= 150000; 
        else if (game_active) begin if (tick_counter == 0) tick_counter <= 150000; else tick_counter <= tick_counter - 1; end
    end

    always @(posedge clk_pix or negedge rst_n) begin
        if (!rst_n) begin
            ball_x <= SCREEN_W / 2; ball_y <= SCREEN_H / 2; paddle_left_y <= (SCREEN_H - PADDLE_H) / 2; paddle_right_y <= (SCREEN_H - PADDLE_H) / 2;
            ball_dx <= 3; ball_dy <= 3; score_left <= 0; score_right <= 0;
        end else if (game_active && game_tick) begin
            if (!btn_up && paddle_left_y > PADDLE_SPEED) paddle_left_y <= paddle_left_y - PADDLE_SPEED;
            else if (!btn_down && paddle_left_y < (SCREEN_H - PADDLE_H - PADDLE_SPEED)) paddle_left_y <= paddle_left_y + PADDLE_SPEED;
            if ( (paddle_right_y + (PADDLE_H/2) < ball_y) && (paddle_right_y < (SCREEN_H - PADDLE_H - AI_SPEED)) ) paddle_right_y <= paddle_right_y + AI_SPEED; 
            else if ( (paddle_right_y + (PADDLE_H/2) > ball_y) && (paddle_right_y > AI_SPEED) ) paddle_right_y <= paddle_right_y - AI_SPEED;
            ball_x <= ball_x + ball_dx; ball_y <= ball_y + ball_dy;
            if (ball_y <= 3 || ball_y > 800) begin ball_dy <= 3; if (ball_y > 800) ball_y <= 0; end
            else if (ball_y >= (SCREEN_H - BALL_SIZE - 3) && ball_y < 800) ball_dy <= -3;
            if ( (ball_x <= PADDLE_L_X + PADDLE_W) && (ball_x + BALL_SIZE >= PADDLE_L_X) && (ball_y + BALL_SIZE >= paddle_left_y) && (ball_y <= paddle_left_y + PADDLE_H) ) begin ball_dx <= 3; if (ball_y + (BALL_SIZE/2) < paddle_left_y + (PADDLE_H/2)) ball_dy <= -3; else ball_dy <= 3; end
            if ( (ball_x + BALL_SIZE >= PADDLE_R_X) && (ball_x <= PADDLE_R_X + PADDLE_W) && (ball_y + BALL_SIZE >= paddle_right_y) && (ball_y <= paddle_right_y + PADDLE_H) ) begin ball_dx <= -3; if (ball_y + (BALL_SIZE/2) < paddle_right_y + (PADDLE_H/2)) ball_dy <= -3; else ball_dy <= 3; end
            if (ball_x < 5) begin if (score_right < 99) score_right <= score_right + 1; ball_x <= SCREEN_W / 2; ball_y <= SCREEN_H / 2; ball_dx <= 3; ball_dy <= 3; end
            else if (ball_x > SCREEN_W - 15) begin if (score_left < 99) score_left <= score_left + 1; ball_x <= SCREEN_W / 2; ball_y <= SCREEN_H / 2; ball_dx <= -3; ball_dy <= 3; end
        end
    end
endmodule