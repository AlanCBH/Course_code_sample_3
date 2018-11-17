#include "cacheblock.h"

uint32_t Cache::Block::get_address() const {
  // TODO
  auto addr = (_tag<<(this->_cache_config.get_num_index_bits()));
  addr = addr | _index;
  addr = addr << (this->_cache_config.get_num_block_offset_bits());
  return addr;
}
