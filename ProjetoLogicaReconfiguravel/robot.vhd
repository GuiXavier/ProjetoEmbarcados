library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity robot_pid_seguidor_linha is
    generic (
        -- Largura de bits para o contador do PWM. 8 bits = 256 níveis de velocidade.
        PWM_COUNTER_BITS : integer := 8
    );
    port (
        -- Sinais de clock, reset e start
        clk         : in  std_logic;
        rst         : in  std_logic;
        btn_start   : in  std_logic;

        -- Entradas dos sensores infravermelhos (PRETO = '1', BRANCO = '0')
        ir_esquerdo : in  std_logic;
        ir_direito  : in  std_logic;

        -- Saídas para a Ponte H (controla direção e velocidade via PWM)
        motor_d_1n1 : out std_logic; -- Motor Direito, pino 1
        motor_d_1n2 : out std_logic; -- Motor Direito, pino 2
        motor_e_1n1 : out std_logic; -- Motor Esquerdo, pino 1
        motor_e_1n2 : out std_logic  -- Motor Esquerdo, pino 2
    );
end entity robot_pid_seguidor_linha;

architecture rtl of robot_pid_seguidor_linha is

    --==================================================================
    -- SINAIS PARA DEBOUNCE E ESTADO DO ROBÔ
    --==================================================================
    signal estado        : std_logic := '0'; -- '0' = parado, '1' = andando
    signal btn_sync_0    : std_logic := '0';
    signal btn_sync_1    : std_logic := '0';
    signal btn_rise_edge : std_logic := '0';

    --==================================================================
    -- CONSTANTES E SINAIS PARA O CONTROLE PID
    --==================================================================
    -- ATENÇÃO: Estes ganhos (Kp, Ki, Kd) são os mais importantes!
    -- Eles devem ser "tunados" experimentalmente no robô real.
    -- Comece com Ki e Kd em 0 e aumente Kp até o robô oscilar.
    -- Depois, aumente Kd para diminuir a oscilação.
    -- Por fim, aumente Ki para corrigir pequenos erros persistentes.
    constant KP : integer := 20; -- Ganho Proporcional
    constant KI : integer := 1;  -- Ganho Integral
    constant KD : integer := 15; -- Ganho Derivativo

    -- Velocidade base quando o erro é zero (0 a 255)
    constant VELOCIDADE_BASE : integer := 150;

    -- Sinais internos para o cálculo do PID
    signal erro             : signed(2 downto 0) := (others => '0'); -- Usamos signed para -1, 0, 1
    signal erro_anterior    : signed(2 downto 0) := (others => '0');
    signal P_termo          : signed(15 downto 0) := (others => '0');
    signal I_termo          : signed(15 downto 0) := (others => '0');
    signal D_termo          : signed(15 downto 0) := (others => '0');
    signal ajuste_pid       : signed(15 downto 0) := (others => '0');

    -- Sinais para a velocidade final dos motores
    signal velocidade_direita : integer range 0 to 2**PWM_COUNTER_BITS - 1 := 0;
    signal velocidade_esquerda: integer range 0 to 2**PWM_COUNTER_BITS - 1 := 0;

    --==================================================================
    -- SINAIS PARA O GERADOR DE PWM
    --==================================================================
    signal pwm_counter : unsigned(PWM_COUNTER_BITS - 1 downto 0) := (others => '0');

