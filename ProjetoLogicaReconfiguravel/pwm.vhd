
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- pwm de 4 bits

entity pwm is

        port(

                clr    : in std_logic;
                clk    : in std_logic;
                duty   : in std_logic_vector(3 downto 0);
                period : in std_logic_vector(3 downto 0);
                pwm    : out std_logic
        
        );

end pwm;    

architecture main of pwm is

            signal count : std_logic_vector(3 downto 0);

begin

            


            cnt : process(clk, clr) 
            begin

                    if clr = '1' then 

                        count <= "0000";
                    elsif clk'event and clk = '1' then        
                            if count = period - 1 then
                                count <= "0000";
                            else 
                                count <= count + 1;
                            end if;    

                    end if;    

            end process;        
            

            pwmout : process(count)
            
            begin
                    if count < duty then 
                        pwm <= '1';
                    else 
                        pwm <= '0';
                    end if;        

            end process;



end architecture;    










