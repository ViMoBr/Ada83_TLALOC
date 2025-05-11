 <h1 style="text-align:center;">TECHNICAL INTRODUCTION</h1>

The **A83** compiler transforms a source text file written in the **Ada 83** language into a **.FINC** macro-assembly file for **FASMG** (flat assembler). The passage through **FASMG** produces an executable **ELF** file.

The transformation work operates in distinct phases that create and augment an intermediate data structure **DIANA** (Descriptive Intermediate Attributed Notation for Ada, for details, see the specifications in the **doc** folder: [DIANA-RM](../DIANA-Ref-Manual-1986-rev4.pdf)) from which the macro-assembly text and finally the executable **ELF** code are derived.

The **DIANA** structure is stored in blocks in a temporary work file **$$$.TMP** which is accessible to all phases in the **ADA__LIB** directory, but is destroyed at the end of the final phase **WRITE_LIB** (this last phase renders the temporary file unusable, so it is destroyed).

The macro-assembly code is kept in text format in a **.FINC** file in the **ADA__LIB** directory and can be examined.

The **ELF** (Executable and Linkable Format) format is used for the executable form.

The **WRITE_LIB** phase produces a **.DCL** (or **.BDY** or **.SUB** for an Ada body or sub-unit) file that contains a **DIANA** description that is "withable" in the **LIB_PHASE** phase so that a module can use others by mentioning them in a "with" clause. These files are stored in the library directory **ADA__LIB**.
```
               |------------|
               |    A83     |
module.adb --> |------------|
               | PAR_PHASE  |
               | LIB_PHASE  |
$$$.TMP <----> | SEM_PHASE  |
               | ERR_PHASE  |
               | CODE_GEN   | --> MODULE.FINC                 (intermediate code to be passed through the FASMG assembler with a launcher file module.fas)
               | WRITE_LIB  | --> MODULE.DCL / .BDY / .SUB    (library unit, DIANA withable)
               |------------|
```
When calling the compiler, you must provide 3 parameters:
* a path to a "project" directory that contains the library directory **ADA__LIB** where the **.DCL**, **.BDY**, **.SUB** and **.FINC** will be stored.
This access is either relative to the location of the executable **ada_comp** called by **a83.sh**, or absolute.

