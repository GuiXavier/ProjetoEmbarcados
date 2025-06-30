library ieee;
use ieee.std_logic_1164.all;

entity seguidor_linha_simples is
    port (
        -- Entradas principais
        clk            : in  std_logic; -- Clock principal (27MHz da placa)
        
        -- Entrada do módulo de 5 sensores de linha
        sensores_linha : in  std_logic_vector(4 downto 0); -- S1 a S5

        -- Saídas para a Ponte H L298N
        motor_r_in1    : out std_logic; -- Controla motor direito via IN3
        motor_r_in2    : out std_logic; -- Controla motor direito via IN4
        motor_l_in1    : out std_logic; -- Controla motor esquerdo via IN1
        motor_l_in2    : out std_logic; -- Controla motor esquerdo via IN2
        
        -- Saída para LED de status (LED onboard da Tang Nano)
        led_status     : out std_logic
    );
end entity;

architecture rtl of seguidor_linha_simples is
begin

    -- Processo Principal: Lógica de controle dos motores
    process(sensores_linha)
    begin
        -- Lógica para seguir a linha preta (Assunção: '1' = Preto, '0' = Branco)
        case sensores_linha is
            -- Perfeitamente na linha -> Frente
            when "00100" => 
                motor_l_in1 <= '1'; motor_l_in2 <= '0';
                motor_r_in1 <= '1'; motor_r_in2 <= '0';

            -- Leve desvio para a direita (robô foi para a esquerda) -> Virar suave à direita
            when "01100" | "01000" => 
                motor_l_in1 <= '1'; motor_l_in2 <= '0'; -- Motor Esquerdo: Frente
                motor_r_in1 <= '0'; motor_r_in2 <= '0'; -- Motor Direito: Parado

            -- Leve desvio para a esquerda (robô foi para a direita) -> Virar suave à esquerda
            when "00110" | "00010" => 
                motor_l_in1 <= '0'; motor_l_in2 <= '0'; -- Motor Esquerdo: Parado
                motor_r_in1 <= '1'; motor_r_in2 <= '0'; -- Motor Direito: Frente

            -- Desvio acentuado para a direita -> Virar rápido à direita
            when "11000" | "10000" => 
                motor_l_in1 <= '1'; motor_l_in2 <= '0'; -- Motor Esquerdo: Frente
                motor_r_in1 <= '0'; motor_r_in2 <= '1'; -- Motor Direito: Ré

            -- Desvio acentuado para a esquerda -> Virar rápido à esquerda
            when "00011" | "00001" => 
                motor_l_in1 <= '0'; motor_l_in2 <= '1'; -- Motor Esquerdo: Ré
                motor_r_in1 <= '1'; motor_r_in2 <= '0'; -- Motor Direito: Frente

            -- Linha perdida (todos brancos "00000") ou cruzamento (todos pretos "11111") -> Parar
            when others =>
                motor_l_in1 <= '0'; motor_l_in2 <= '0'; -- Parado
                motor_r_in1 <= '0'; motor_r_in2 <= '0'; -- Parado
        end case;
    end process;
    
    -- O LED de status fica sempre aceso para indicar que a placa está ligada e o código rodando.
    led_status <= '1';

end architecture;