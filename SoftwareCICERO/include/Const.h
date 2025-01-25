#pragma once

namespace Cicero {

enum InstrType {
    ACCEPT 			      = 0,
    SPLIT  			      = 1,
    MATCH  			      = 2,
    JMP	   			      = 3,
    END_WITHOUT_ACCEPTING = 4,
    MATCH_ANY 		      = 5,
    ACCEPT_PARTIAL	      = 6,
    NOT_MATCH		      = 7,
    RANGE                 = 8,
    NOT_RANGE             = 9,
};

const int INSTR_MEM_SIZE = 512; // PC is 9bits
const int BITS_INSTR_TYPE = 4;
const int BITS_INSTR = 20;

enum ClockResult { CONTINUE, ACCEPTED, REFUSED };

} // namespace Cicero