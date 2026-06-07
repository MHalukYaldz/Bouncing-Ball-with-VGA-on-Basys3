library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller is
    Port (
        clk_25MHz : in STD_LOGIC;
        reset     : in STD_LOGIC;
        hcount    : out integer range 0 to 799;
        vcount    : out integer range 0 to 524;
        hsync     : out STD_LOGIC;
        vsync     : out STD_LOGIC;
        video_on  : out STD_LOGIC
        );
end vga_controller;

architecture Behavioral of vga_controller is

    CONSTANT H_VISIBLE      : integer := 640;
    CONSTANT H_FRONT_PORCH  : integer := 16;
    CONSTANT H_SYNC_PULSE   : integer := 96;
    CONSTANT H_BACK_PORCH   : integer := 48;
    CONSTANT H_TOTAL        : integer := 800;

    CONSTANT V_VISIBLE      : integer := 480;
    CONSTANT V_FRONT_PORCH  : integer := 10;
    CONSTANT V_SYNC_PULSE   : integer := 2;
    CONSTANT V_BACK_PORCH   : integer := 33;
    CONSTANT V_TOTAL        : integer := 525;

    signal h_cnt    : integer range 0 to H_TOTAL-1 := 0;--basa gec emri
    signal v_cnt    : integer range 0 to V_TOTAL-1 := 0;

begin
    process(clk_25MHz, reset)
    begin
        if reset = '1' then
            h_cnt <= 0;
            v_cnt <= 0;
        elsif rising_edge(clk_25MHz) then
            if h_cnt = H_TOTAL - 1 then
                h_cnt <= 0;
                if v_cnt = V_TOTAL - 1 then
                    v_cnt <= 0;
                else
                    v_cnt <= v_cnt + 1;
                end if;
            else
                h_cnt <= h_cnt + 1;
            end if;
        end if;
    end process;


    hsync <= '0' when (h_cnt >= H_VISIBLE + H_FRONT_PORCH) and 
                      (h_cnt < H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE)
                else '1';
    
    vsync <= '0' when (v_cnt >= V_VISIBLE + V_FRONT_PORCH) and 
                      (v_cnt < V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE)
                else '1';

    video_on <= '1' when (h_cnt < H_VISIBLE and v_cnt < V_VISIBLE )
                    else '0';


    hcount <= h_cnt;
    vcount <= v_cnt;

end Behavioral;
