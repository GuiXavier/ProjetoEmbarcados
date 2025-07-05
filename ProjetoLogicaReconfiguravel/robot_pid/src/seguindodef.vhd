library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Renomeei a entidade para seguir o padrão do projeto anterior
entity seguindodef is
    port (
        -- Entradas principais
        clk            : in  std_logic;
        reset          : in  std_logic;
        
        -- Entrada dos 3 sensores de linha
        sensores_linha : in  std_logic_vector(2 downto 0);

        -- Saídas para a Ponte H (nomes corrigidos para clareza)
        motor_l_in1    : out std_logic;
        motor_l_in2    : out std_logic;
        motor_r_in1    : out std_logic; -- Corrigido de motor_r_in3
        motor_r_in2    : out std_logic  -- Corrigido de motor_r_in4
    );
end entity;

architecture rtl of seguindodef is
    -- === CONSTANTES DE VELOCIDADE (AJUSTE AQUI!) ===
    constant VEL_MAXIMA : unsigned(7 downto 0) := to_unsigned(220, 8);
    constant VEL_CURVA  : unsigned(7 downto 0) := to_unsigned(150, 8);
    constant VEL_PARADO : unsigned(7 downto 0) := to_unsigned(0, 8);

    -- Sinais internos para os geradores de PWM
    signal duty_cycle_l : unsigned(7 downto 0);
    signal duty_cycle_r : unsigned(7 downto 0);
    signal pwm_signal_l : std_logic;
    signal pwm_signal_r : std_logic;

    -- Sinais para controlar a direção
    signal l_frente, l_re, r_frente, r_re : std_logic;

    -- Componente do nosso gerador de PWM
    component pwm_generator is
        port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            duty_cycle : in  unsigned(7 downto 0);
            pwm_out    : out std_logic
        );
    end component;

begin

    -- =================================================================
    -- CORREÇÃO PRINCIPAL AQUI: Instanciando os geradores de PWM
    -- A saída (pwm_out) agora controla os SINAIS INTERNOS, não as portas de saída.
    -- Também corrigi para usar os sinais de reset e duty_cycle corretos.
    -- =================================================================
    pwm_left: pwm_generator
        port map (
            clk        => clk,
            reset      => '0',
            duty_cycle => x"80",
            pwm_out    => pwm_signal_l -- Controla o sinal interno pwm_signal_l
        );

    pwm_right: pwm_generator
        port map (
            clk        => clk,
            reset      => '0',
            duty_cycle => x"80",
            pwm_out    => pwm_signal_r -- Controla o sinal interno pwm_signal_r
        );

    -- Processo que define as intenções de velocidade e direção (lógica principal)
    process(clk, reset)
    begin
        if reset = '1' then
            duty_cycle_l <= (others => '0');
            duty_cycle_r <= (others => '0');
            l_frente <= '0'; l_re <= '0';
            r_frente <= '0'; r_re <= '0';
        elsif rising_edge(clk) then
            -- Lógica para 3 sensores (Esquerda, Centro, Direita)
            case sensores_linha is
                -- Linha no centro -> Frente
                when "010" | "111" => -- A condição "111" (cruzamento) também vai para frente
                    l_frente <= '1'; l_re <= '0';
                    r_frente <= '1'; r_re <= '0';
                    duty_cycle_l <= VEL_MAXIMA;
                    duty_cycle_r <= VEL_MAXIMA;

                -- Linha à esquerda -> Virar para a esquerda
                when "100" | "110" =>
                    l_frente <= '1'; l_re <= '0';
                    r_frente <= '1'; r_re <= '0';
                    duty_cycle_l <= VEL_CURVA;  -- Motor esquerdo lento
                    duty_cycle_r <= VEL_MAXIMA; -- Motor direito rápido

                -- Linha à direita -> Virar para a direita
                when "001" | "011" =>
                    l_frente <= '1'; l_re <= '0';
                    r_frente <= '1'; r_re <= '0';
                    duty_cycle_l <= VEL_MAXIMA; -- Motor esquerdo rápido
                    duty_cycle_r <= VEL_CURVA;  -- Motor direito lento
                
                -- Robô perdido (tudo branco "000") -> Parar
                when others =>
                    l_frente <= '0'; l_re <= '0';
                    r_frente <= '0'; r_re <= '0';
                    duty_cycle_l <= VEL_PARADO;
                    duty_cycle_r <= VEL_PARADO;
            end case;


        end if;

    end process;
    
    -- Lógica final (multiplexador) que aplica o PWM nos pinos de direção corretos.
    -- Agora esta é a ÚNICA parte do código que controla as saídas dos motores.
    -- Corrigido para o padrão IN1=Frente, IN2=Ré.

         motor_l_in1 <= pwm_signal_l when l_frente = '1' else '0';
         motor_l_in2 <= pwm_signal_l when l_re     = '1' else '0';
         motor_r_in1 <= pwm_signal_r when r_frente = '1' else '0';
         motor_r_in2 <= pwm_signal_r when r_re     = '1' else '0';
 


end architecture;