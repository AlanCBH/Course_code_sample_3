#include "utils.h"

uint32_t extract_tag(uint32_t address, const CacheConfig& cache_config) {
  // TODO
  auto tag = cache_config.get_num_tag_bits();
  auto bitshift = 32-tag;
  address = (address>>bitshift);
  //auto bitstring = (1<<tag)-1;
  return address;
  //return 0;
}

uint32_t extract_index(uint32_t address, const CacheConfig& cache_config) {
  // TODO
  auto zerobits = cache_config.get_num_block_offset_bits();
  auto tag = cache_config.get_num_index_bits();
  auto bitstring = (1<<tag)-1;
  address = (address>>zerobits);
  bitstring = address & bitstring;
  return bitstring;
}

uint32_t extract_block_offset(uint32_t address, const CacheConfig& cache_config) {
  // TODO
  auto tag = cache_config.get_num_block_offset_bits();
  auto bitstring = (1<<tag)-1;
  bitstring = address & bitstring;
  return bitstring;
}
