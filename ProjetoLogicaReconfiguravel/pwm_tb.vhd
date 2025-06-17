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


            CONT : entity work.pwm generic map(n) port map(clr, clk, duty, period, pwm);

                clock : process                 -- configuração do clock
                begin
                        wait for 50 ns;
                        clk <= not clk;
                end process;

                reset : process 
                begin
                        clr <= '0';
                        wait for 120 ns;
                        clk <= '1';
                        wait for 120 ns;
                        clk <= '0';
                        wait for 120 ns;
                end process;        

               -- dut : process
               -- begin

               -- end process;

               -- periodo : process
               -- begin
                        
               -- end process;

               -- pwm_ : process 
               -- begin
                        
               -- end process;

end architecture;    












