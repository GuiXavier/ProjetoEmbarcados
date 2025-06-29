library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity teste is 
    port (
        sensor  : in  std_logic;
        led_out : out std_logic
    );
end entity;

architecture arch of teste is
    signal led_state : std_logic := '0';
begin

    process(sensor)
    begin
        -- Lógica combinacional dentro do process
        if sensor = '1' then 
            led_state <= '1';
        else 
            led_state <= '0';
        end if;
    end process;

    -- Saída do LED
    led_out <= led_state;

end architecture;
