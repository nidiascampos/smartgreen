#include <Vcc.h>

const float VccMin   = 0.0;             // Minimum expected Vcc level, in Volts.
const float VccMax   = 5.0;             // Maximum expected Vcc level, in Volts.
// NOTE: é necessario ajustar/verificar o valor do VCC para cada arduino
// Measured Vcc by multimeter divided by reported Vcc
const float VccCorrection = 5.00/5.02;  // Module 05

Vcc vcc(VccCorrection);
