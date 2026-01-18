module flappy_logic (
    input clk_pix, input rst_n, input game_active, input btn_jump,
    input [9:0] draw_x, input [9:0] draw_y,
    output reg is_bird, output reg is_pipe, output reg is_ground, output reg [6:0] score, output reg is_game_over
);
    localparam SCREEN_H = 272; localparam GROUND_H = 20; localparam BIRD_X = 50; localparam BIRD_SIZE= 12;
    localparam PIPE_W = 30; localparam PIPE_GAP = 70;
    localparam STATE_IDLE = 0; localparam STATE_PLAY = 1; localparam STATE_GAMEOVER = 2;
    reg [1:0] state;
    reg [9:0] bird_y; reg signed [9:0] velocity; 
    reg [9:0] pipe_x; reg [9:0] pipe_gap_y; 
    reg [19:0] frame_counter; 
    reg [15:0] lfsr; reg prev_btn_jump; reg jump_queued; 
    wire jump_pressed = (btn_jump && !prev_btn_jump);

    always @(*) begin
        is_bird = (draw_x >= BIRD_X && draw_x < BIRD_X + BIRD_SIZE && draw_y >= bird_y && draw_y < bird_y + BIRD_SIZE);
        is_ground = (draw_y >= SCREEN_H - GROUND_H);
        if (draw_x >= pipe_x && draw_x < pipe_x + PIPE_W) begin
            if (draw_y < pipe_gap_y || draw_y > pipe_gap_y + PIPE_GAP) is_pipe = 1; else is_pipe = 0; 
        end else is_pipe = 0;
        if (is_ground) is_pipe = 0;
    end
    always @(*) is_game_over = (state == STATE_GAMEOVER);

    always @(posedge clk_pix or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_IDLE; bird_y <= 100; velocity <= 0; pipe_x <= 300; pipe_gap_y <= 50; score <= 0;
            lfsr <= 16'h1234; prev_btn_jump <= 0; jump_queued <= 0;
        end else begin
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
            if (game_active) begin
                prev_btn_jump <= btn_jump;
                if (jump_pressed) jump_queued <= 1;

                if (state == STATE_IDLE) begin
                    bird_y <= 120; velocity <= 0; score <= 0; pipe_x <= 400;
                    if (jump_queued) begin state <= STATE_PLAY; velocity <= -6; jump_queued <= 0; end
                end
                else if (state == STATE_PLAY) begin
                    if (frame_counter == 0) begin
                        frame_counter <= 160000; // YAVAŞ
                        if (jump_queued) begin velocity <= -6; jump_queued <= 0; end 
                        else begin if (velocity < 5) velocity <= velocity + 1; end
                        if ($signed(bird_y) + velocity < 0) bird_y <= 0; else bird_y <= bird_y + velocity;
                        if (pipe_x == 0) begin pipe_x <= 480; pipe_gap_y <= 20 + (lfsr % 140); score <= score + 1; end 
                        else pipe_x <= pipe_x - 2; 
                        if (bird_y + BIRD_SIZE >= SCREEN_H - GROUND_H) state <= STATE_GAMEOVER;
                        if ((BIRD_X + BIRD_SIZE > pipe_x) && (BIRD_X < pipe_x + PIPE_W)) begin
                            if (bird_y < pipe_gap_y || bird_y + BIRD_SIZE > pipe_gap_y + PIPE_GAP) state <= STATE_GAMEOVER;
                        end
                    end else frame_counter <= frame_counter - 1;
                end
                else if (state == STATE_GAMEOVER) begin
                    if (jump_queued) begin state <= STATE_IDLE; jump_queued <= 0; end
                end
            end 
        end 
    end
endmodule