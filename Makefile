ifndef HSA_RUNTIME_PATH
	HSA_RUNTIME_PATH=/opt/hsa
endif

ifndef HSA_LLVM_PATH
	HSA_LLVM_PATH=/opt/amd/cloc/bin
endif

TEST_NAME=vector_copy
LFLAGS= -g  -Wl,--unresolved-symbols=ignore-in-shared-libs
INCS = -I $(HSA_RUNTIME_PATH)/include
C_FILES := $(wildcard *.c)
OBJ_FILES := $(addprefix obj/, $(notdir $(C_FILES:.c=.o)))
CFLAGS :=

all: $(TEST_NAME) $(TEST_NAME).brig

$(TEST_NAME): $(OBJ_FILES) $(COMMON_OBJ_FILES)
	$(CC) $(CFLAGS) $(LFLAGS) $(OBJ_FILES) -L$(HSA_RUNTIME_PATH)/lib -lhsa-runtime64 -o $(TEST_NAME)

$(TEST_NAME).hsail	:	$(TEST_NAME).cl
	cloc.sh -hsail $<

$(TEST_NAME).brig :	$(TEST_NAME).hsail
	$(HSA_LLVM_PATH)/hsailasm $< -o $@

obj/%.o: %.c
	$(CC) -c $(CFLAGS) $(INCS) -o $@ $< -std=c99

clean	:	
	rm obj/*o *.brig *.hsail $(TEST_NAME) *.isa

test	:	all
	@LD_LIBRARY_PATH=$(HSA_RUNTIME_PATH)/lib PROGRAM_FINALIZE_OPTIONS_APPEND=-dump-isa ./$(TEST_NAME)

dump	:	all
	@LD_LIBRARY_PATH=$(HSA_RUNTIME_PATH)/lib PROGRAM_FINALIZE_OPTIONS_APPEND=-dump-isa ./$(TEST_NAME) | grep "Execution" > "result.log" 
	

