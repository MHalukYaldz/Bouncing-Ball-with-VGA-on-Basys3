library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bouncing_ball_top is
    Port (
        clk    : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        vga_hs : out STD_LOGIC;
        vga_vs : out STD_LOGIC;
        vga_r  : out STD_LOGIC_VECTOR(3 downto 0);
        vga_g  : out STD_LOGIC_VECTOR(3 downto 0);
        vga_b  : out STD_LOGIC_VECTOR(3 downto 0)
    );
end bouncing_ball_top;

architecture Behavioral of bouncing_ball_top is

    component clk_divider
        Port (
            clk_100MHz : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            clk_25MHz  : out STD_LOGIC
        );
    end component;

    component vga_controller
        Port (
            clk_25MHz : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            hsync     : out STD_LOGIC;
            vsync     : out STD_LOGIC;
            hcount    : out integer range 0 to 799;
            vcount    : out integer range 0 to 524;
            video_on  : out STD_LOGIC
        );
    end component;

    component ball_engine
        Generic (
            BALL_R  : integer;
            SCREEN_W: integer;
            SCREEN_H: integer
        );
        Port (
            clk    : in  STD_LOGIC;
            reset  : in  STD_LOGIC;
            vsync  : in  STD_LOGIC;
            ball_x : out integer range 0 to 639;
            ball_y : out integer range 0 to 479
        );
    end component;

    signal clk_25    : STD_LOGIC;
    signal hsync_s   : STD_LOGIC;
    signal vsync_s   : STD_LOGIC;
    signal h_cnt     : integer range 0 to 799;
    signal v_cnt     : integer range 0 to 524;
    signal video_on  : STD_LOGIC;
    signal ball_x_s  : integer range 0 to 639;
    signal ball_y_s  : integer range 0 to 479;

    -- Daire ici kontrol icin
    signal dx        : integer range -800 to 800;
    signal dy        : integer range -525 to 525;
    signal dist_sq   : integer range 0 to 1000000;--915000 e maks deger icin guvenli ust sinir
    signal in_ball   : STD_LOGIC;

    constant BALL_R  : integer := 20;

begin

    U_CLK : clk_divider
        port map (clk_100MHz => clk, reset => reset, clk_25MHz => clk_25);

    U_VGA : vga_controller
        port map (
            clk_25MHz => clk_25, reset => reset,
            hsync => hsync_s, vsync => vsync_s,
            hcount => h_cnt, vcount => v_cnt,
            video_on => video_on
        );

    U_BALL : ball_engine
        generic map (BALL_R => BALL_R, SCREEN_W => 640, SCREEN_H => 480)
        port map (
            clk => clk_25, reset => reset,
            vsync => vsync_s,
            ball_x => ball_x_s, ball_y => ball_y_s
        );

    -- Piksel topun içinde mi? (daire denklemi)
    dx      <= h_cnt - ball_x_s;
    dy      <= v_cnt - ball_y_s;
    dist_sq <= dx * dx + dy * dy;
    in_ball <= '1' when (dist_sq <= BALL_R * BALL_R) else '0';

    -- Renk
    process(video_on, in_ball)
    begin
        if video_on = '0' then
            -- Blanking
            vga_r <= "0000"; vga_g <= "0000"; vga_b <= "0000";
        elsif in_ball = '1' then
            -- Top: kirmizi
            vga_r <= "1111"; vga_g <= "0010"; vga_b <= "0010";
        else
            -- Arka plan: koyu mavi
            vga_r <= "0000"; vga_g <= "0000"; vga_b <= "0100";
        end if;
    end process;

    vga_hs <= hsync_s;
    vga_vs <= vsync_s;

end Behavioral;