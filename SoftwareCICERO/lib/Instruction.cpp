#include "Instruction.h"

#include <cstdio>

#include "Const.h"

namespace Cicero {

Instruction::Instruction() { instr = 0; }

Instruction::Instruction(unsigned int instruction) { instr = instruction; }

unsigned int Instruction::getType() {
    return instr >> (BITS_INSTR - BITS_INSTR_TYPE);
};
unsigned int Instruction::getData() {
    return instr % (1 << (BITS_INSTR - BITS_INSTR_TYPE));
};
unsigned int Instruction::getChar1() {
    return this->getData() >> 8;
};
unsigned int Instruction::getChar2() {
    return this->getData() & 0xFF;
};

void Instruction::printType(int PC) {
    switch (this->getType()) {
    case 0:
        printf("ACCEPT");
        break;
    case 1:
        printf("SPLIT{%d,%d}", PC + 1, this->getData());
        break;
    case 2:
        printf("MATCH(%c)", this->getData());
        break;
    case 3:
        printf("JMP(%d)", this->getData());
        break;
    case 4:
        printf("END_WITHOUT_ACCEPTING");
        break;
    case 5:
        printf("MATCH_ANY");
        break;
    case 6:
        printf("ACCEPT_PARTIAL");
        break;
    case 7:
        printf("NOT_MATCH(%c)", this->getData());
        break;
    case 8:
        printf("RANGE{%c, %c}", this->getChar1(), this->getChar2());
        break;
    case 9:
        printf("NOT_RANGE{%c, %c}", this->getChar1(), this->getChar2());
        break;
    default:
        printf("UNKNOWN");
        break;
    }
}

void Instruction::print(int pc) {
    printf("%03d: %x \\\\ ", pc, instr);
    switch (this->getType()) {
    case 0:
        printf("ACCEPT\n");
        break;
    case 1:
        printf("SPLIT\t {%d,%d} \n", pc + 1, this->getData());
        break;
    case 2:
        printf("MATCH\t char %c\n", this->getData());
        break;
    case 3:
        printf("JMP to \t %d \n", this->getData());
        break;
    case 4:
        printf("END_WITHOUT_ACCEPTING\n");
        break;
    case 5:
        printf("MATCH_ANY\n");
        break;
    case 6:
        printf("ACCEPT_PARTIAL\n");
        break;
    case 7:
        printf("NOT_MATCH\t char %c\n", this->getData());
        break;
    case 8:
        printf("RANGE\t char %c\t char %c\n", this->getChar1(), this->getChar2());
        break;
    case 9:
        printf("NOT_RANGE\t char %c\t char %c\n", this->getChar1(), this->getChar2());
        break;
    default:
        printf("UNKNOWN %d\t data %d\n", this->getType(), this->getData());
        break;
    }
};

} // namespace Cicero
