-- arquivo de testbench para testar os sinais 


library ieee;
use ieee.std_logic_1164.all;

entity pwm_tb is 
    constant n : integer := 4;
end entity;

architecture main of pwm_tb is 

    signal clr    :  std_logic := '0';
    signal clk    :  std_logic := '0';
    signal duty   :  std_logic_vector (n - 1 downto 0) := (others => '0');
    signal period :  std_logic_vector (n - 1 downto 0) := (others => '0'); 
    signal pwm    :  std_logic := '0';

begin

    CONT : entity work.pwm(main) 
        generic map(n) 
        port map(clr, clk, duty, period, pwm);

    -- Processo de clock: alterna o clock a cada 50ns
    clock : process
    begin
        wait for 50 ns;
        clk <= not clk;
    end process;

    -- Processo de reset: configura o reset por um tempo
    reset : process 
    begin
        clr <= '0';
        wait for 120 ns;
        clk <= '1';
        wait for 120 ns;
        clk <= '0';
        wait for 120 ns;
    end process;        

    -- Processo de estímulo: define valores para duty e period
    stimulus : process
    begin
        wait for 10 ns;  -- tempo antes de aplicar estímulos
        duty <= x"4";    -- 4 em hexadecimal (0100)
        period <= x"D";  -- D em hexadecimal (1101)
        wait;            -- aguarda indefinidamente após aplicar estímulo
    end process;

    -- estudo para gerar um sinal pwm de 2kHz

end architecture;
