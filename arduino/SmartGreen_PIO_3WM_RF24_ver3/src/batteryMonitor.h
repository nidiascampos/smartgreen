#include <Vcc.h>

const float VccMin   = 0.0;             // Minimum expected Vcc level, in Volts.
const float VccMax   = 5.0;             // Maximum expected Vcc level, in Volts.
// NOTE: é necessario ajustar/verificar o valor do VCC para cada arduino
// Measured Vcc by multimeter divided by reported Vcc
// const float VccCorrection = 5.00/5.02;  // Module 01
// const float VccCorrection = 5.15/5.0918;  // Module 02
// const float VccCorrection = 4.40/4.2950;  // Module 03
// const float VccCorrection = 5.12/5.1857;  // Module 04 * primeira placa
const float VccCorrection = 5.01/5.1676;  // Module 04 * segunda placa

Vcc vcc(VccCorrection);
