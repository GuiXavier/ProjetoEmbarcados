# Robô Seguidor de Linha com STM32F401RE – Conversão do Wltoys 144001

## 📚 Contextualização

Veículos autônomos de pista fixa têm sido amplamente utilizados em competições acadêmicas e projetos didáticos por integrarem sensoriamento, controle embarcado e atuação mecânica. O modelo Wltoys 144001, originalmente radiocontrolado, possui um chassi robusto, motor DC, bateria Li-Po e direção servoassistida, características que o tornam ideal para conversão em um robô seguidor de linha.

## 📌 Definição do Projeto

Este projeto propõe a modificação do Wltoys 144001 para operar como um robô seguidor de linha com cinco canais de detecção IR, comandado por um microcontrolador STM32F401RE.

### Funcionalidades principais:
- Leitura de sensores IR TCRT5000 (5 canais);
- Cálculo do erro de posição da linha;
- Geração de sinais PWM para controle de:
  - Ponte H L298N (motor DC);
  - Servo de direção.

## 🎯 Objetivos

- Desenvolver firmware em C/CMake para o STM32F401RE;
- Realizar a integração eletrônica entre sensores, atuadores e o chassi do veículo;
- Testar e verificar o desempenho do sistema em um trajeto demarcado.

## 🧠 Justificativa

- Aplicar e consolidar conhecimentos em sistemas embarcados em um projeto prático;
- Reaproveitar hardware de radiocontrole de alta qualidade para fins acadêmicos e de pesquisa.

## ✅ Resultados Esperados

- Navegação estável em toda a extensão da pista, sem perda de trajetória;
- Geração de relatório técnico detalhado e vídeo demonstrativo do robô em operação.

## 🔧 Materiais

### Já disponíveis:
- Chassi Wltoys 144001 com motor DC, bateria Li-Po e servo de direção;
- Placa de desenvolvimento STM32F401RE (Nucleo-64);
- Sensor seguidor de linha IR TCRT5000 (5 canais);
- Módulo de ponte H dupla L298N.

### A adquirir:
- Pista de testes com faixa preta para calibração e experimentação.

## 👥 Integrantes

- Paulo Guilherme Lira Xavier  
- Yan Danilo Lima Morejon  
- João Pedro Fagundes da Silva  
- Eduardo Buchner

## 📹 Demonstração

*Link para o vídeo de demonstração será adicionado aqui após a finalização dos testes.*

## 📄 Licença

Este projeto é apenas para fins educacionais. Consulte a instituição para termos de uso e reprodução.

---

