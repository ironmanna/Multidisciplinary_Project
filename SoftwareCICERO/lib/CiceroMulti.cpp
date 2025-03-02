#include "CiceroMulti.h"
#include "Buffers.h"
#include <cmath>
#include <cstring>
#include <iostream>
#include <memory>
#include <queue>
#include <utility>
#include <vector>
#include <tuple>

namespace Cicero {

// Wrapper class that holds and inits all components.
CiceroMulti::CiceroMulti(unsigned short W, bool dbg) {

    if (W == 0)
        W = 1;

    hasProgram = false;
    verbose = dbg;

    engine = std::make_unique<Engine>(program, W + 1, dbg);
}

void CiceroMulti::setProgram(const char *filename) {
    FILE *fp = fopen(filename, "r");
    unsigned int instr;
    int i;

    if (fp != NULL) {

        if (verbose)
            printf("Reading program file: \n\n");

        for (i = 0; i < INSTR_MEM_SIZE && !feof(fp); i++) {

            fscanf(fp, "%x", &instr);
            program[i] = Instruction(instr);
            fscanf(fp, "\n");

            // Pretty print instructions
            if (verbose)
                program[i].print(i);
        }

        if (i == INSTR_MEM_SIZE && !feof(fp)) {
            fprintf(
                stderr,
                "[X] Program memory exceeded. Only the first %x instructions "
                "were read.\n",
                INSTR_MEM_SIZE);
        }

        hasProgram = true;
        fclose(fp);
    } else {
        hasProgram = false;
        fprintf(stderr, "[X] Could not open program file %s for reading.\n",
                filename);
    }
};

bool CiceroMulti::CiceroMulti::isProgramSet() { return hasProgram; }

std::tuple<bool, int> CiceroMulti::match(std::string input) {

    if (!hasProgram) {
        fprintf(stderr,
                "[X] No program is loaded to match the string against.\n");
        return std::make_tuple(false, 0);
    }

    return engine->runMultiChar(std::move(input));
}

} // namespace Cicero
