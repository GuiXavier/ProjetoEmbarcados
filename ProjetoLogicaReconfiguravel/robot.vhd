library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity robot is 

        generic (

                   n  : integer := 8                    -- quantidade de bits definida
        );
        port (
                
                -- sinais de clock, reset e start

                clk         : in std_logic;
                rst         : in std_logic;
                btn_start   : in std_logic;
                ir_esquerdo : in  std_logic;
                ir_direito  : in  std_logic;
                
                -- ponte H 
                
                motor_d_1n1 : out std_logic;     -- motor direita
                motor_d_1n2 : out std_logic;     -- motor direita
                motor_e_1n1 : out std_logic;     -- motor esquerda
                motor_e_1n2 : out std_logic      -- motor esquerda

        );

end entity;    

architecture rtl of robot is 


                -- Sinais com as condições iniciais em 0 de estado, debounce, counter 

                signal estado        : std_logic := '0';
                signal btn_sync_0    : std_logic := '0';
                signal btn_sync_1    : std_logic := '0';
                signal btn_rise_edge : std_logic := '0';

                signal counter : unsigned (n - 1 downto 0) := (others => '0');
                signal debounce_ok : std_logic := '0';

begin

                -- botão de start

                process(clk)
                begin 
                        if rising_edge(clk) then
                                btn_sync_0 <= btn_start;
                                btn_sync_1 <= btn_sync_0;
                        end if;        
                end process;

                -- detector de borda de subida

                process(clk)

                begin   
                        if rising_edge(clk) then

                                btn_rise_edge <= btn_sync_0 and not btn_sync_1;
                        end if;
      
                end process;    

                -- debounce 

                process (clk, rst)
                begin
                        if rst = '1' then  
                                counter <= (others => '0');
                                debounce_ok <= '0';      
                        elsif rising_edge(clk)  then
                                
                                if btn_sync_0 = '1' then
                                        if counter = x"7FFFFF" then
                                                counter <= counter + 1;
                                        else                 
                                                debounce_ok <= '1';
                                        end if;
                                else 
                                        counter <= (others => '0');
                                        debounce_ok <= '0';
                                end if;
                                
                        end if;
                        
                   
                end process;        


               -- Alternância de estado do robô
                process(clk, rst)
                begin
                        if rst = '1' then
                                 estado <= '0';
                        elsif rising_edge(clk) then
                                if debounce_ok = '1' and btn_rise_edge = '1' then
                                        estado <= not estado;
                                end if;
                        end if;
                end process;

                -- Lógica de controle de motor
    process(clk)
    begin
        if rising_edge(clk) then
            if estado = '1' then
                -- PRETO = '1', BRANCO = '0'
                if ir_esquerdo = '0' and ir_direito = '0' then
                    -- Frente
                    motor_e_1n1 <= '1'; 
                    motor_e_1n2 <= '0';
                    motor_d_1n1 <= '1';
                    motor_d_1n2 <= '0';
                elsif ir_esquerdo = '1' and ir_direito = '0' then
                    -- Corrigir para esquerda
                    motor_e_1n1 <= '0'; 
                    motor_e_1n2 <= '1';
                    motor_d_1n1 <= '1'; 
                    motor_d_1n2 <= '0';
                elsif ir_esquerdo = '0' and ir_direito = '1' then
                    -- Corrigir para direita
                    motor_e_1n1 <= '1'; 
                    motor_e_1n2 <= '0';
                    motor_d_1n1 <= '0'; 
                    motor_d_1n2 <= '1';
                else
                    -- Ambos no preto (ou ruído) ? segue reto
                    motor_e_1n1 <= '1'; 
                    motor_e_1n2 <= '0';
                    motor_d_1n1 <= '1'; 
                    motor_d_1n2 <= '0';
                end if;
            else
                -- Estado parado
                motor_e_1n1 <= '0'; 
                motor_e_1n2 <= '0';
                motor_d_1n1 <= '0'; 
                motor_d_1n2 <= '0';
            end if;
        end if;
    end process;


    -- IMPLEMENTAÇÃO DO PID (PROPORCIONAL - INTEGRADOR - DERIVATIVO)



end architecture;        