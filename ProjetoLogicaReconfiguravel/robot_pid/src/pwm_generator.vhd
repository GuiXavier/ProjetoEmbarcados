-- Módulo Gerador de PWM de 8 bits
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_generator is
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        duty_cycle : in  unsigned(7 downto 0); -- Entrada de velocidade (0 a 255)
        pwm_out    : out std_logic             -- Saída do sinal PWM
    );
end entity;

architecture rtl of pwm_generator is
    signal counter : unsigned(7 downto 0) := (others => '0');
begin

    process(clk, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
        elsif rising_edge(clk) then
            -- O contador simplesmente incrementa e volta a zero, criando a base de tempo.
            counter <= counter + 1;
        end if;
    end process;

    -- Lógica de comparação: Se o contador for menor que o duty_cycle, a saída é '1'.
    pwm_out <= '1' when counter < duty_cycle else '0';

end architecture;