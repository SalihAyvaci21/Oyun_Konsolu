module VGAMod
(
    input PixelClk, nRST,
    input [1:0] game_mode, // 2 Bit

    // Pong
    input [9:0] ball_x_in, ball_y_in, paddle_left_y_in, paddle_right_y_in,
    input [6:0] score_left_in, score_right_in,

    // Snake
    input snake_body_in, snake_apple_in, input [6:0] snake_score_in, input snake_game_over_in,

    // Flappy
    input flappy_bird_in, flappy_pipe_in, flappy_ground_in, input [6:0] flappy_score_in, input flappy_game_over_in,

    // Pacman
    input pac_wall_in, pac_dot_in, pac_player_in,
    input [29:0] ghost_positions_in, 
    input [6:0] pac_score_in, input pac_game_over_in,

    output [9:0] out_draw_x, out_draw_y,
    output LCD_DE, LCD_HSYNC, LCD_VSYNC,
    output [4:0] LCD_B, output [5:0] LCD_G, output [4:0] LCD_R
);

    reg [15:0] PixelCount;
    reg [15:0] LineCount;

    // 1. PARAMETRELER
    localparam WidthPixel = 16'd480; localparam HightPixel = 16'd272;
    localparam H_FrontPorch= 16'd2; localparam H_Pluse = 16'd41; localparam H_BackPorch = 16'd2;
    localparam V_FrontPorch= 16'd2; localparam V_Pluse = 16'd10; localparam V_BackPorch = 16'd2;
    localparam PixelForHS = WidthPixel + H_BackPorch + H_FrontPorch;
    localparam LineForVS = HightPixel + V_BackPorch + V_FrontPorch;

    // 2. KOORDİNAT HESABI
    wire [9:0] draw_x = (PixelCount >= H_BackPorch) ? (PixelCount - H_BackPorch) : 10'd0;
    wire [9:0] draw_y = (LineCount >= V_BackPorch) ? (LineCount - V_BackPorch) : 10'd0;

    assign out_draw_x = draw_x;
    assign out_draw_y = draw_y;

    assign LCD_HSYNC = ((PixelCount >= H_Pluse)&&(PixelCount <= (PixelForHS-H_FrontPorch))) ? 0 : 1;
    assign LCD_VSYNC = (((LineCount >= V_Pluse)&&(LineCount <= (LineForVS-0)))) ? 0 : 1;
    assign LCD_DE = ((PixelCount >= H_BackPorch)&&(PixelCount <= PixelForHS-H_FrontPorch)&&
                     (LineCount >= V_BackPorch)&&(LineCount <= LineForVS-V_FrontPorch-1)) ? 1 : 0;

    always @(posedge PixelClk or negedge nRST) begin
        if(!nRST) begin LineCount <= 0; PixelCount <= 0; end
        else if(PixelCount == PixelForHS) begin PixelCount <= 0; LineCount <= LineCount + 1; end
        else if(LineCount == LineForVS) begin LineCount <= 0; PixelCount <= 0; end
        else PixelCount <= PixelCount + 1;
    end

    // 3. FONT FONKSİYONU
    function [2:0] get_font_row;
        input [4:0] char_code; input [2:0] row; 
        begin
            case (char_code)
                0: case(row) 0:get_font_row=3'b111; 1:get_font_row=3'b101; 2:get_font_row=3'b101; 3:get_font_row=3'b101; 4:get_font_row=3'b111; default:get_font_row=0; endcase
                1: case(row) 0:get_font_row=3'b010; 1:get_font_row=3'b110; 2:get_font_row=3'b010; 3:get_font_row=3'b010; 4:get_font_row=3'b111; default:get_font_row=0; endcase
                2: case(row) 0:get_font_row=3'b111; 1:get_font_row=3'b001; 2:get_font_row=3'b111; 3:get_font_row=3'b100; 4:get_font_row=3'b111; default:get_font_row=0; endcase
                3: case(row) 0:get_font_row=3'b111; 1:get_font_row=3'b001; 2:get_font_row=3'b111; 3:get_font_row=3'b001; 4:get_font_row=3'b111; default:get_font_row=0; endcase
                4: case(row) 0:get_font_row=3'b101; 1:get_font_row=3'b101; 2:get_font_row=3'b111; 3:get_font_row=3'b001; 4:get_font_row=3'b001; default:get_font_row=0; endcase
                5: case(row) 0:get_font_row=3'b111; 1:get_font_row=3'b100; 2:get_font_row=3'b111; 3:get_font_row=3'b001; 4:get_font_row=3'b111; default:get_font_row=0; endcase
                6: case(row) 0:get_font_row=3'b111; 1:get_font_row=3'b100; 2:get_font_row=3'b111; 3:get_font_row=3'b101; 4:get_font_row=3'b111; default:get_font_row=0; endcase
                7: case(row) 0:get_font_row=3'b111; 1:get_font_row=3'b001; 2:get_font_row=3'b001; 3:get_font_row=3'b001; 4:get_font_row=3'b001; default:get_font_row=0; endcase
                8: case(row) 0:get_font_row=3'b111; 1:get_font_row=3'b101; 2:get_font_row=3'b111; 3:get_font_row=3'b101; 4:get_font_row=3'b111; default:get_font_row=0; endcase
                9: case(row) 0:get_font_row=3'b111; 1:get_font_row=3'b101; 2:get_font_row=3'b111; 3:get_font_row=3'b001; 4:get_font_row=3'b111; default:get_font_row=0; endcase
                10: case(row) 0:get_font_row=3'b111; 1:get_font_row=3'b100; 2:get_font_row=3'b101; 3:get_font_row=3'b101; 4:get_font_row=3'b111; default:get_font_row=0; endcase // G
                11: case(row) 0:get_font_row=3'b010; 1:get_font_row=3'b101; 2:get_font_row=3'b111; 3:get_font_row=3'b101; 4:get_font_row=3'b101; default:get_font_row=0; endcase // A
                12: case(row) 0:get_font_row=3'b101; 1:get_font_row=3'b111; 2:get_font_row=3'b101; 3:get_font_row=3'b101; 4:get_font_row=3'b101; default:get_font_row=0; endcase // M
                13: case(row) 0:get_font_row=3'b111; 1:get_font_row=3'b100; 2:get_font_row=3'b111; 3:get_font_row=3'b100; 4:get_font_row=3'b111; default:get_font_row=0; endcase // E
                14: case(row) 0:get_font_row=3'b111; 1:get_font_row=3'b101; 2:get_font_row=3'b101; 3:get_font_row=3'b101; 4:get_font_row=3'b111; default:get_font_row=0; endcase // O
                15: case(row) 0:get_font_row=3'b101; 1:get_font_row=3'b101; 2:get_font_row=3'b101; 3:get_font_row=3'b010; 4:get_font_row=3'b010; default:get_font_row=0; endcase // V
                16: case(row) 0:get_font_row=3'b110; 1:get_font_row=3'b101; 2:get_font_row=3'b110; 3:get_font_row=3'b101; 4:get_font_row=3'b101; default:get_font_row=0; endcase // R
                17: case(row) 0:get_font_row=3'b011; 1:get_font_row=3'b100; 2:get_font_row=3'b010; 3:get_font_row=3'b001; 4:get_font_row=3'b110; default:get_font_row=0; endcase // S
                default: get_font_row = 3'b000;
            endcase
        end
    endfunction

    function is_char_at;
        input [9:0] d_x; input [9:0] d_y; input [9:0] pos_x; input [9:0] pos_y; input [4:0] char_code; input [3:0] scale;
        begin
            if (d_x >= pos_x && d_x < pos_x + (3*scale) && d_y >= pos_y && d_y < pos_y + (5*scale)) begin
                 reg [2:0] bits; bits = get_font_row(char_code, (d_y - pos_y)/scale);
                 is_char_at = bits[2 - (d_x - pos_x)/scale];
            end else is_char_at = 0;
        end
    endfunction

    // 4. DEĞİŞKENLER
    localparam SCORE_Y = 15; localparam SCALE = 4; localparam DIGIT_W = 3 * SCALE; localparam SPACE = 2 * SCALE;
    localparam GO_Y = 100; localparam GO_X = 140; 

    // Skor Bit Hesaplamaları
    wire [2:0] f_tens = get_font_row(flappy_score_in/10, (draw_y-SCORE_Y)/SCALE);
    wire [2:0] f_units = get_font_row(flappy_score_in%10, (draw_y-SCORE_Y)/SCALE);
    wire [2:0] s_tens = get_font_row(snake_score_in/10, (draw_y-SCORE_Y)/SCALE);
    wire [2:0] s_units = get_font_row(snake_score_in%10, (draw_y-SCORE_Y)/SCALE);
    wire [2:0] p_l_tens = get_font_row(score_left_in/10, (draw_y-SCORE_Y)/SCALE);
    wire [2:0] p_l_units = get_font_row(score_left_in%10, (draw_y-SCORE_Y)/SCALE);
    wire [2:0] p_r_tens = get_font_row(score_right_in/10, (draw_y-SCORE_Y)/SCALE);
    wire [2:0] p_r_units = get_font_row(score_right_in%10, (draw_y-SCORE_Y)/SCALE);
    wire [2:0] pac_tens = get_font_row(pac_score_in/10, (draw_y-SCORE_Y)/SCALE);
    wire [2:0] pac_units = get_font_row(pac_score_in%10, (draw_y-SCORE_Y)/SCALE);

    // Çizim Flagleri
    reg is_go_text; 
    reg is_flappy_score, is_snake_score, is_pong_score, is_pac_score;
    reg is_pong_ball, is_pong_pad_l, is_pong_pad_r, is_pong_net;
    reg [1:0] ghost_id_to_draw;

    localparam BALL_SIZE = 10; localparam PADDLE_H = 60; localparam PADDLE_W = 10;
    localparam PADDLE_L_X = 20; localparam PADDLE_R_X = WidthPixel - 20 - PADDLE_W;
    localparam TILE_SIZE = 20;
    
    // Pacman Yardımcı Hesapları
    wire [4:0] cell_x = draw_x / TILE_SIZE; wire [4:0] cell_y = draw_y / TILE_SIZE;
    wire [4:0] off_x = draw_x % TILE_SIZE; wire [4:0] off_y = draw_y % TILE_SIZE;
    wire [4:0] g0_x = ghost_positions_in[29:25]; wire [4:0] g0_y = ghost_positions_in[24:20];
    wire [4:0] g1_x = ghost_positions_in[19:15]; wire [4:0] g1_y = ghost_positions_in[14:10];
    wire [4:0] g2_x = ghost_positions_in[9:5];   wire [4:0] g2_y = ghost_positions_in[4:0];

    // 5. ÇİZİM MANTIĞI
    always @(*) begin
        is_go_text = 0; is_flappy_score = 0; is_snake_score = 0; is_pong_score = 0; is_pac_score = 0; 
        is_pong_ball=0; is_pong_pad_l=0; is_pong_pad_r=0; is_pong_net=0;
        ghost_id_to_draw = 0;

        if (game_mode == 0) begin // PONG
            is_pong_ball = (draw_x >= ball_x_in && draw_x < ball_x_in + BALL_SIZE && draw_y >= ball_y_in && draw_y < ball_y_in + BALL_SIZE);
            is_pong_pad_l = (draw_x >= PADDLE_L_X && draw_x < PADDLE_L_X + PADDLE_W && draw_y >= paddle_left_y_in && draw_y < paddle_left_y_in + PADDLE_H);
            is_pong_pad_r = (draw_x >= PADDLE_R_X && draw_x < PADDLE_R_X + PADDLE_W && draw_y >= paddle_right_y_in && draw_y < paddle_right_y_in + PADDLE_H);
            is_pong_net = (draw_x >= (WidthPixel/2)-1 && draw_x <= (WidthPixel/2)+1 && draw_y[3] == 1'b1);
            if (draw_y >= SCORE_Y && draw_y < SCORE_Y + (5*SCALE)) begin
                if (draw_x >= (WidthPixel/2)-80 && draw_x < (WidthPixel/2)-80 + DIGIT_W) is_pong_score = (score_left_in >= 10) ? p_l_tens[2-(draw_x-((WidthPixel/2)-80))/SCALE] : 0;
                else if (draw_x >= (WidthPixel/2)-80 + DIGIT_W + SPACE && draw_x < (WidthPixel/2)-80 + 2*DIGIT_W + SPACE) is_pong_score = p_l_units[2-(draw_x-((WidthPixel/2)-80 + DIGIT_W + SPACE))/SCALE];
                if (draw_x >= (WidthPixel/2)+40 && draw_x < (WidthPixel/2)+40 + DIGIT_W) is_pong_score = (score_right_in >= 10) ? p_r_tens[2-(draw_x-((WidthPixel/2)+40))/SCALE] : 0;
                else if (draw_x >= (WidthPixel/2)+40 + DIGIT_W + SPACE && draw_x < (WidthPixel/2)+40 + 2*DIGIT_W + SPACE) is_pong_score = p_r_units[2-(draw_x-((WidthPixel/2)+40 + DIGIT_W + SPACE))/SCALE];
            end
        end 
        else if (game_mode == 1) begin // SNAKE
            if (draw_y >= SCORE_Y && draw_y < SCORE_Y + (5*SCALE)) begin
                if (draw_x >= 20 && draw_x < 20 + DIGIT_W) is_snake_score = (snake_score_in >= 10) ? s_tens[2-(draw_x-20)/SCALE] : 0;
                else if (draw_x >= 35 && draw_x < 35 + DIGIT_W) is_snake_score = s_units[2-(draw_x-35)/SCALE];
            end
            if (snake_game_over_in) begin
                if (is_char_at(draw_x, draw_y, GO_X, GO_Y, 10, 4) || is_char_at(draw_x, draw_y, GO_X+15, GO_Y, 11, 4) ||
                    is_char_at(draw_x, draw_y, GO_X+30, GO_Y, 12, 4) || is_char_at(draw_x, draw_y, GO_X+45, GO_Y, 13, 4) ||
                    is_char_at(draw_x, draw_y, GO_X+75, GO_Y, 14, 4) || is_char_at(draw_x, draw_y, GO_X+90, GO_Y, 15, 4) ||
                    is_char_at(draw_x, draw_y, GO_X+105, GO_Y, 13, 4) || is_char_at(draw_x, draw_y, GO_X+120, GO_Y, 16, 4)) is_go_text = 1;
            end
        end
        else if (game_mode == 2) begin // FLAPPY
             if (draw_y >= SCORE_Y && draw_y < SCORE_Y + (5*SCALE)) begin
                 if (draw_x >= (WidthPixel/2)-15 && draw_x < (WidthPixel/2)-15 + DIGIT_W) is_flappy_score = (flappy_score_in >= 10) ? f_tens[2-(draw_x-((WidthPixel/2)-15))/SCALE] : 0;
                 else if (draw_x >= (WidthPixel/2) + SPACE && draw_x < (WidthPixel/2) + SPACE + DIGIT_W) is_flappy_score = f_units[2-(draw_x-((WidthPixel/2) + SPACE))/SCALE];
             end
             if (flappy_game_over_in) begin
                if (is_char_at(draw_x, draw_y, GO_X, GO_Y, 10, 4) || is_char_at(draw_x, draw_y, GO_X+15, GO_Y, 11, 4) ||
                    is_char_at(draw_x, draw_y, GO_X+30, GO_Y, 12, 4) || is_char_at(draw_x, draw_y, GO_X+45, GO_Y, 13, 4) ||
                    is_char_at(draw_x, draw_y, GO_X+75, GO_Y, 14, 4) || is_char_at(draw_x, draw_y, GO_X+90, GO_Y, 15, 4) ||
                    is_char_at(draw_x, draw_y, GO_X+105, GO_Y, 13, 4) || is_char_at(draw_x, draw_y, GO_X+120, GO_Y, 16, 4)) is_go_text = 1;
             end
        end
        else if (game_mode == 3) begin // PACMAN
             if (draw_y >= SCORE_Y && draw_y < SCORE_Y + (5*SCALE)) begin
                 if (draw_x >= 20 && draw_x < 20 + DIGIT_W) is_pac_score = (pac_score_in >= 10) ? pac_tens[2-(draw_x-20)/SCALE] : 0;
                 else if (draw_x >= 35 && draw_x < 35 + DIGIT_W) is_pac_score = pac_units[2-(draw_x-35)/SCALE];
             end
             if (pac_game_over_in) begin
                if (is_char_at(draw_x, draw_y, GO_X, GO_Y, 10, 4) || is_char_at(draw_x, draw_y, GO_X+15, GO_Y, 11, 4) ||
                    is_char_at(draw_x, draw_y, GO_X+30, GO_Y, 12, 4) || is_char_at(draw_x, draw_y, GO_X+45, GO_Y, 13, 4) ||
                    is_char_at(draw_x, draw_y, GO_X+75, GO_Y, 14, 4) || is_char_at(draw_x, draw_y, GO_X+90, GO_Y, 15, 4) ||
                    is_char_at(draw_x, draw_y, GO_X+105, GO_Y, 13, 4) || is_char_at(draw_x, draw_y, GO_X+120, GO_Y, 16, 4)) is_go_text = 1;
             end
             
             // HAYALET ÇİZİMİ
             if (!(off_x < 4 && off_y < 4) && !(off_x > 16 && off_y < 4)) begin
                if (cell_x == g0_x && cell_y == g0_y) ghost_id_to_draw = 1; 
                else if (cell_x == g1_x && cell_y == g1_y) ghost_id_to_draw = 2; 
                else if (cell_x == g2_x && cell_y == g2_y) ghost_id_to_draw = 3; 
             end
        end
    end

    reg [4:0] r_out; reg [5:0] g_out; reg [4:0] b_out;
    
    // 6. RENK ATAMA
    always @(*) begin
        if (!LCD_DE) begin r_out=0; g_out=0; b_out=0; end else begin
            case (game_mode)
                0: begin // PONG
                    if (is_pong_pad_r) {r_out, g_out, b_out} = {5'd31, 6'd0, 5'd0}; 
                    else if (is_pong_score) {r_out, g_out, b_out} = {5'd31, 6'd63, 5'd31};
                    else if (is_pong_ball) {r_out, g_out, b_out} = {5'd31, 6'd63, 5'd0}; 
                    else if (is_pong_pad_l) {r_out, g_out, b_out} = {5'd0, 6'd63, 5'd31};
                    else if (is_pong_net) {r_out, g_out, b_out} = {5'd16, 6'd32, 5'd16};
                    else {r_out, g_out, b_out} = {draw_y[8:5], 6'b000010, draw_y[8:4] + 5'd5}; 
                end
                1: begin // SNAKE
                    if (is_go_text) {r_out, g_out, b_out} = {5'd31, 6'd63, 5'd31}; 
                    else if (snake_apple_in) {r_out, g_out, b_out} = {5'd31, 6'd0, 5'd0}; 
                    else if (snake_body_in) {r_out, g_out, b_out} = {5'd0, 6'd63, 5'd0}; 
                    else if (is_snake_score) {r_out, g_out, b_out} = {5'd31, 6'd63, 5'd31};
                    else {r_out, g_out, b_out} = snake_game_over_in ? {5'd10, 6'd0, 5'd0} : {5'd0, 6'd0, 5'd0}; 
                end
                2: begin // FLAPPY
                    if (is_go_text || is_flappy_score) {r_out, g_out, b_out} = {5'd31, 6'd63, 5'd31}; 
                    else if (flappy_bird_in) {r_out, g_out, b_out} = {5'd31, 6'd63, 5'd0}; 
                    else if (flappy_pipe_in) {r_out, g_out, b_out} = {5'd0, 6'd63, 5'd0}; 
                    else if (flappy_ground_in) {r_out, g_out, b_out} = {5'd20, 6'd40, 5'd10}; 
                    else {r_out, g_out, b_out} = {5'd10, 6'd50, 5'd31}; 
                end
                3: begin // PACMAN
                    if (is_go_text || is_pac_score) {r_out, g_out, b_out} = {5'd31, 6'd63, 5'd31}; 
                    else if (pac_player_in) {r_out, g_out, b_out} = {5'd31, 6'd63, 5'd0}; 
                    else if (ghost_id_to_draw == 1) {r_out, g_out, b_out} = {5'd31, 6'd0, 5'd0};  
                    else if (ghost_id_to_draw == 2) {r_out, g_out, b_out} = {5'd31, 6'd32, 5'd20}; 
                    else if (ghost_id_to_draw == 3) {r_out, g_out, b_out} = {5'd0, 6'd63, 5'd31};  
                    else if (pac_wall_in) {r_out, g_out, b_out} = {5'd0, 6'd0, 5'd31}; 
                    else if (pac_dot_in) {r_out, g_out, b_out} = {5'd31, 6'd63, 5'd20}; 
                    else {r_out, g_out, b_out} = {5'd0, 6'd0, 5'd0}; 
                end
                default: {r_out, g_out, b_out} = 0;
            endcase
        end
    end
    assign LCD_R = r_out; assign LCD_G = g_out; assign LCD_B = b_out;
endmodule