
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


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
    
            



end architecture;    










