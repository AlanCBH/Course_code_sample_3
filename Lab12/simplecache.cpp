#include "simplecache.h"

int SimpleCache::find(int index, int tag, int block_offset) {
  // read handout for implementation details
  auto elem = _cache.find(index);
  if (elem != _cache.end()) {
    auto elemS = elem->second;
          for (int i = 0; i < elemS.size(); i++) {
                  if (elemS[i].valid() && elemS[i].tag() == tag) {
                          return elemS[i].get_byte(block_offset);
                  }
          }
  }

  return 0xdeadbeef;
}

void SimpleCache::insert(int index, int tag, char data[]) {
  // read handout for implementation details
  // keep in mind what happens when you assign in in C++ (hint: Rule of Three)
  auto elem = _cache.find(index);
  if (elem != _cache.end()) {
          auto &elemS = elem->second;
          bool rewrite = true;
          for (int i = 0; i < elemS.size(); i++) {
                  if (!elemS[i].valid()) {
                        elemS[i].replace(tag,data);
                        rewrite = false;
                        return;
                  }
          }
          if (rewrite) {
                  elemS[0].replace(tag,data);
          }
  }

}
