

library ieee;
use ieee.std_logic_1164.all;

entity projetologica is

                -- Generic e Porta do Carrinho
                generic(
                                n : natural := 2 -- quantidade que podemos alterar conforme necessitamos 

                );

                port(

                                i : in std_logic_vector (1 to 0);           -- entrada
                                o : out std_logic                           -- saida
                );


end projetologica;    


architecture main of projetologica is

                            signal a : integer := 00;
begin
    
    

end architecture;












