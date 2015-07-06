__kernel void vector_copy(__global int *in, __global int *out, __global int *dummy) {
    int id = get_global_id(0);
    int i;
  
    for (i = 0; i < in[0] * 1000; i++)
        out[id] = in[id];
    dummy[id] = 0;
}

