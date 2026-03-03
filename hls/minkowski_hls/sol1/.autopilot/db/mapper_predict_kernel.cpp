#include "hls_signal_handler.h"
#include <algorithm>
#include <cassert>
#include <fstream>
#include <iostream>
#include <list>
#include <map>
#include <vector>
#include "ap_fixed.h"
#include "ap_int.h"
#include "hls_directio.h"
#include "hls_stream.h"
using namespace std;

namespace hls::sim
{
  template<size_t n>
  struct Byte {
    unsigned char a[n];

    Byte()
    {
      for (size_t i = 0; i < n; ++i) {
        a[i] = 0;
      }
    }

    template<typename T>
    Byte<n>& operator= (const T &val)
    {
      std::memcpy(a, &val, n);
      return *this;
    }
  };

  struct SimException : public std::exception {
    const std::string msg;
    const size_t line;
    SimException(const std::string &msg, const size_t line)
      : msg(msg), line(line)
    {
    }
  };

  void errExit(const size_t line, const std::string &msg)
  {
    std::string s;
    s += "ERROR";
//  s += '(';
//  s += __FILE__;
//  s += ":";
//  s += std::to_string(line);
//  s += ')';
    s += ": ";
    s += msg;
    s += "\n";
    fputs(s.c_str(), stderr);
    exit(1);
  }
}


namespace hls::sim
{
  struct Buffer {
    char *first;
    Buffer(char *addr) : first(addr)
    {
    }
  };

  struct DBuffer : public Buffer {
    static const size_t total = 1<<10;
    size_t ufree;

    DBuffer(size_t usize) : Buffer(nullptr), ufree(total)
    {
      first = new char[usize*ufree];
    }

    ~DBuffer()
    {
      delete[] first;
    }
  };

  struct CStream {
    char *front;
    char *back;
    size_t num;
    size_t usize;
    std::list<Buffer*> bufs;
    bool dynamic;

    CStream() : front(nullptr), back(nullptr),
                num(0), usize(0), dynamic(true)
    {
    }

    ~CStream()
    {
      for (Buffer *p : bufs) {
        delete p;
      }
    }

    template<typename T>
    T* data()
    {
      return (T*)front;
    }

    template<typename T>
    void transfer(hls::stream<T> *param)
    {
      while (!empty()) {
        param->write(*(T*)nextRead());
      }
    }

    bool empty();
    char* nextRead();
    char* nextWrite();
  };

  bool CStream::empty()
  {
    return num == 0;
  }

  char* CStream::nextRead()
  {
    assert(num > 0);
    char *res = front;
    front += usize;
    if (dynamic) {
      if (++static_cast<DBuffer*>(bufs.front())->ufree == DBuffer::total) {
        if (bufs.size() > 1) {
          bufs.pop_front();
          front = bufs.front()->first;
        } else {
          front = back = bufs.front()->first;
        }
      }
    }
    --num;
    return res;
  }

  char* CStream::nextWrite()
  {
    if (dynamic) {
      if (static_cast<DBuffer*>(bufs.back())->ufree == 0) {
        bufs.push_back(new DBuffer(usize));
        back = bufs.back()->first;
      }
      --static_cast<DBuffer*>(bufs.back())->ufree;
    }
    char *res = back;
    back += usize;
    ++num;
    return res;
  }

  std::list<CStream> streams;
  std::map<char*, CStream*> prebuilt;

  CStream* createStream(size_t usize)
  {
    streams.emplace_front();
    CStream &s = streams.front();
    {
      s.dynamic = true;
      s.bufs.push_back(new DBuffer(usize));
      s.front = s.bufs.back()->first;
      s.back = s.front;
      s.num = 0;
      s.usize = usize;
    }
    return &s;
  }

  template<typename T>
  CStream* createStream(hls::stream<T> *param)
  {
    CStream *s = createStream(sizeof(T));
    {
      s->dynamic = true;
      while (!param->empty()) {
        T data = param->read();
        memcpy(s->nextWrite(), (char*)&data, sizeof(T));
      }
      prebuilt[s->front] = s;
    }
    return s;
  }

  template<typename T>
  CStream* createStream(T *param, size_t usize)
  {
    streams.emplace_front();
    CStream &s = streams.front();
    {
      s.dynamic = false;
      s.bufs.push_back(new Buffer((char*)param));
      s.front = s.back = s.bufs.back()->first;
      s.usize = usize;
      s.num = ~0UL;
    }
    prebuilt[s.front] = &s;
    return &s;
  }

