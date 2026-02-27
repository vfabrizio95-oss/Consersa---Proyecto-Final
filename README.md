# CONSERSA

## Índice
1. [Contexto de la empresa](#-contexto-de-la-empresa)
2. [Problema identificado](#️-problema-identificado)
3. [¿Por qué elegir nuestra solución?](#-por-qué-elegir-nuestra-solución)
4. [Tecnologías y Requerimientos No Funcionales](#️-tecnologías-y-requerimientos-no-funcionales)
5. [Justificación de la arquitectura](#️-justificación-de-la-arquitectura)
6. [Requisitos no funcionales](#️-requisito-no-funcionales)
7. [Ramas de desarrollo y flujo de integracion](#-ramas-de-desarrollo-y-flujo-de-integracion)
8. [Preguntas operativas](#-preguntas-operativas)
---

## Contexto de la empresa

**Consersa** es una empresa contratista que ejecuta trabajos de mantenimiento y reparación de redes de agua potable y alcantarillado sanitario, bajo supervisión de Sedalib. Entre sus principales actividades se encuentran la atención de fugas de agua, atoros de desagüe, reparaciones de redes y conexiones nuevas.
El proceso inicia cuando un usuario reporta una incidencia a través del call center de Sedalib. Esta información es registrada en el sistema de Sedalib, donde se genera una orden de servicio que posteriormente es derivada a Consersa. El call center de Consersa  recibe la orden y esta la deriva a un supervisor formado por operarios (6 - 8 personas) según corresponda el tipo de trabajo y la zona geográfica.
Una vez ejecutado el trabajo en campo, el supervisor registra las actividades realizadas en una hoja de campo, incluyendo los materiales utilizados y los metrados de la intervención. Estas hojas son revisadas por un ingeniero que se encarga de revisar el metrado y cálculos, luego se deriva estas hojas a un supervisor de Sedalib para que sean validadas y por último el ingeniero de sistemas se encarga de Valorizar las hojas de campo de acuerdo a las órdenes de servicio que son descargadas en el call center.
La valorización consiste en ingresar los metrados al sistema, los cuales se calculan automáticamente con base en precios unitarios previamente establecidos por contrato. El resultado de este proceso determina el monto facturable del servicio ejecutado, flujo que se repite diariamente para cada orden de servicio atendida.


---

## Problema identificado

El sistema de gestión de órdenes y valorizaciones utilizado por Consersa presenta problemas operativos que afectan directamente la facturación. El sistema  es usado por un grupo de 100 personas, en 2 turnos diferentes, en la mañana (7 a.m. -  3 p.m) y otro grupo en la tarde (3 p.m - 11 p.m), en cada turno se encargan del Call Center de Consersa y se encargan de Valorizar. La duplicidad de órdenes de servicio ocurre cuando el sistema  guarda 2 veces o elimina una orden, por ejemplo; una orden de servicio es generada en un turno, luego valorizada y los trabajadores del otro turno al abrir el sistema podrían eliminar o modificar datos de la orden ya valorizada, generando la problemática.

---

## ¿Por qué elegir nuestra solución?

Por ejemplo, un trabajador intenta guardar esta orden:
| N° O.S | Ord.SED | Fecha | Hora | Ubicación | Usuario | Tipo de trabajo |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 23482 | 512879 | 04/12/2025 | 21:04:44 | JOSE M. ZAPIOLA 1935 - 1939 - LA ESPERANZA | SAUCEDA CHAVEZ NELVA MICAELA | Reparación de alcantarillado |

y una vez ejecutado el trabajo, se manda la hoja de campo.
Luego en el siguiente turno, otro trabajador modifica datos de la orden ya valorizada, lo vuelve a guardar creando un duplicado.

| N° O.S | Ord.SED | Fecha | Hora | Ubicación | Usuario | Tipo de trabajo |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 23482 | 512879 | 04/12/2025 | 21:04:44 | JOSE M. ZAPIOLA 1935 - 1939 - LA ESPERANZA | SAUCEDA CHAVEZ NELVA MICAELA | Reparación de alcantarillado |
| 23482 | 512879 | 04/12/2025 | 21:04:44 | JOSE M. ZAPIOLA 1935 - 1939 - LA ESPERANZA | SAUCEDA CHAVEZ NELVA MICAELA | Hundimiento en la pista |

y lo vuelve a valorizar. Esta actividad cuesta 13,901.96 soles, esta actividad se ha duplicado, entonces les cobra el doble lo cual les causará una pérdida y una posible sanción de parte de Sedalib. En el caso que el otro turno elimine la orden de servicio ya valorizada, eliminaría todo y tendrían una pérdida de 13,901.96 soles. Nuestro sistema solucionaría tanto el problema de la duplicidad para evitar la duplicación de precios y la eliminación de órdenes de los trabajos valorizados.

---

## Requisitos no funcionales

| ID | Atributo de Calidad | Requerimiento No Funcional | Tecnologías |
|----|--------------------|----------------------------|-------------|
| RNF 01 | Rendimiento | El sistema debe permitir hasta 100 sesiones de usuario concurrentes durante los turnos operativos (7:00 a.m - 11:00 p.m), garantizando tiempos de respuesta estables mediante escalabilidad automática. | AWS Cognito + Amazon API Gateway + AWS Lambda |
| RNF 02 | Rendimiento | El sistema debe reflejar los cambios de estado de una orden en un tiempo máximo de 2 segundos mediante procesamiento orientado a eventos. | Amazon EventBridge + Amazon SQS (FIFO) + AWS Lambda |
| RNF 03 | Rendimiento | El sistema debe responder el 95% de las consultas en menos de 2 segundos utilizando almacenamiento de baja latencia. | Amazon API Gateway + AWS Lambda + Amazon DynamoDB |
| RNF 04 | Disponibilidad | El sistema debe estar disponible durante los turnos operativos (7:00 a.m - 11:00 p.m) con una disponibilidad mínima del 99.9% mensual. | Amazon Route 53 + Amazon CloudFront + AWS WAF + Amazon API Gateway + AWS Lambda |
| RNF 05 | Escalabilidad | El sistema debe permitir el acceso continuo a los usuarios autorizados aun cuando se presenten picos de carga de hasta 200 órdenes diarias, sin pérdida de información. | Amazon SQS (FIFO) + AWS Lambda + Amazon EventBridge |
| RNF 06 | Rendimiento | El sistema debe permitir el registro y visualización de una orden en un tiempo máximo de 3 segundos desde su creación. | Amazon API Gateway + AWS Lambda + Amazon DynamoDB |
| RNF 07 | Seguridad | El sistema deberá implementar un control de acceso basado en roles, evitando la anulación o eliminación de órdenes de servicio por parte de usuarios no autorizados. | Amazon Cognito + Amazon API Gateway |
| RNF 08 | Seguridad | El sistema debe validar el acceso de los operarios mediante Amazon Cognito, exigiendo Autenticación Multifactor (MFA) para autorizar el flujo hacia el API Gateway. | Amazon Cognito (MFA) |
| RNF 09 | Seguridad | El sistema deberá evitar la duplicidad de órdenes y valorizaciones, asegurando que una misma operación registrada más de una vez genere un único registro (0% duplicidad). | Amazon EventBridge + Amazon SQS (FIFO) |
| RNF 10 | Seguridad | El sistema debe registrar el 100% de las acciones críticas (POST y DELETE), capturando el usuario, la fecha/hora y el detalle de la operación para fines de auditoría. | Amazon API Gateway + AWS Lambda + Amazon CloudWatch |
| RNF 11 | Seguridad | El sistema debe proteger la capa de presentación contra ataques comunes como inyección SQL, XSS y tráfico malicioso. | AWS WAF + Amazon CloudFront |
| RNF 12 | Seguridad | El sistema debe ejecutar las funciones AWS Lambda dentro de subredes privadas en una Amazon VPC, permitiendo acceso únicamente mediante VPC Endpoints. | Amazon VPC + Subnets privadas + VPC Endpoints + AWS Lambda |
| RNF 13 | Fiabilidad | El sistema debe garantizar copias de seguridad automáticas con retención mínima de 30 días para recuperación ante fallos. | Amazon DynamoDB + Amazon S3 |
| RNF 14 | Fiabilidad | El sistema debe permitir la recuperación operativa de la infraestructura en caso de fallo mediante Infrastructure as Code (IaC), asegurando reprovisionamiento en máximo 2 horas. | Terraform + AWS Lambda + Amazon API Gateway + Amazon DynamoDB + Amazon EventBridge + Amazon SQS |
| RNF 15 | Fiabilidad | El sistema debe garantizar alta disponibilidad y durabilidad de los datos mediante el uso de Amazon DynamoDB como base de datos administrada. | Amazon DynamoDB |
| RNF 16 | Mantenibilidad | El sistema debe permitir auditar el 100% de las órdenes anuladas o eliminadas almacenando el estado anterior y posterior de la orden. | Amazon DynamoDB + AWS Lambda |
| RNF 17 | Mantenibilidad | El sistema debe detectar fallos enviando eventos fallidos a una DLQ y generar alertas automáticas. | Amazon SQS (DLQ) + Amazon SNS |
| RNF 18 | Flexibilidad | El sistema debe permitir la adición de nuevas actividades de servicio sin afectar el núcleo del sistema. | Amazon EventBridge |
| RNF 19 | Flexibilidad | El sistema debe coordinar automáticamente el cambio de estados en tiempo real (≤ 2 segundos) mediante arquitectura orientada a eventos. | AWS Lambda + Amazon EventBridge |
| RNF 20 | Flexibilidad | El sistema debe permitir la modificación de reglas y parámetros de negocio sin afectar el núcleo del procesamiento. | AWS Lambda + Amazon EventBridge |
| RNF 21 | Flexibilidad | El sistema debe soportar hasta 50 actividades por orden mediante arquitectura desacoplada y persistencia flexible de estados. | AWS Lambda + Amazon EventBridge + Amazon SQS (DLQ) + Amazon DynamoDB |
| RNF 22 | Modificabilidad | El sistema debe permitir el despliegue y modificación independiente de los servicios de negocio sin afectar otros componentes. | AWS Lambda + Amazon SQS |
| RNF 23 | Observabilidad | El sistema debe monitorear el 100% de ejecuciones y solicitudes, registrando métricas, logs y trazabilidad distribuida, generando alertas automáticas ante fallos críticos. | Amazon CloudWatch + AWS X-Ray + Amazon SNS + AWS Lambda + Amazon API Gateway |

---

## Ramas de desarrollo y flujo de integración

- Main (producción): Contiene la versión estable lista para despliegue. Solo se integran cambios validados desde develop.
- Develop (integración): Acumula funcionalidades desde ramas feature/*, se prueban y luego se pasa a main.
- Feature (característica): Espacio de trabajo para una funcionalidad específica. Al finalizar, se integra a develop y luego a main.

---

## Preguntas Operativas

- ¿Cuántos usuarios utilizarán el sistema?
El sistema será utilizado por aproximadamente 100 usuarios internos, entre operarios del Call Center de Consersa y  valorizadores. Estos usuarios se encuentran distribuidos en dos turnos operativos: mañana (7:00 a.m. – 3:00 p.m.) y tarde (3:00 p.m. – 11:00 p.m.).
- ¿Cuántos usuarios estarán conectados a la vez?
Dado que el personal se divide en dos turnos, se estima que habrá aproximadamente 50 usuarios conectados simultáneamente por turno. No obstante, el sistema ha sido diseñado para soportar hasta 100 sesiones concurrentes, conforme al RNF 01, considerando posibles escenarios de solapamiento en el cambio de turno o picos de carga.
- ¿Cuáles son los periodos de actividad/carga del servicio?
Los periodos de mayor actividad comprenden el rango de 7:00 a.m. a 11:00 p.m., correspondientes a las 16 horas de operación diaria. En este intervalo se concentra el procesamiento de órdenes de servicio, el registro de hojas de campo provenientes de las cuadrillas y el proceso de valorización. El momento de mayor criticidad ocurre durante el cambio de turno a las 3:00 p.m., donde puede incrementarse la concurrencia.
- ¿Cuánto tiempo debe estar disponible el servicio?
El servicio debe mantenerse disponible de forma crítica durante las 16 horas de operación diaria, con una disponibilidad mínima mensual del 99.9%. Cualquier interrupción, especialmente en el cambio de turno, podría generar duplicidad o eliminación indebida de órdenes ya valorizadas, ocasionando pérdidas económicas estimadas en aproximadamente S/ 13,901.96 por cada orden mal gestionada.
- Backups y frecuencia
El sistema contará con copias de seguridad automáticas y recuperación punto en el tiempo (PITR) configuradas en Amazon DynamoDB, con una retención mínima de 30 días. Adicionalmente, ante fallos en el procesamiento de eventos, las órdenes no se perderán, ya que serán enviadas a colas de errores (DLQ) en Amazon SQS para su posterior análisis y reprocesamiento, garantizando integridad y recuperación ante incidentes.
- ¿Cuánta data se generará por año?
Considerando un máximo aproximado de 200 órdenes diarias, el sistema podría registrar alrededor de 73,000 órdenes al año. Cada orden genera información estructurada, eventos asociados y registros de auditoría, por lo que se proyecta un crecimiento anual moderado y totalmente manejable por la infraestructura planteada.
- Tiempos de respuesta
El sistema debe garantizar tiempos de respuesta óptimos incluso con hasta 100 usuarios concurrentes. Se establece que el 95% de las consultas deben resolverse en menos de 2 segundos, el registro de una orden no debe superar los 3 segundos y los cambios de estado deben reflejarse en un tiempo máximo de 2 segundos. Esto se logra mediante una arquitectura Serverless implementada sobre Amazon Web Services, utilizando AWS Lambda y Amazon API Gateway para el procesamiento y escalabilidad automática de solicitudes, junto con Amazon EventBridge para la gestión eficiente de eventos, asegurando baja latencia y estabilidad aun en escenarios de alta concurrencia.
