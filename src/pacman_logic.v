module pacman_logic (
    input clk_pix, input rst_n, input game_active,
    input btn_left, input btn_right,
    input [9:0] draw_x, input [9:0] draw_y,
    output reg is_wall, output reg is_dot, output reg is_player,
    output wire [29:0] ghost_positions_out,
    output reg [6:0] score, output reg is_game_over
);
    localparam TILE_SIZE = 20; localparam GRID_W = 24; localparam GRID_H = 13;
    reg [4:0] pac_x, pac_y;
    reg [4:0] ghost_x [0:2]; reg [4:0] ghost_y [0:2]; reg [1:0] ghost_dir [0:2];
    assign ghost_positions_out = {ghost_x[0], ghost_y[0], ghost_x[1], ghost_y[1], ghost_x[2], ghost_y[2]};
    reg [4:0] move_offset; reg [1:0] pac_dir, pac_next_dir; reg state; 
    reg [19:0] speed_counter; reg [15:0] lfsr; 
    reg dots [0:311]; 
    reg prev_btn_left, prev_btn_right;
    wire press_left = (btn_left && !prev_btn_left); wire press_right = (btn_right && !prev_btn_right);
    integer i, g;

    function check_wall;
        input [4:0] gx; input [4:0] gy;
        begin
            if (gx == 0 || gx == GRID_W-1 || gy == 0 || gy == GRID_H-1) check_wall = 1; 
            else if ((gx % 4 == 0) && (gy % 3 == 0)) check_wall = 1; 
            else if ((gx % 4 == 0) && (gy > 4 && gy < 8)) check_wall = 1; 
            else check_wall = 0;
        end
    endfunction

    always @(*) is_game_over = state;

    always @(posedge clk_pix or negedge rst_n) begin
        if (!rst_n) begin
            pac_x <= 1; pac_y <= 1;
            ghost_x[0] <= 11; ghost_y[0] <= 6; ghost_dir[0] <= 1; 
            ghost_x[1] <= 12; ghost_y[1] <= 6; ghost_dir[1] <= 3; 
            ghost_x[2] <= 13; ghost_y[2] <= 6; ghost_dir[2] <= 1; 
            pac_dir <= 1; pac_next_dir <= 1; move_offset <= 0;
            speed_counter <= 500000; // HIZLI MOD
            score <= 0; state <= 0; lfsr <= 16'hCAFE;
            for (i=0; i<312; i=i+1) dots[i] <= 1;
        end else begin
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
            prev_btn_left <= btn_left; prev_btn_right <= btn_right;

            if (game_active) begin
                if (state == 0) begin 
                    if (press_left) pac_next_dir <= pac_dir - 1;
                    else if (press_right) pac_next_dir <= pac_dir + 1;

                    if (speed_counter == 0) begin
                        speed_counter <= 500000; 
                        
                        if (move_offset == 0) begin
                            reg [4:0] next_tx, next_ty;
                            case (pac_next_dir)
                                0: begin next_tx=pac_x; next_ty=pac_y-1; end
                                1: begin next_tx=pac_x+1; next_ty=pac_y; end
                                2: begin next_tx=pac_x; next_ty=pac_y+1; end
                                3: begin next_tx=pac_x-1; next_ty=pac_y; end
                            endcase
                            if (!check_wall(next_tx, next_ty)) pac_dir <= pac_next_dir; 
                        end 
                        
                        move_offset <= move_offset + 4;
                        if (move_offset >= TILE_SIZE-4) begin
                            move_offset <= 0;
                            case (pac_dir)
                                0: if(!check_wall(pac_x, pac_y-1)) pac_y <= pac_y - 1;
                                1: if(!check_wall(pac_x+1, pac_y)) pac_x <= pac_x + 1;
                                2: if(!check_wall(pac_x, pac_y+1)) pac_y <= pac_y + 1;
                                3: if(!check_wall(pac_x-1, pac_y)) pac_x <= pac_x - 1;
                            endcase
                            if (dots[pac_y * GRID_W + pac_x]) begin
                                dots[pac_y * GRID_W + pac_x] <= 0; score <= score + 1;
                            end
                        end

                        if (move_offset == 0) begin
                            for (g=0; g<3; g=g+1) begin
                                reg [4:0] g_next_x, g_next_y; reg [1:0] best_dir;
                                if (g == 0) begin 
                                    if (pac_x > ghost_x[g] && !check_wall(ghost_x[g]+1, ghost_y[g])) best_dir = 1; 
                                    else if (pac_x < ghost_x[g] && !check_wall(ghost_x[g]-1, ghost_y[g])) best_dir = 3; 
                                    else if (pac_y > ghost_y[g] && !check_wall(ghost_x[g], ghost_y[g]+1)) best_dir = 2; 
                                    else if (pac_y < ghost_y[g] && !check_wall(ghost_x[g], ghost_y[g]-1)) best_dir = 0; 
                                    else best_dir = lfsr[1:0]; 
                                    if (best_dir == (ghost_dir[g] + 2)) best_dir = ghost_dir[g];
                                    ghost_dir[g] <= best_dir;
                                end else begin 
                                    case (ghost_dir[g])
                                        0: begin g_next_x=ghost_x[g]; g_next_y=ghost_y[g]-1; end
                                        1: begin g_next_x=ghost_x[g]+1; g_next_y=ghost_y[g]; end
                                        2: begin g_next_x=ghost_x[g]; g_next_y=ghost_y[g]+1; end
                                        3: begin g_next_x=ghost_x[g]-1; g_next_y=ghost_y[g]; end
                                    endcase
                                    if (check_wall(g_next_x, g_next_y) || (lfsr[3:0] == g)) ghost_dir[g] <= lfsr[1:0];
                                end
                                case (ghost_dir[g])
                                    0: if(!check_wall(ghost_x[g], ghost_y[g]-1)) ghost_y[g] <= ghost_y[g] - 1;
                                    1: if(!check_wall(ghost_x[g]+1, ghost_y[g])) ghost_x[g] <= ghost_x[g] + 1;
                                    2: if(!check_wall(ghost_x[g], ghost_y[g]+1)) ghost_y[g] <= ghost_y[g] + 1;
                                    3: if(!check_wall(ghost_x[g]-1, ghost_y[g])) ghost_x[g] <= ghost_x[g] - 1;
                                endcase
                            end
                        end
                        for (g=0; g<3; g=g+1) begin if (pac_x == ghost_x[g] && pac_y == ghost_y[g]) state <= 1; end
                    end else speed_counter <= speed_counter - 1;
                end else begin 
                    if (press_left || press_right) begin
                        state <= 0; score <= 0; pac_x <= 1; pac_y <= 1;
                        ghost_x[0] <= 11; ghost_y[0] <= 6; ghost_x[1] <= 12; ghost_y[1] <= 6; ghost_x[2] <= 13; ghost_y[2] <= 6;
                        for (i=0; i<312; i=i+1) dots[i] <= 1;
                    end
                end
            end
        end
    end

    wire [4:0] cell_x = draw_x / TILE_SIZE; wire [4:0] cell_y = draw_y / TILE_SIZE;
    wire [4:0] off_x = draw_x % TILE_SIZE; wire [4:0] off_y = draw_y % TILE_SIZE;

    always @(*) begin
        is_wall = check_wall(cell_x, cell_y);
        is_dot = 0;
        if (cell_x < GRID_W && cell_y < GRID_H && dots[cell_y * GRID_W + cell_x] && !is_wall)
            if (off_x > 8 && off_x < 12 && off_y > 8 && off_y < 12) is_dot = 1;
        is_player = 0;
        if (cell_x == pac_x && cell_y == pac_y)
            if (!(off_x < 4 && off_y < 4) && !(off_x > 16 && off_y < 4) && !(off_x < 4 && off_y > 16) && !(off_x > 16 && off_y > 16)) is_player = 1;
    end
endmodule