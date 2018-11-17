#include "cachesimulator.h"

Cache::Block* CacheSimulator::find_block(uint32_t address) const {
  /**
   * TODO
   *
   * 1. Use `_cache->get_blocks_in_set` to get all the blocks that could
   *    possibly have `address` cached.
   * 2. Loop through all these blocks to see if any one of them actually has
   *    `address` cached (i.e. the block is valid and the tags match).
   * 3. If you find the block, increment `_hits` and return a pointer to the
   *    block. Otherwise, return NULL.
   */
   auto Config = this->_cache->get_config();
   auto index  = extract_index(address,Config);
   auto allBlocks = this->_cache->get_blocks_in_set(index);
   for (int i = 0; i < allBlocks.size(); i++) {
        auto tag = extract_tag(address,Config);
        if (extract_tag(allBlocks[i]->get_address(),Config) == tag && allBlocks[i]->is_valid() ) {
                _hits++;
                return allBlocks[i];
        }
   }
  return NULL;
}

Cache::Block* CacheSimulator::bring_block_into_cache(uint32_t address) const {
  /**
   * TODO
   *
   * 1. Use `_cache->get_blocks_in_set` to get all the blocks that could
   *    cache `address`.
   * 2. Loop through all these blocks to find an invalid `block`. If found,
   *    skip to step 4.
   * 3. Loop through all these blocks to find the least recently used `block`.
   *    If the block is dirty, write it back to memory.
   * 4. Update the `block`'s tag. Read data into it from memory. Mark it as
   *    valid. Mark it as clean. Return a pointer to the `block`.
   */
   auto Config = this->_cache->get_config();
   auto index  = extract_index(address,Config);
   auto allBlocks = _cache->get_blocks_in_set(index);
   int least = 0;
   auto tag = extract_tag(address,Config);
   for (int i = 0; i < allBlocks.size(); i++) {
           if (!allBlocks[i]->is_valid()) {
                   allBlocks[i]->set_tag(tag);
                   allBlocks[i]->read_data_from_memory(this->_memory);
                   allBlocks[i]->mark_as_valid();
                   allBlocks[i]->mark_as_clean();
                   return allBlocks[i];
           }
           auto time = allBlocks[i]->get_last_used_time();
           if (time <= allBlocks[least]->get_last_used_time()) {
                   least = i;
           }
   }
   if (allBlocks[least]->is_dirty()) {
         allBlocks[least]->write_data_to_memory(this->_memory);
   }
   allBlocks[least]->set_tag(tag);
   allBlocks[least]->read_data_from_memory(this->_memory);
   allBlocks[least]->mark_as_valid();
   allBlocks[least]->mark_as_clean();
   return allBlocks[least];

  //return NULL;
}

uint32_t CacheSimulator::read_access(uint32_t address) const {
  /**
   * TODO
   *
   * 1. Use `find_block` to find the `block` caching `address`.
   * 2. If not found, use `bring_block_into_cache` cache `address` in `block`.
   * 3. Update the `last_used_time` for the `block`.
   * 4. Use `read_word_at_offset` to return the data at `address`.
   */
  auto Config = this->_cache->get_config();
  auto fblock = this->find_block(address);
  if (fblock == NULL) {
          fblock = this->bring_block_into_cache(address);
  }
  //auto time = fblock->get_last_used_time();
  _use_clock++;
  fblock->set_last_used_time(_use_clock.get_count());
  auto offset = extract_block_offset(address,Config);
  return fblock->read_word_at_offset(offset);
  //return 0;
}

void CacheSimulator::write_access(uint32_t address, uint32_t word) const {
  /**
   * TODO
   *
   * 1. Use `find_block` to find the `block` caching `address`.
   * 2. If not found
   *    a. If the policy is write allocate, use `bring_block_into_cache`.
   *    a. Otherwise, directly write the `word` to `address` in the memory
   *       using `_memory->write_word` and return.
   * 3. Update the `last_used_time` for the `block`.
   * 4. Use `write_word_at_offset` to to write `word` to `address`.
   * 5. a. If the policy is write back, mark `block` as dirty.
   *    b. Otherwise, write `word` to `address` in memory.
   */
   auto fblock = this->find_block(address);
   if (fblock == NULL) {
           if (this->_policy.is_write_allocate()) {
                   fblock = this->bring_block_into_cache(address);
           } else {
                   this->_memory->write_word(address,word);
                   return;
           }
   }
   this->_use_clock++;
   fblock->set_last_used_time(_use_clock.get_count());
   auto Config = this->_cache->get_config();
   auto offset = extract_block_offset(address,Config);
   fblock->write_word_at_offset(word,offset);
   if (this->_policy.is_write_back()) {
           fblock->mark_as_dirty();
   } else {
           this->_memory->write_word(address,word);
   }
   return;
}
