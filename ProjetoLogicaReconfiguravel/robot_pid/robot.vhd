library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seguidor_linha is
    port (
        -- Configurar as portas no FloorPlanner (ou arquivo de restrições)
        clk         : in  std_logic;
        reset       : in  std_logic;
        btn_start   : in  std_logic;
        ir_esquerdo : in  std_logic; -- Sensor IR principal esquerdo
        ir_direito  : in  std_logic; -- Sensor IR principal direito

        motor_r_in1 : out std_logic; -- Controle Motor Direito (L298N IN3 ou IN4)
        motor_r_in2 : out std_logic; -- Controle Motor Direito (L298N IN3 ou IN4)
        motor_l_in1 : out std_logic; -- Controle Motor Esquerdo (L298N IN1 ou IN2)
        motor_l_in2 : out std_logic; -- Controle Motor Esquerdo (L298N IN1 ou IN2)
        
        -- Sensores de linha adicionais (futuros)
        --ir1_sensor  : in std_logic; -- Sensor de linha adicional 1
        --ir2_sensor  : in std_logic; -- Sensor de linha adicional 2
        --ir3_sensor  : in std_logic; -- Sensor de linha adicional 3
        
        -- LED de teste
        led_out     : out std_logic  -- Saída para LED de teste (ex: LED onboard)
    );
end entity;

architecture rtl of seguidor_linha is
    signal estado        : std_logic := '0'; -- '0' = parado, '1' = em funcionamento
    signal btn_sync_0    : std_logic := '0';
    signal btn_sync_1    : std_logic := '0';
    signal btn_rise_edge : std_logic := '0';

    signal counter       : unsigned(23 downto 0) := (others => '0');
    signal debounce_ok   : std_logic := '0';

begin

    -- Sincronizador de botão
    process(clk)
    begin
        if rising_edge(clk) then
            btn_sync_0 <= btn_start;
            btn_sync_1 <= btn_sync_0;
        end if;
    end process;

    -- Detector de borda de subida (rising edge)
    process(clk)
    begin
        if rising_edge(clk) then
            btn_rise_edge <= btn_sync_0 and not btn_sync_1;
        end if;
    end process;

    -- Debounce: incrementa contador enquanto botão estiver pressionado
    process(clk, reset)
    begin
        if reset = '1' then
            counter     <= (others => '0');
            debounce_ok <= '0';
        elsif rising_edge(clk) then
            if btn_sync_0 = '1' then
                if counter < x"7FFFFF" then      -- x"7FFFFF" = 23 bits (0 a 8388607)
                    counter <= counter + 1;
                else
                    debounce_ok <= '1';
                end if;
            else
                counter     <= (others => '0');
                debounce_ok <= '0';
            end if;
        end if;
    end process;

    -- Alternância de estado do robô
    process(clk, reset)
    begin
        if reset = '1' then
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
                -- Lógica simples de seguir linha com 2 sensores
                if ir_esquerdo = '0' and ir_direito = '0' then
                    -- Ambos na linha (Branco = 0). Vai pra frente.
                    motor_l_in1 <= '1'; motor_l_in2 <= '0'; -- Motor Esquerdo para frente
                    motor_r_in1 <= '1'; motor_r_in2 <= '0'; -- Motor Direito para frente
                elsif ir_esquerdo = '1' and ir_direito = '0' then
                    -- Sensor esquerdo no preto (linha desviou para esquerda). Vira para direita.
                    motor_l_in1 <= '1'; motor_l_in2 <= '0'; -- Motor Esquerdo para frente
                    motor_r_in1 <= '0'; motor_r_in2 <= '1'; -- Motor Direito para trás (ou parado para virar mais rápido)
                elsif ir_esquerdo = '0' and ir_direito = '1' then
                    -- Sensor direito no preto (linha desviou para direita). Vira para esquerda.
                    motor_l_in1 <= '0'; motor_l_in2 <= '1'; -- Motor Esquerdo para trás (ou parado)
                    motor_r_in1 <= '1'; motor_r_in2 <= '0'; -- Motor Direito para frente
                else -- ir_esquerdo = '1' and ir_direito = '1'
                    -- Ambos no preto (linha muito larga ou totalmente fora). Pode parar ou ir reto.
                    -- Aqui estamos fazendo ir reto por simplicidade.
                    motor_l_in1 <= '1'; motor_l_in2 <= '0';
                    motor_r_in1 <= '1'; motor_r_in2 <= '0';
                end if;
                
                -- Exemplo de uso dos sensores adicionais (apenas para demonstração)
                -- Você precisaria de uma lógica mais complexa com 3 ou 5 sensores.
                -- if ir1_sensor = '1' then
                --    -- Algo com sensor 1
                -- end if;

            else
                -- Estado parado: desliga os motores
                motor_l_in1 <= '0'; motor_l_in2 <= '0';
                motor_r_in1 <= '0'; motor_r_in2 <= '0';
            end if;
        
            -- LED de teste liga quando o robô está em funcionamento
            led_out <= estado;
        end if;
    end process;
    
end architecture;