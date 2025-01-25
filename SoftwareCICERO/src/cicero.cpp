#include "CiceroMulti.h"
#include <cstdio>
#include <tuple>

int main(int argc, char **argv) {

    if (argc != 2) {
        fprintf(stderr, "Usage: %s <path/to/program>", argv[0]);
        return -1;
    }

    Cicero::CiceroMulti CICERO = Cicero::CiceroMulti(1, true);
    CICERO.setProgram(argv[1]);

    bool matchResult = std::get<0>(CICERO.match("MAFSAEDVLKEYDRRRRMEALLLSLYYPNDRKLLDYKEWSPPRVQVECPKAPVEWNNPPSEKGLIVGHFSGIKYKGEKAQASEVDVNKMCCWVSKFKDAMRRYQGIQTCKIPGKVLSDLDAKIKAYNLTVEGVEGFVRYSRVTKQHVAAFLKELRHSKQYENVNLIHYILTDKRVDIQHLEKDLVKDFKALVESAHRMRQGHMINVKYILYQLLKKHGHGPDGPDILTVKTGSKGVLYDDSFRKIYTDLGWKFTPL"));

    if (matchResult)
        printf("regex %d 	, input %d (len: %d)	, match True\n", 0, 0,
               256);
    else
        printf("regex %d 	, input %d (len: %d)	, match False\n", 0, 0,
               256);

    return 0;
}
