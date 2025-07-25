#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../hdr/codegen.h"
#include "../hdr/symtable.h"

// Label counter for branching
static int label_counter = 0;

// Number of local variables (stack size placeholder)
static int localsize = 0;

void emit_header(void) {
    printf(".intel_syntax noprefix\n");
    printf(".text\n");
}

void emit_footer(void) {
    printf("leave\n");
    printf("ret\n");
}

void emit_function_start(const char *name) {
    printf(".globl %s\n", name);
    printf("%s:\n", name);
    printf("enter %d, 0\n", localsize);  // localsize = stack space
}

void emit_function_end(void) {
    // leave + ret already in footer for now
}

void emit_assignment(const char *var, int value) {
    int offset = sym_lookup_offset(var);
    if (offset == -1) {
        fprintf(stderr, "Undefined variable: %s\n", var);
        exit(1);
    }

    // push value (şu anda sabit, aslında expression değeri olmalı)
    printf("push %d\n", value); // veya eax vs.

    // push adres of variable
    printf("lea eax, [ebp-%d]\n", offset);
    printf("push eax\n");

    // pop destination address into ebx
    printf("pop ebx\n");

    // pop value into eax
    printf("pop eax\n");

    // store eax (value) into [ebx] (address)
    printf("mov [ebx], eax\n");
}

void emit_assignment_expr(const char *var) {
    int offset = sym_lookup_offset(var);
    if (offset == -1) {
        fprintf(stderr, "Undefined variable: %s\n", var);
        exit(1);
    }

    // buraya kadar eax = hesaplanmış expr sonucu olmalı

    // adresi al
    printf("lea ebx, [ebp-%d]\n", offset);
    // ata
    printf("mov [ebx], eax\n");
}


void emit_return(int value) {
    printf("mov eax, %d\n", value);
    printf("jmp .Lreturn_%d\n", label_counter++);
}

int emit_add(int lhs, int rhs) {
    printf("// ADD placeholder: %d + %d\n", lhs, rhs);
    return lhs + rhs;
}

int emit_sub(int lhs, int rhs) {
    printf("// SUB placeholder: %d - %d\n", lhs, rhs);
    return lhs - rhs;
}

int emit_mul(int lhs, int rhs) {
    printf("// MUL placeholder: %d * %d\n", lhs, rhs);
    return lhs * rhs;
}

int emit_div(int lhs, int rhs) {
    printf("// DIV placeholder: %d / %d\n", lhs, rhs);
    return lhs / rhs;
}

void emit_if(int condition) {
    printf("// IF placeholder: cond=%d\n", condition);
}

void emit_while(int condition) {
    printf("// WHILE placeholder: cond=%d\n", condition);
}

void emit_push(int value) {
    printf("push %d\n", value);
}

void emit_call(const char *func_name, int arg_count) {
    // çağrılan fonksiyon ismine karşılık gelen global pointer’a ulaşıp çağır
    printf("lea eax, \"%s\"\n", func_name);
    printf("mov eax, [eax]\n");
    printf("call eax\n");

    if (arg_count > 0) {
        printf("add esp, %d\n", arg_count * 4); // stack'ten argümanları kaldır
    }

    // sonucu EAX'ta varsayıyoruz
}