* access to the source text to be compiled (absolute or relative access to the **ada_comp** executable's directory)

* a letter indicating the phase after which to stop. You may indeed want to do only a syntax analysis (S or s stop letter), quick check for typing errors for example, or stop after the semantic analysis (M or m) in order to examine the **DIANA** structure in the **$$$.TMP** file.

Since there is no parameter passing to an **Ada 83** program, the parameter string must be provided via the shell and standard input.
There is therefore a script file **a83.sh** taking 3 parameters which are relayed by a bash command:
```
 ./ada_comp <<< "$1 $2 $3"
```
The call to the compiler (executable **ada_comp** in bin directory) is then done by something like:
```
 ./a83.sh  ./  ./my_prog.adb  W
```
Where we assume to be in the **bin** directory containing **a83.sh** and which acts as a test project directory, thus containing an **ADA__LIB** directory. So that the project path is **./**, the relative access to the source is here **./my_prog.adb** and the stop letter is "W" (stop after the **WRITE_LIB** phase performing also the macro_code generation phase).

The stop option letter can be:
- S/s we stop after the syntax phase (**PAR_PHASE**) which allows to control the incomplete **DIANA** structure after this phase
- L/l we stop after the library phase (**LIB_PHASE**) the temporary **DIANA** file is completed by the imports due to the "with" and the sub ancestors contexts if  any.
- M/m we stop after the semantic phase (**SEM_PHASE**) the **DIANA** structure has been augmented with semantic nodes
- C the macro-code is generated but the library is not written (allows to test the code generation without touching the library)
- w the library is written but the macro-code generation is bypassed (allows to store the result of semantic compilation without being confronted with a coding bug during the development of the **CODE_GEN** part).
- W the library is written and the macro-code generation is done.

A letter option U (ugly), P (pretty) or A (all) performs a print of the **DIANA** structure present in the working file the
 **$$$.TMP** (present in the library folder **ADA__LIB** of the project).
The file **"$$$.TMP"** is however inaccessible after an option **w** or **W** which destroys this file (it is modified and becomes unusable at the end of this ultimate operation), but any stop before the **WRITE_LIB** phase leaves the **$$$.TMP** accessible.
The print of **$$$.TMP** post **SEM_PHASE** is crucial for the development of **CODE_GEN**.

IMPORTANT NOTE: As it is possible to stop during the compilation process, **DIANA** files that do not contain certain coding information can be put in the library and cause errors if they are used during a coding operation.
To avoid this kind of artificial error, it must be ensured that any file used in a coding operation has also been passed through the coding phase. This normally reduces to using the **W** option. But in the development phase of the code generator, it is useful to be able to stop where you want (at your own risk, normally at this stage you should know what you are doing!).

## 1. COMPILATION PHASES

There are 7 compilation phases whose detailed description follows.

<br></br>

### 1.1 LEXICAL AND SYNTAX ANALYSIS PHASE (_"PAR_PHASE"_)
This phase performs the lexical and syntax analysis of the source text submitted for compilation. It is a classic LALR(1) analyzer whose tables are manufactured by a specific system present in a "src/lalr_tools" directory.

The software structure of the phase is as follows (in the src/par_phase directory, the entry point being the _"PAR_PHASE"_ procedure):

---

<pre>
 <h4 style="text-align:center;">PHASE "PAR_PHASE"</h4>

     [ <a href="../../bin/text_io.ads">text_io</a> ..........\
     [<a href="../../bin/text_io.adb">bdy</a>                |
                         |
     [ <a href="../../bin/sequential_io.ads">sequential_io</a> ..\ |
     [bdy              | |
                       | |
                       | |    [ <a href="../../src/par_phase/lex.ads">lex</a> .......\
                       | \..> [<a href="../../src/par_phase/lex.adb">bdy</a>         |
                       |                   |
                       |      [ <a href="../../src/par_phase/grmr_ops.ads">grmr_ops</a> ..|
                       |      [<a href="../../src/par_phase/grmr_ops.adb">bdy</a>         |
                       |                   |
                       \....> [ <a href="../../src/par_phase/grmr_tbl.ads">grmr_tbl</a> ..|
                                           |    [ <a href="../../src/ada_comp/idl.ads">idl</a>
                                           |    | ( par_phase
                                           |    [<a href="../../src/ada_comp/idl.adb">bdy</a>
                                           \..> | _( <a href="../../src/par_phase/idl-par_phase.adb">par_phase</a>
                                                     | _( <a href="../../src/par_phase/idl-par_phase-set_dflt.adb">set_dflt</a>
</pre>

---
 The files concerned (accessible by the links above) are:
```
   lex.ads           lex.adb
   grmr_ops.ads      grmr_ops.adb
   grmr_tbl.ads
   idl-par_phase.adb
   idl-par_phase-set_dflt.adb

```
---

The entry point of the phase is the _**IDL.PAR_PHASE**_ procedure is a separate sub-unit of the _**IDL**_ module which we will talk about later. Its declaration has this form:
```
    procedure PAR_PHASE ( PATH_TEXTE, NOM_TEXTE, LIB_PATH :STRING );
```

At the end of the execution of _**PAR_PHASE**_ on the source file, a DIANA tree containing only the syntax information is present in the working file **$$$.TMP**. a call of A83 with a letter option of display of the tree of **$$$.TMP** allows to visualize the obtained tree.

<br></br>

### 1.2 LIBRARY PHASE (_"LIB_PHASE"_) ###

The Ada 83 language allows modular compilation: a module can use definitions and services provided and previously compiled by another module which is mentioned in a "with" clause.

Before verifying that the static semantics of the compiled file is correct, the **LIB_PHASE** phase reads the **.DCL** (or **.BDY** or **.SUB**) files and integrates the **DIANA** trees of these "withed" modules. It is indeed necessary to have the definitions used and their semantic characteristics previously obtained to verify the semantics of the module being compiled.

The phase is contained in a single file in the src/ada_comp directory:

<pre>
 <a href="../../src/ada_comp/idl-lib_phase.adb">idl-lib_phase.adb</a>
</pre>

This procedure unit **IDL.LIB_PHASE**  separated from the **LIB** module is the entry point of the phase. It is without parameter (but included and separated from the module **IDL**):
```
    procedure LIB_PHASE;
```
The tree contained in **$$$.TMP** is completed by the relocated blocks of the "withed" units. The stop letter after **LIB_PHASE** is **L**.

<br></br>

### 1.3 SEMANTIC ANALYSIS PHASE (_"SEM_PHASE"_) ###

This phase performs the static semantic verification of the compiled module, it is a very complex phase divided into 29 modules (src/sem_phase directory) and whose entry point is the **IDL.SEM_PHASE** procedure contained in the file <pre>
 <a href="../../src/sem_phase/idl-sem_phase.adb">idl-sem_phase.adb</a>
</pre>

The software structure is an inclusion of sub-units:

---

<pre>
 <h4 style="text-align:center;">PHASE "SEM_PHASE"</h4>
         [ <a href="../../src/ada_comp/idl.ads">idl</a>
         |
         | ( sem_phase
         [<a href="../../src/ada_comp/idl.adb">bdy</a>
         | _( <a href="../../src/sem_phase/idl-sem_phase.adb">sem_phase</a>
              |
              | _[ <a href="../../src/sem_phase/idl-sem_phase-aggreso.adb">aggreso</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-att_walk.adb">att_walk</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-chk_stat.adb">chk_stat</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-def_util.adb">def_util</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-def_walk.adb">def_walk</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-derived.adb">derived</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-eval_num.adb">eval_num</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-expreso.adb">expreso</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-exp_type.adb">exp_type</a>
              | _( <a href="../../src/sem_phase/idl-sem_phase-fix_pre.adb">fix_pre</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-fix_with.adb">fix_with</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-gen_subs.adb">gen_subs</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-hom_unit.adb">hom_unit</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-instant.adb">instant</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-make_nod.adb">make_nod</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-newsnam.adb">newsnam</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-nod_walk.adb">nod_walk</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-pra_walk.adb">pra_walk</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-pre_fcns.adb">pre_fcns</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-red_subp.adb">red_subp</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-rep_clau.adb">rep_clau</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-req_util.adb">req_util</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-sem_glob.adb">sem_glob</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-set_util.adb">set_util</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-stm_walk.adb">stm_walk</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-uarith.adb">uarith</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-univ_ops.adb">univ_ops</a>
              | _[ <a href="../../src/sem_phase/idl-sem_phase-vis_util.adb">vis_util</a>
</pre>

---
   The files concerned are in src/sem_phase:
```
     idl-sem_phase
     idl-sem_phase-aggreso.adb       idl-sem_phase-att_walk.adb
     idl-sem_phase-chk_stat.adb      idl-sem_phase-def_util.adb
     idl-sem_phase-def_walk.adb      idl-sem_phase-derived.adb
     idl-sem_phase-eval_num.adb      idl-sem_phase-expreso.adb
     idl-sem_phase-exp_type.adb      idl-sem_phase-fix_pre.adb
     idl-sem_phase-fix_with.adb      idl-sem_phase-gen_subs.adb
     idl-sem_phase-hom_unit.adb      idl-sem_phase-instant.adb
     idl-sem_phase-make_nod.adb      idl-sem_phase-newsnam.adb
     idl-sem_phase-nod_walk.adb      idl-sem_phase-pra_walk.adb
     idl-sem_phase-pre_fcns.adb      idl-sem_phase-red_subp.adb
     idl-sem_phase-rep_clau.adb      idl-sem_phase-req_util.adb
     idl-sem_phase-sem_glob.adb      idl-sem_phase-set_util.adb
     idl-sem_phase-stm_walk.adb      idl-sem_phase-uarith.adb
     idl-sem_phase-univ_ops.adb      idl-sem_phase-vis_util.adb
```
---

<br></br>

### 1.4 PHASE _"ERR_PHASE"_ ###

The errors found in the previous phases are accumulated in the **DIANA** tree and presented in the **ERR_PHASE**. If there are errors, the following phases are not executed.
The **ERR_PHASE** procedure without parameter is contained in the idl-err_phase.adb file of the src/ada_comp directory.

<pre>
 <a href="../../src/ada_comp/idl-err_phase.adb">idl-err_phase.adb</a>
</pre>

It is separated from the **IDL** module.

<br></br>

### 1.5 MACRO ASSEMBLY CODE GENERATION PHASE (CODE_GEN) ###

From the **DIANA** tree verified both syntactically and semantically, a form of intermediate machine code independent of the target hardware is elaborated.
The first validated Ada 83 compiler targeted a stack machine interpreter. The only source accessible in C language is that of Ada-Ed.
A later project conducted in Poland (see the doc/Thèses_Pologne folder) used an intermediate stack machine code, but with the intention of translating it into 386 machine assembler (A.Wierzinska's thesis). The translator from **DIANA** to "A-Code", an extension of the traditional P-Code of Pascal for Ada, was built by M.Cierniak and can serve as an example.
However, current processors (2024) are register machines and the most modern code optimizers, such as LLVM or simpler substitutes such as QUBE, work on a representation in 3-address operations and an SSA (Single Static Assignment) approach. the question therefore arises as to whether it is not judicious to aim for an intermediate code of this kind, easier to translate into assembler for example for RISC-V which has the advantage of being a modern and "clean" specification compared to Amd/Intel x86 processor very burdened by its history and the constraints of compatibility.

The choice made for now is a median path where a stack machine macro-code is written by the **CODE_GEN** phase for assembly with **FASMG**. The stack machine has no optimized code, but the direct native code produced give some decent level of performance.

<br></br>

### 1.6 FINAL TARGET CODE GENERATION PHASE ###

The macro-code is then translated into target machine code carried in ELF files by direct assembly with the **FASMG** assembly engine. A single chunk binary executable is directly produced without linking step.

<br></br>

### 1.7 LIBRARY MODULE WRITING PHASE (_"WRITE_LIB"_) ###

The last operation of the compiler consists in manufacturing a block of **DIANA** tree which can be integrated into another later compilation which would use in clause "with" the module that one finishes compiling.
Not all **DIANA** blocks of the module being compiled are to be saved because certain parts of the tree in **$$$.TMP** come from "with" clauses and therefore from library files already saved.
However, the sequence of phases is such that the **DIANA** tree blocks to be saved (coming from the syntax analysis then from the semantic analysis) are separated by "withed blocks not to be saved". It is therefore necessary to relocate the nodes to be saved and compact them into a single range of blocks from which the **.DCL**, **.BDY** or **.SUB** file is made.
A marking algorithm for relocation destroys the old tree (some pointers being deliberately denatured during marking). This is not serious insofar as there is no more operation to be done after this last phase, and that the examination of the **DIANA** tree, if it must be done, can be done by stopping before the **WRITE_LIB** phase.
This phase is performed by the procedure present in the file of src/ada_comp:
<pre>
 <a href="../../src/ada_comp/idl-write_lib.adb">idl-write_lib.adb</a>
</pre>


## READY FOR THE DEEP DIVE ?

[GO ON TO DIANA GRAPHS !](./tlaloc-diana-idl.md) 
