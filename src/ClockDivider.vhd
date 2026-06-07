library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity clk_divider is
    Port (
          clk_100MHz : in STD_LOGIC;
          reset      : in STD_LOGIC;
          clk_25MHz  : out STD_LOGIC
     );
end clk_divider;

architecture Behavioral of clk_divider is

    signal counter : integer range 0 to 1 := 0;
    signal clk_tmp : STD_LOGIC := '0';

begin
    process(clk_100MHz, reset)
    begin
        if(reset = '1') then
            counter <= 0;
            clk_tmp <= '0';
        elsif rising_edge(clk_100MHz) then
            if counter = 1 then
                counter <= 0;
                clk_tmp <= not clk_tmp;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    clk_25MHz <= clk_tmp;

end Behavioral;
