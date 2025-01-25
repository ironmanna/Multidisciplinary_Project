#include <assert.h>
#include <iostream>
#include <fstream>
#include <string>
#include <chrono>
#include <stdlib.h>
#include <cmath>
#include <stdint.h>
#include <vector>
#include <tuple>

#include "CiceroMulti.h"
#include <cstdio>

void try_match (const char *input_re, const char * data, const char *output_file_name, int iterations, char *csv_separator);
double i_avg(std::vector<double> &vec);
void i_log(std::vector<double > &vec, std::vector<double> &log_vec);

int main (int argc, char * argv[]){

    if(argc < 4){
        std::cout<<"Wrong parameters utilization: path_to_re, path_to_data, path_to_output, repetitions, csv_separator"<<std::endl;
        return -1;
    }
    
    try_match(argv[1], argv[2], argv[3], atoi(argv[4]), argv[5]);
    return 0;
}

void try_match (const char *input_re, const char *data, const char *output_file_name, int iterations, char *csv_separator){
    std::string n;
    long int  i, match_count, all_re_match;
    std::string chunks_file_name(data);
    chunks_file_name.append("/chunk.txt");
    std::ifstream chunks_file(chunks_file_name);
    std::tuple<bool, int> result = std::make_tuple(false, 0);
    int iterations_ccs = 0;
    std::vector<double> avg_chunk_ccs;
    std::vector<double> avg_re_ccs;
    std::string line;
    std::string chunks_line;
    long int chunks_number;

    //getting number of data chunks
    std::getline(chunks_file, chunks_line);
    chunks_number = atoi(chunks_line.c_str());
    chunks_file.close();
    std::cout << "Chunks number: " << chunks_number << "\n";
    //iterate over regexes
    long int a = 0;
    long int b = 0;

    auto CICERO = Cicero::CiceroMulti(1, false); // Cicero object, Buffers, verbose
    long int re_counter = 0;

    std::string re_str = std::string(input_re) + std::to_string(re_counter);

    bool re_str_exists = true;

    std::ofstream output;
    output.open(output_file_name, std::ios_base::app);

    while (re_str_exists) {
        // Process each numbered file
        std::cout << "Processing file: " << re_str.c_str() << "\n";

        avg_chunk_ccs.clear();
        avg_re_ccs.clear();
        iterations_ccs = 0;


        // Check if the file exists
        std::ifstream re_file_check(re_str);
        if (!re_file_check.good()) {
            std::cerr << "Regex file does not exist: " << re_str << std::endl;
            re_str_exists = false;
        }
        re_file_check.close();
        re_counter++;

        re_str = std::string(input_re) + std::to_string(re_counter);
        

        if (re_str_exists) {
            CICERO.setProgram(re_str.c_str());
        
            result = std::make_tuple(false, 0);

            match_count = 0;
            for(long int j = 0; j < chunks_number; j++){
                std::string chunk_str = std::to_string(j);
                std::string data_path(data);
                data_path.append("/data");
                data_path.append(chunk_str);
                data_path.append(".dat");
                std::ifstream input(data_path,  std::ios::binary);
                std::string content((std::istreambuf_iterator<char>(input)),
                            (std::istreambuf_iterator<char>()));
                input.close();
                
                iterations_ccs = 0;
                for(long int i = 0; i < iterations; i++){
                    result = std::make_tuple(false, 0);
                    result = CICERO.match(content);
                    //std::cout << "result: " << std::get<0>(result) << " " << std::get<1>(result) << "\n";
                    if(std::get<0>(result)){
                        match_count++;
                    }
                    iterations_ccs += std::get<1>(result);             
                }
                avg_chunk_ccs.push_back(iterations_ccs/iterations);
            }

            avg_re_ccs.push_back(i_avg(avg_chunk_ccs));
        }
    }
    output << match_count << csv_separator;        
    output << i_avg(avg_re_ccs) << csv_separator;
    output << exp(i_avg(avg_re_ccs)) << csv_separator << "\n";
}

double i_avg(std::vector<double> &vec){
    unsigned long long sum;
    double avg;
    avg = 0;
    sum = 0;

    for(long int i = 0; i < vec.size(); i++){
	sum += vec[i];
    }
    //std::cout<<"sum "<<sum<<"  "<<vec.size()<<"\n";

    avg = sum / vec.size();
    return avg;
}