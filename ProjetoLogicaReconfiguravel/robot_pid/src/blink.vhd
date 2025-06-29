library ieee;
use ieee.std_logic_1164.all;

entity blink is
            
        port (

        clk : in std_logic;
        led : out std_logic

);
end entity;

architecture main of blink is 
begin
        process(clk) is

            variable cnt : integer range 0 to 32e6 := 0;
            variable led_state : std_logic := '0';
         begin 

                if rising_edge(clk) then
                        cnt := cnt + 1;
                if cnt >= 32e6 then
                        cnt := 0;
                        led_state := not led_state;
                end if; 
                end if;
            led <= led_state;
        end process;


end architecture;