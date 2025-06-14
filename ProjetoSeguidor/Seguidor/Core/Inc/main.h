/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.h
  * @brief          : Header for main.c file.
  *                   This file contains the common defines of the application.
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2025 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "stm32l4xx_hal.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Exported types ------------------------------------------------------------*/
/* USER CODE BEGIN ET */

/* USER CODE END ET */

/* Exported constants --------------------------------------------------------*/
/* USER CODE BEGIN EC */

/* USER CODE END EC */

/* Exported macro ------------------------------------------------------------*/
/* USER CODE BEGIN EM */

/* USER CODE END EM */

void HAL_TIM_MspPostInit(TIM_HandleTypeDef *htim);

/* Exported functions prototypes ---------------------------------------------*/
void Error_Handler(void);

/* USER CODE BEGIN EFP */

/* USER CODE END EFP */

/* Private defines -----------------------------------------------------------*/
#define MCO_Pin GPIO_PIN_0
#define MCO_GPIO_Port GPIOA
#define SENSOR_1_Pin GPIO_PIN_1
#define SENSOR_1_GPIO_Port GPIOA
#define SENSOR_2_Pin GPIO_PIN_2
#define SENSOR_2_GPIO_Port GPIOA
#define SENSOR_3_Pin GPIO_PIN_3
#define SENSOR_3_GPIO_Port GPIOA
#define SENSOR_4_Pin GPIO_PIN_4
#define SENSOR_4_GPIO_Port GPIOA
#define SENSOR_5_Pin GPIO_PIN_5
#define SENSOR_5_GPIO_Port GPIOA
#define SENSOR_6_Pin GPIO_PIN_6
#define SENSOR_6_GPIO_Port GPIOA
#define SENSOR_7_Pin GPIO_PIN_7
#define SENSOR_7_GPIO_Port GPIOA
#define MOTOR_A_ENA_Pin GPIO_PIN_8
#define MOTOR_A_ENA_GPIO_Port GPIOA
#define MOTOR_B_ENB_Pin GPIO_PIN_9
#define MOTOR_B_ENB_GPIO_Port GPIOA
#define MOTOR_A_IN1_Pin GPIO_PIN_11
#define MOTOR_A_IN1_GPIO_Port GPIOA
#define SWDIO_Pin GPIO_PIN_13
#define SWDIO_GPIO_Port GPIOA
#define SWCLK_Pin GPIO_PIN_14
#define SWCLK_GPIO_Port GPIOA
#define VCP_RX_Pin GPIO_PIN_15
#define VCP_RX_GPIO_Port GPIOA
#define LD3_Pin GPIO_PIN_3
#define LD3_GPIO_Port GPIOB
#define MOTOR_B_IN3_Pin GPIO_PIN_4
#define MOTOR_B_IN3_GPIO_Port GPIOB
#define MOTOR_A_IN2_Pin GPIO_PIN_5
#define MOTOR_A_IN2_GPIO_Port GPIOB
#define MOTOR_B_IN4_Pin GPIO_PIN_7
#define MOTOR_B_IN4_GPIO_Port GPIOB

/* USER CODE BEGIN Private defines */

/* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */
