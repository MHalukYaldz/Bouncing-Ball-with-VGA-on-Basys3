library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ball_engine is
    Generic (
        BALL_R  : integer := 20;   -- Top yaricapi (piksel)
        SCREEN_W: integer := 640;
        SCREEN_H: integer := 480
    );
    Port (
        clk    : in  STD_LOGIC;   -- 25 MHz pixel clk
        reset  : in  STD_LOGIC;
        vsync  : in  STD_LOGIC;   -- Frame sinyali
        ball_x : out integer range 0 to 639;
        ball_y : out integer range 0 to 479
    );
end ball_engine;

architecture Behavioral of ball_engine is

    -- Topun merkez koordinatlari
    signal bx : integer range 0 to 639 := 320;
    signal by : integer range 0 to 479 := 240;

    -- Hiz: +1 veya -1
    signal vx : integer range -1 to 1 := 1;
    signal vy : integer range -1 to 1 := 1;

    -- vsync kenar tespiti
    signal vsync_prev : STD_LOGIC := '0';

begin

    process(clk, reset)
    begin
        if reset = '1' then
            bx <= 320;
            by <= 240;
            vx <= 1;
            vy <= 1;
            vsync_prev <= '0';

        elsif rising_edge(clk) then
            vsync_prev <= vsync;

            if vsync = '1' and vsync_prev = '0' then

                -- Yeni pozisyon
                bx <= bx + vx;
                by <= by + vy;

                -- Yatay duvar carpismasi
                if (bx + vx) >= SCREEN_W - BALL_R then
                    vx <= -1;
                elsif (bx + vx) <= BALL_R then
                    vx <= 1;
                end if;

                -- Dikey duvar carpismasi
                if (by + vy) >= SCREEN_H - BALL_R then
                    vy <= -1;
                elsif (by + vy) <= BALL_R then
                    vy <= 1;
                end if;

            end if;
        end if;
    end process;

    ball_x <= bx;
    ball_y <= by;

end Behavioral;