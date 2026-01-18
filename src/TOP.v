module TOP
(
    input           Reset_Button, // S1
    input           User_Button,  // S2
    input           XTAL_IN,      

    output          LCD_CLK,
    output          LCD_HYNC,
    output          LCD_SYNC,
    output          LCD_DEN,
    output  [4:0]   LCD_R,
    output  [5:0]   LCD_G,
    output  [4:0]   LCD_B,
    output  [5:0]   LED
);

    // --- 1. SİSTEM KABLOLARI ---
    wire CLK_SYS;
    wire CLK_PIX;   // 9 MHz
    wire pll_lock;
    wire sys_rst_n;
    wire [9:0] vga_x, vga_y; // VGA Koordinatları

    // --- 2. OYUN SİNYAL KABLOLARI ---
    
    // Pong
    wire [9:0] pong_ball_x, pong_ball_y;
    wire [9:0] pong_pad_l, pong_pad_r;
    wire [6:0] pong_score_l, pong_score_r;

    // Snake
    wire snake_body_on, snake_apple_on, snake_is_over;
    wire [6:0] snake_score;

    // Flappy
    wire bird_on, pipe_on, ground_on, flappy_is_over;
    wire [6:0] flappy_score;
    
    // Pacman
    wire pac_wall_on, pac_dot_on, pac_player_on, pac_is_over;
    wire [29:0] ghost_positions_w;
    wire [6:0] pac_score;

    // Buton Sinyalleri
    wire btn_s1_clean; 
    wire btn_s2_clean;
    wire jump_btn; 

    // --- 3. PLL ---
    Gowin_rPLL chip_pll (.clkout(CLK_SYS), .lock(pll_lock), .clkoutd(CLK_PIX), .clkin(XTAL_IN));
    assign LCD_CLK = CLK_PIX;
    assign sys_rst_n = pll_lock; 

    // --- 4. BUTONLAR ---
    Debounce db_s1 (.clk(CLK_PIX), .btn_in(Reset_Button), .btn_out(btn_s1_clean));
    Debounce db_s2 (.clk(CLK_PIX), .btn_in(User_Button),  .btn_out(btn_s2_clean));
    assign jump_btn = (btn_s1_clean || btn_s2_clean);

    // --- 5. OYUN SEÇİCİ (0, 1, 2, 3 Döngüsü) ---
    reg [24:0] switch_counter;
    reg [1:0] game_mode; // 2 Bit yeterli (0-3)

    always @(posedge CLK_PIX or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            switch_counter <= 0;
            game_mode <= 0;
        end else begin
            if (btn_s1_clean && btn_s2_clean) begin
                if (switch_counter < 18_000_000) 
                    switch_counter <= switch_counter + 1;
                else begin
                    game_mode <= game_mode + 1; // 2 bit olduğu için 3'ten sonra 0'a döner (Overflow)
                    switch_counter <= 0; 
                end
            end else begin
                switch_counter <= 0; 
            end
        end
    end

    // --- 6. OYUN MODÜLLERİ ---

    pong_logic game_pong (
        .clk_pix(CLK_PIX), .rst_n(sys_rst_n), .game_active(game_mode == 0),
        .btn_up(!btn_s2_clean), .btn_down(!btn_s1_clean),
        .ball_x(pong_ball_x), .ball_y(pong_ball_y),
        .paddle_left_y(pong_pad_l), .paddle_right_y(pong_pad_r),
        .score_left(pong_score_l), .score_right(pong_score_r)  
    );

    snake_logic game_snake (
        .clk_pix(CLK_PIX), .rst_n(sys_rst_n), .game_active(game_mode == 1), 
        .btn_left(btn_s1_clean), .btn_right(btn_s2_clean),
        .draw_x(vga_x), .draw_y(vga_y), 
        .is_body(snake_body_on), .is_apple(snake_apple_on),
        .score(snake_score), .is_game_over(snake_is_over)
    );

    flappy_logic game_flappy (
        .clk_pix(CLK_PIX), .rst_n(sys_rst_n), .game_active(game_mode == 2),
        .btn_jump(jump_btn),
        .draw_x(vga_x), .draw_y(vga_y),
        .is_bird(bird_on), .is_pipe(pipe_on), .is_ground(ground_on),
        .score(flappy_score), .is_game_over(flappy_is_over)
    );

    pacman_logic game_pacman (
        .clk_pix(CLK_PIX), .rst_n(sys_rst_n), .game_active(game_mode == 3),
        .btn_left(btn_s1_clean), .btn_right(btn_s2_clean),
        .draw_x(vga_x), .draw_y(vga_y),
        .is_wall(pac_wall_on), .is_dot(pac_dot_on), 
        .is_player(pac_player_on), .ghost_positions_out(ghost_positions_w),
        .score(pac_score), .is_game_over(pac_is_over)
    );

    // --- 7. VGA RENDERER ---
    VGAMod vga_renderer
    (
        .PixelClk(CLK_PIX), .nRST(sys_rst_n), .game_mode(game_mode),

        // Pong
        .ball_x_in(pong_ball_x), .ball_y_in(pong_ball_y),
        .paddle_left_y_in(pong_pad_l), .paddle_right_y_in(pong_pad_r),
        .score_left_in(pong_score_l), .score_right_in(pong_score_r),
        
        // Snake
        .snake_body_in(snake_body_on), .snake_apple_in(snake_apple_on),
        .snake_score_in(snake_score), .snake_game_over_in(snake_is_over),

        // Flappy
        .flappy_bird_in(bird_on), .flappy_pipe_in(pipe_on), .flappy_ground_in(ground_on),
        .flappy_score_in(flappy_score), .flappy_game_over_in(flappy_is_over),

        // Pacman
        .pac_wall_in(pac_wall_on), .pac_dot_in(pac_dot_on),
        .pac_player_in(pac_player_on), .ghost_positions_in(ghost_positions_w),
        .pac_score_in(pac_score), .pac_game_over_in(pac_is_over),

        .out_draw_x(vga_x), .out_draw_y(vga_y),
        .LCD_DE(LCD_DEN), .LCD_HSYNC(LCD_HYNC), .LCD_VSYNC(LCD_SYNC),
        .LCD_B(LCD_B), .LCD_G(LCD_G), .LCD_R(LCD_R)
    );

    assign LED = {4'b0, game_mode}; 

endmodule