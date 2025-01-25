#pragma once

namespace Cicero {

// Wrapper around the 32bit instruction for easy retrieval of type, data and
// easy printing.
class Instruction {
  private:
    unsigned int instr;

  public:
    Instruction();

    Instruction(unsigned int instruction);
    unsigned int getType();
    unsigned int getData();
    unsigned int getChar1();
    unsigned int getChar2();

    void printType(int PC);
    void print(int pc);
};

} // namespace Cicero
