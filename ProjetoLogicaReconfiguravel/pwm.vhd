
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- pwm de 4 bits

entity pwm is

        generic (N : integer := 4);

        port(

                clr    : in std_logic;                              -- clear (reset)  
                clk    : in std_logic;                              -- clock
                duty   : in std_logic_vector(N - 1 downto 0);       -- duty 
                period : in std_logic_vector(N - 1 downto 0);       -- periodo
                pwm    : out std_logic                              -- saida pwm
        
        );

end pwm;    

architecture main of pwm is

            signal count : std_logic_vector(N - 1 downto 0);

begin
            cnt : process(clk, clr)             -- contador 4 bit
            begin
                    -- assincrono 
                    if clr = '1' then                       -- se clear = 1 então                
                        count <= (others => '0');           -- limpa o vetor 
                    elsif clk'event and clk = '1' then      -- detecta a borda de subida    rising_edge(clk)  mas vai precisar de um test_bench
                            if count = period - 1 then
                                count <= (others => '0');
                            else 
                                count <= count + 1;
                            end if;    
                    end if;    
            end process;        
            
            -- output saida 
            pwmout : process(count)
            begin
                    if count < duty then 
                        pwm <= '1';
                    else 
                        pwm <= '0';
                    end if;        

            end process;

end architecture;    