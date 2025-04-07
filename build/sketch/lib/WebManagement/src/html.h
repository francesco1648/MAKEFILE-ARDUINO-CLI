#line 1 "/home/francesco/Desktop/ISAAC/PLL_PROVE_cp/PicoLowLevel/lib/WebManagement/src/html.h"
#ifndef html_h
#define html_h

inline const char* serverIndex PROGMEM = "<form method='POST' action='/update' enctype='multipart/form-data'>"
                            "<input type='file' name='update'>"
                            "<input type='submit' value='Update'>"
                          "</form>"
                          "<form method='POST' action='/config' enctype='multipart/form-data'>"
                            "<input type='file' name='config' accept=\".json\">"
                            "<input type='submit' value='Set config'>"
                          "</form>";

#endif 