  CStream* findStream(char *buf)
  {
    return prebuilt.at(buf);
  }
}
class AESL_RUNTIME_BC {
  public:
    AESL_RUNTIME_BC(const char* name) {
      file_token.open( name);
      if (!file_token.good()) {
        cout << "Failed to open tv file " << name << endl;
        exit (1);
      }
      file_token >> mName;//[[[runtime]]]
    }
    ~AESL_RUNTIME_BC() {
      file_token.close();
    }
    int read_size () {
      int size = 0;
      file_token >> mName;//[[transaction]]
      file_token >> mName;//transaction number
      file_token >> mName;//pop_size
      size = atoi(mName.c_str());
      file_token >> mName;//[[/transaction]]
      return size;
    }
  public:
    fstream file_token;
    string mName;
};
using hls::sim::Byte;
extern "C" void predict_kernel(volatile void *, volatile void *, volatile void *, volatile void *, Byte<4>*, Byte<4>*, Byte<4>*, Byte<4>*, int, Byte<4>*, Byte<4>*, Byte<4>*, Byte<4>*, volatile void *, volatile void *, volatile void *, volatile void *, Byte<4>*, Byte<4>*, Byte<4>*, Byte<4>*, int, volatile void *, volatile void *, volatile void *, volatile void *, Byte<4>*, Byte<4>*, Byte<4>*, Byte<4>*, volatile void *);
extern "C" void apatb_predict_kernel_hw(volatile void * __xlx_apatb_param_p_x_0, volatile void * __xlx_apatb_param_p_x_1, volatile void * __xlx_apatb_param_p_x_2, volatile void * __xlx_apatb_param_p_x_3, volatile void * __xlx_apatb_param_H_x_0, volatile void * __xlx_apatb_param_H_x_1, volatile void * __xlx_apatb_param_H_x_2, volatile void * __xlx_apatb_param_H_x_3, int __xlx_apatb_param_m_x, volatile void * __xlx_apatb_param_A_0, volatile void * __xlx_apatb_param_A_1, volatile void * __xlx_apatb_param_A_2, volatile void * __xlx_apatb_param_A_3, volatile void * __xlx_apatb_param_p_w_0, volatile void * __xlx_apatb_param_p_w_1, volatile void * __xlx_apatb_param_p_w_2, volatile void * __xlx_apatb_param_p_w_3, volatile void * __xlx_apatb_param_H_w_0, volatile void * __xlx_apatb_param_H_w_1, volatile void * __xlx_apatb_param_H_w_2, volatile void * __xlx_apatb_param_H_w_3, int __xlx_apatb_param_m_w, volatile void * __xlx_apatb_param_p_pred_0, volatile void * __xlx_apatb_param_p_pred_1, volatile void * __xlx_apatb_param_p_pred_2, volatile void * __xlx_apatb_param_p_pred_3, volatile void * __xlx_apatb_param_H_pred_0, volatile void * __xlx_apatb_param_H_pred_1, volatile void * __xlx_apatb_param_H_pred_2, volatile void * __xlx_apatb_param_H_pred_3, volatile void * __xlx_apatb_param_m_pred) {
using hls::sim::createStream;
  // Collect __xlx_H_x_0__tmp_vec
std::vector<Byte<4>> __xlx_H_x_0__tmp_vec;
for (size_t i = 0; i < 32; ++i){
__xlx_H_x_0__tmp_vec.push_back(((Byte<4>*)__xlx_apatb_param_H_x_0)[i]);
}
  int __xlx_size_param_H_x_0 = 32;
  int __xlx_offset_param_H_x_0 = 0;
  int __xlx_offset_byte_param_H_x_0 = 0*4;
  // Collect __xlx_H_x_1__tmp_vec
std::vector<Byte<4>> __xlx_H_x_1__tmp_vec;
for (size_t i = 0; i < 32; ++i){
__xlx_H_x_1__tmp_vec.push_back(((Byte<4>*)__xlx_apatb_param_H_x_1)[i]);
}
  int __xlx_size_param_H_x_1 = 32;
  int __xlx_offset_param_H_x_1 = 0;
  int __xlx_offset_byte_param_H_x_1 = 0*4;
  // Collect __xlx_H_x_2__tmp_vec
std::vector<Byte<4>> __xlx_H_x_2__tmp_vec;
for (size_t i = 0; i < 32; ++i){
__xlx_H_x_2__tmp_vec.push_back(((Byte<4>*)__xlx_apatb_param_H_x_2)[i]);
}
  int __xlx_size_param_H_x_2 = 32;
  int __xlx_offset_param_H_x_2 = 0;
  int __xlx_offset_byte_param_H_x_2 = 0*4;
  // Collect __xlx_H_x_3__tmp_vec
std::vector<Byte<4>> __xlx_H_x_3__tmp_vec;
for (size_t i = 0; i < 32; ++i){
__xlx_H_x_3__tmp_vec.push_back(((Byte<4>*)__xlx_apatb_param_H_x_3)[i]);
}
  int __xlx_size_param_H_x_3 = 32;
  int __xlx_offset_param_H_x_3 = 0;
  int __xlx_offset_byte_param_H_x_3 = 0*4;
  // Collect __xlx_A_0__tmp_vec
std::vector<Byte<4>> __xlx_A_0__tmp_vec;
for (size_t i = 0; i < 4; ++i){
__xlx_A_0__tmp_vec.push_back(((Byte<4>*)__xlx_apatb_param_A_0)[i]);
}
  int __xlx_size_param_A_0 = 4;
  int __xlx_offset_param_A_0 = 0;
  int __xlx_offset_byte_param_A_0 = 0*4;
  // Collect __xlx_A_1__tmp_vec
std::vector<Byte<4>> __xlx_A_1__tmp_vec;
for (size_t i = 0; i < 4; ++i){
__xlx_A_1__tmp_vec.push_back(((Byte<4>*)__xlx_apatb_param_A_1)[i]);
}
  int __xlx_size_param_A_1 = 4;
  int __xlx_offset_param_A_1 = 0;
  int __xlx_offset_byte_param_A_1 = 0*4;
  // Collect __xlx_A_2__tmp_vec
std::vector<Byte<4>> __xlx_A_2__tmp_vec;
for (size_t i = 0; i < 4; ++i){
__xlx_A_2__tmp_vec.push_back(((Byte<4>*)__xlx_apatb_param_A_2)[i]);
}
  int __xlx_size_param_A_2 = 4;
  int __xlx_offset_param_A_2 = 0;
  int __xlx_offset_byte_param_A_2 = 0*4;
  // Collect __xlx_A_3__tmp_vec
std::vector<Byte<4>> __xlx_A_3__tmp_vec;
for (size_t i = 0; i < 4; ++i){
__xlx_A_3__tmp_vec.push_back(((Byte<4>*)__xlx_apatb_param_A_3)[i]);
}
  int __xlx_size_param_A_3 = 4;
  int __xlx_offset_param_A_3 = 0;
  int __xlx_offset_byte_param_A_3 = 0*4;
  // Collect __xlx_H_w_0__tmp_vec
std::vector<Byte<4>> __xlx_H_w_0__tmp_vec;
for (size_t i = 0; i < 32; ++i){
__xlx_H_w_0__tmp_vec.push_back(((Byte<4>*)__xlx_apatb_param_H_w_0)[i]);
}
  int __xlx_size_param_H_w_0 = 32;
  int __xlx_offset_param_H_w_0 = 0;
  int __xlx_offset_byte_param_H_w_0 = 0*4;
  // Collect __xlx_H_w_1__tmp_vec
std::vector<Byte<4>> __xlx_H_w_1__tmp_vec;
for (size_t i = 0; i < 32; ++i){
__xlx_H_w_1__tmp_vec.push_back(((Byte<4>*)__xlx_apatb_param_H_w_1)[i]);
}
  int __xlx_size_param_H_w_1 = 32;
  int __xlx_offset_param_H_w_1 = 0;
  int __xlx_offset_byte_param_H_w_1 = 0*4;
  // Collect __xlx_H_w_2__tmp_vec
std::vector<Byte<4>> __xlx_H_w_2__tmp_vec;
for (size_t i = 0; i < 32; ++i){
__xlx_H_w_2__tmp_vec.push_back(((Byte<4>*)__xlx_apatb_param_H_w_2)[i]);
}
  int __xlx_size_param_H_w_2 = 32;
  int __xlx_offset_param_H_w_2 = 0;
  int __xlx_offset_byte_param_H_w_2 = 0*4;
  // Collect __xlx_H_w_3__tmp_vec
std::vector<Byte<4>> __xlx_H_w_3__tmp_vec;
for (size_t i = 0; i < 32; ++i){
__xlx_H_w_3__tmp_vec.push_back(((Byte<4>*)__xlx_apatb_param_H_w_3)[i]);
}
  int __xlx_size_param_H_w_3 = 32;
  int __xlx_offset_param_H_w_3 = 0;
  int __xlx_offset_byte_param_H_w_3 = 0*4;
  // Collect __xlx_H_pred_0__tmp_vec
std::vector<Byte<4>> __xlx_H_pred_0__tmp_vec;
for (size_t i = 0; i < 32; ++i){
__xlx_H_pred_0__tmp_vec.push_back(((Byte<4>*)__xlx_apatb_param_H_pred_0)[i]);
}
  int __xlx_size_param_H_pred_0 = 32;
  int __xlx_offset_param_H_pred_0 = 0;
  int __xlx_offset_byte_param_H_pred_0 = 0*4;
  // Collect __xlx_H_pred_1__tmp_vec
std::vector<Byte<4>> __xlx_H_pred_1__tmp_vec;
for (size_t i = 0; i < 32; ++i){
__xlx_H_pred_1__tmp_vec.push_back(((Byte<4>*)__xlx_apatb_param_H_pred_1)[i]);
}
  int __xlx_size_param_H_pred_1 = 32;
  int __xlx_offset_param_H_pred_1 = 0;
  int __xlx_offset_byte_param_H_pred_1 = 0*4;
  // Collect __xlx_H_pred_2__tmp_vec
std::vector<Byte<4>> __xlx_H_pred_2__tmp_vec;
for (size_t i = 0; i < 32; ++i){
__xlx_H_pred_2__tmp_vec.push_back(((Byte<4>*)__xlx_apatb_param_H_pred_2)[i]);
}
  int __xlx_size_param_H_pred_2 = 32;
  int __xlx_offset_param_H_pred_2 = 0;
  int __xlx_offset_byte_param_H_pred_2 = 0*4;
  // Collect __xlx_H_pred_3__tmp_vec
std::vector<Byte<4>> __xlx_H_pred_3__tmp_vec;
for (size_t i = 0; i < 32; ++i){
__xlx_H_pred_3__tmp_vec.push_back(((Byte<4>*)__xlx_apatb_param_H_pred_3)[i]);
}
  int __xlx_size_param_H_pred_3 = 32;
  int __xlx_offset_param_H_pred_3 = 0;
  int __xlx_offset_byte_param_H_pred_3 = 0*4;
  // DUT call
  predict_kernel(__xlx_apatb_param_p_x_0, __xlx_apatb_param_p_x_1, __xlx_apatb_param_p_x_2, __xlx_apatb_param_p_x_3, __xlx_H_x_0__tmp_vec.data(), __xlx_H_x_1__tmp_vec.data(), __xlx_H_x_2__tmp_vec.data(), __xlx_H_x_3__tmp_vec.data(), __xlx_apatb_param_m_x, __xlx_A_0__tmp_vec.data(), __xlx_A_1__tmp_vec.data(), __xlx_A_2__tmp_vec.data(), __xlx_A_3__tmp_vec.data(), __xlx_apatb_param_p_w_0, __xlx_apatb_param_p_w_1, __xlx_apatb_param_p_w_2, __xlx_apatb_param_p_w_3, __xlx_H_w_0__tmp_vec.data(), __xlx_H_w_1__tmp_vec.data(), __xlx_H_w_2__tmp_vec.data(), __xlx_H_w_3__tmp_vec.data(), __xlx_apatb_param_m_w, __xlx_apatb_param_p_pred_0, __xlx_apatb_param_p_pred_1, __xlx_apatb_param_p_pred_2, __xlx_apatb_param_p_pred_3, __xlx_H_pred_0__tmp_vec.data(), __xlx_H_pred_1__tmp_vec.data(), __xlx_H_pred_2__tmp_vec.data(), __xlx_H_pred_3__tmp_vec.data(), __xlx_apatb_param_m_pred);
// print __xlx_apatb_param_H_x_0
for (size_t i = 0; i < __xlx_size_param_H_x_0; ++i) {
((Byte<4>*)__xlx_apatb_param_H_x_0)[i] = __xlx_H_x_0__tmp_vec[__xlx_offset_param_H_x_0+i];
}
// print __xlx_apatb_param_H_x_1
for (size_t i = 0; i < __xlx_size_param_H_x_1; ++i) {
((Byte<4>*)__xlx_apatb_param_H_x_1)[i] = __xlx_H_x_1__tmp_vec[__xlx_offset_param_H_x_1+i];
}
// print __xlx_apatb_param_H_x_2
for (size_t i = 0; i < __xlx_size_param_H_x_2; ++i) {
((Byte<4>*)__xlx_apatb_param_H_x_2)[i] = __xlx_H_x_2__tmp_vec[__xlx_offset_param_H_x_2+i];
}
// print __xlx_apatb_param_H_x_3
for (size_t i = 0; i < __xlx_size_param_H_x_3; ++i) {
((Byte<4>*)__xlx_apatb_param_H_x_3)[i] = __xlx_H_x_3__tmp_vec[__xlx_offset_param_H_x_3+i];
}
// print __xlx_apatb_param_A_0
for (size_t i = 0; i < __xlx_size_param_A_0; ++i) {
((Byte<4>*)__xlx_apatb_param_A_0)[i] = __xlx_A_0__tmp_vec[__xlx_offset_param_A_0+i];
}
// print __xlx_apatb_param_A_1
for (size_t i = 0; i < __xlx_size_param_A_1; ++i) {
((Byte<4>*)__xlx_apatb_param_A_1)[i] = __xlx_A_1__tmp_vec[__xlx_offset_param_A_1+i];
}
// print __xlx_apatb_param_A_2
for (size_t i = 0; i < __xlx_size_param_A_2; ++i) {
((Byte<4>*)__xlx_apatb_param_A_2)[i] = __xlx_A_2__tmp_vec[__xlx_offset_param_A_2+i];
}
// print __xlx_apatb_param_A_3
for (size_t i = 0; i < __xlx_size_param_A_3; ++i) {
((Byte<4>*)__xlx_apatb_param_A_3)[i] = __xlx_A_3__tmp_vec[__xlx_offset_param_A_3+i];
}
// print __xlx_apatb_param_H_w_0
for (size_t i = 0; i < __xlx_size_param_H_w_0; ++i) {
((Byte<4>*)__xlx_apatb_param_H_w_0)[i] = __xlx_H_w_0__tmp_vec[__xlx_offset_param_H_w_0+i];
}
// print __xlx_apatb_param_H_w_1
for (size_t i = 0; i < __xlx_size_param_H_w_1; ++i) {
((Byte<4>*)__xlx_apatb_param_H_w_1)[i] = __xlx_H_w_1__tmp_vec[__xlx_offset_param_H_w_1+i];
}
// print __xlx_apatb_param_H_w_2
for (size_t i = 0; i < __xlx_size_param_H_w_2; ++i) {
((Byte<4>*)__xlx_apatb_param_H_w_2)[i] = __xlx_H_w_2__tmp_vec[__xlx_offset_param_H_w_2+i];
}
// print __xlx_apatb_param_H_w_3
for (size_t i = 0; i < __xlx_size_param_H_w_3; ++i) {
((Byte<4>*)__xlx_apatb_param_H_w_3)[i] = __xlx_H_w_3__tmp_vec[__xlx_offset_param_H_w_3+i];
}
// print __xlx_apatb_param_H_pred_0
for (size_t i = 0; i < __xlx_size_param_H_pred_0; ++i) {
((Byte<4>*)__xlx_apatb_param_H_pred_0)[i] = __xlx_H_pred_0__tmp_vec[__xlx_offset_param_H_pred_0+i];
}
// print __xlx_apatb_param_H_pred_1
for (size_t i = 0; i < __xlx_size_param_H_pred_1; ++i) {
((Byte<4>*)__xlx_apatb_param_H_pred_1)[i] = __xlx_H_pred_1__tmp_vec[__xlx_offset_param_H_pred_1+i];
}
// print __xlx_apatb_param_H_pred_2
for (size_t i = 0; i < __xlx_size_param_H_pred_2; ++i) {
((Byte<4>*)__xlx_apatb_param_H_pred_2)[i] = __xlx_H_pred_2__tmp_vec[__xlx_offset_param_H_pred_2+i];
}
// print __xlx_apatb_param_H_pred_3
for (size_t i = 0; i < __xlx_size_param_H_pred_3; ++i) {
((Byte<4>*)__xlx_apatb_param_H_pred_3)[i] = __xlx_H_pred_3__tmp_vec[__xlx_offset_param_H_pred_3+i];
}
}
