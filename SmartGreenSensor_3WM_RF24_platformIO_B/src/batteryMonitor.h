#include <Vcc.h>

const float VccMin   = 0.0;             // Minimum expected Vcc level, in Volts.
const float VccMax   = 5.0;             // Maximum expected Vcc level, in Volts.
// FIXME: é necessario ajustar/verificar o valor do VCC para cada arduino
const float VccCorrection = 4.91/5.00;  // Measured Vcc by multimeter divided by reported Vcc

Vcc vcc(VccCorrection);