begin

    --==================================================================
    -- LÓGICA DO BOTÃO DE START/STOP (com debounce por sincronia)
    --==================================================================
    process(clk)
    begin
        if rising_edge(clk) then
            btn_sync_0 <= btn_start;
            btn_sync_1 <= btn_sync_0;
        end if;
    end process;

    btn_rise_edge <= btn_sync_0 and not btn_sync_1;

    process(clk, rst)
    begin
        if rst = '1' then
            estado <= '0';
        elsif rising_edge(clk) then
            if btn_rise_edge = '1' then
                estado <= not estado;
            end if;
        end if;
    end process;


    --==================================================================
    -- PROCESSO PRINCIPAL: CÁLCULO DO PID
    --==================================================================
    process(clk, rst)
    begin
        if rst = '1' then
            erro              <= (others => '0');
            erro_anterior     <= (others => '0');
            P_termo           <= (others => '0');
            I_termo           <= (others => '0');
            D_termo           <= (others => '0');
            ajuste_pid        <= (others => '0');
            
        elsif rising_edge(clk) then
            if estado = '1' then
                -- 1. DETERMINAR O ERRO A PARTIR DOS SENSORES
                --    PRETO='1', BRANCO='0'
                if ir_esquerdo = '0' and ir_direito = '0' then
                    erro <= to_signed(0, erro'length); -- Na linha, erro = 0
                elsif ir_esquerdo = '0' and ir_direito = '1' then
                    erro <= to_signed(1, erro'length); -- Desvio para a esquerda, erro positivo (vira p/ direita)
                elsif ir_esquerdo = '1' and ir_direito = '0' then
                    erro <= to_signed(-1, erro'length); -- Desvio para a direita, erro negativo (vira p/ esquerda)
                else -- Ambos no preto (1,1) ou ruído
                    erro <= to_signed(0, erro'length); -- Segue reto
                end if;

                -- 2. CALCULAR OS TERMOS DO PID
                P_termo <= to_signed(KP, P_termo'length) * erro;
                I_termo <= I_termo + (to_signed(KI, I_termo'length) * erro);
                D_termo <= to_signed(KD, D_termo'length) * (erro - erro_anterior);

                -- Anti-Windup para o termo Integral (evita que ele cresça indefinidamente)
                -- Limita o I_termo a um valor razoável
                if I_termo > 2000 then
                    I_termo <= to_signed(2000, I_termo'length);
                elsif I_termo < -2000 then
                    I_termo <= to_signed(-2000, I_termo'length);
                end if;

                -- 3. CALCULAR O AJUSTE FINAL DO PID
                ajuste_pid <= P_termo + I_termo + D_termo;

                -- 4. ATUALIZAR O ERRO ANTERIOR PARA O PRÓXIMO CICLO
                erro_anterior <= erro;

            else -- Se o robô estiver parado
                erro              <= (others => '0');
                erro_anterior     <= (others => '0');
                P_termo           <= (others => '0');
                I_termo           <= (others => '0');
                D_termo           <= (others => '0');
                ajuste_pid        <= (others => '0');
            end if;
        end if;
    end process;


    --==================================================================
    -- CÁLCULO DA VELOCIDADE DOS MOTORES E GERAÇÃO DE PWM
    --==================================================================
    process(clk, rst)
        variable vel_d_temp : signed(15 downto 0);
        variable vel_e_temp : signed(15 downto 0);
        constant MAX_PWM : integer := 2**PWM_COUNTER_BITS - 1;
    begin
        if rst = '1' then
            velocidade_direita  <= 0;
            velocidade_esquerda <= 0;
            pwm_counter         <= (others => '0');

        elsif rising_edge(clk) then
            -- O contador de PWM cicla de 0 a 255 (para 8 bits)
            pwm_counter <= pwm_counter + 1;

            if estado = '1' then
                -- 5. CALCULAR A VELOCIDADE DE CADA MOTOR
                --    O ajuste é subtraído da direita e somado na esquerda.
                vel_d_temp := to_signed(VELOCIDADE_BASE, 16) - ajuste_pid;
                vel_e_temp := to_signed(VELOCIDADE_BASE, 16) + ajuste_pid;

                -- 6. SATURAÇÃO (CLAMPING)
                --    Garante que a velocidade não seja negativa nem maior que o máximo.
                -- Motor Direito
                if vel_d_temp < 0 then
                    velocidade_direita <= 0;
                elsif vel_d_temp > MAX_PWM then
                    velocidade_direita <= MAX_PWM;
                else
                    velocidade_direita <= to_integer(vel_d_temp);
                end if;

                -- Motor Esquerdo
                if vel_e_temp < 0 then
                    velocidade_esquerda <= 0;
                elsif vel_e_temp > MAX_PWM then
                    velocidade_esquerda <= MAX_PWM;
                else
                    velocidade_esquerda <= to_integer(vel_e_temp);
                end if;

                -- 7. GERAR O SINAL PWM PARA OS MOTORES
                --    Para andar para frente, um pino da Ponte H recebe o PWM e o outro fica em '0'.
                
                -- Motor Esquerdo
                if pwm_counter < to_unsigned(velocidade_esquerda, pwm_counter'length) then
                    motor_e_1n1 <= '1';
                else
                    motor_e_1n1 <= '0';
                end if;
                motor_e_1n2 <= '0'; -- Direção: Frente

                -- Motor Direito
                if pwm_counter < to_unsigned(velocidade_direita, pwm_counter'length) then
                    motor_d_1n1 <= '1';
                else
                    motor_d_1n1 <= '0';
                end if;
                motor_d_1n2 <= '0'; -- Direção: Frente

            else
                -- Se o robô estiver parado, desliga todos os motores.
                motor_e_1n1 <= '0';
                motor_e_1n2 <= '0';
                motor_d_1n1 <= '0';
                motor_d_1n2 <= '0';
                velocidade_direita <= 0;
                velocidade_esquerda <= 0;
            end if;
        end if;
    end process;

end architecture rtl;