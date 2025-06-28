

library ieee;
use ieee.std_logic_1164.all;

entity projetologica is

                -- Generic e Porta do Carrinho
                generic(
                                n : integer := 4 -- quantidade que podemos alterar conforme necessitamos 

                );

                port(

                                i : in std_logic_vector (n - 1 to 0);           -- entrada
                                o : out std_logic                           -- saida
                );


end projetologica;    


architecture main of projetologica is

                            signal q : integer := 0;
begin
    
    

end architecture;












