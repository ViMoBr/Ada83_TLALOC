 <h1 style="text-align: center;"> Ada-83-compiler-tools</h1>
 <br></br>

## Reconstitute an Ada® ANSI/MIL-STD-1815A-1983 standard compiler

## Project Motivation

At the time of its appearance, the Ada language, now "Ada 83", was a real innovation and constituted a special programming universe, compelling its user to produce well-designed software, while offering the same user a range of software structures and services unmatched under a remarkably natural syntax.
Do the subsequent revisions of the language, resulting first in Ada 95 and then 2005 and 2012, constitute progress? Personally, I don't think so. The introduction of object programming and its ubiquitous pointers, its stamped types, the complication of the possible structure of programs with child packages bring a false impression of richness while simultaneously multiplying the opportunities to make knots in the software system.
Most programs have no benefit to derive from inheritance mechanisms and extensible record structures. The ideas underlying these features come from specific-purpose systems, and it is only artificially that they are applied to all programs; often to the detriment of their comprehensibility.
As for the syntax of the modern revisions of the language, it is clear that many expression formulas have no immediate meaning and require a thorough knowledge of certain situations created by the complexification of later Ada versions. From Ada 95 to Ada 2012, the revisions have allowed many engineers to work, but like many software systems, the developments thicken and ultimately degrade the clarity of the original system and sometimes even the philosophy.

It therefore seems desirable that an Ada language conforming to the original Ada 83 definition remains accessible. How can we maintain a fair environment using the original language? Gnat, the most widely used free compiler, has a -gnat83 option that in principle compiles an original version of the language, but the entire compilation system adapted to the revisions considerably weighs down the implementation, and if it is only a matter of compiling the Ada 83 version, it would be preferable to have only the strict minimum.
Reconstituting a pure Ada 83 compiler written in the same language and freely accessible is in my opinion a useful project. But what source code elements do we have to carry out this project so that everything does not have to be rewritten and reinvented ex nihilo?

 <br></br>

## Accessible source elements

Ada 83 being a language whose implementation is quite complex, there are very few compilation systems available in source code form.

### The Ada NYU project
There is still an interpretable SETL specification produced before 1990 as part of the Ada project conducted at the Courant Institute of New York University. This has been preserved by some enthusiasts, but, in itself, it is of little use today, although I was able to recompile it with Gnu-SETL.

### Ada/Ed-C
The SETL specification was translated into the C language (a translation that was the subject of a collaboration and theses in 1986 between the Ecole Nationale Supérieure de Télécommunications ENST and the NYUADA team). This work resulted in the Ada/Ed system. The C sources are still accessible and re-compilable with some interventions. However, the structure of the C software translated from SETL is a bit difficult to grasp. The compiler produces code interpreted by a virtual machine. The intermediate representation resulting from the syntactic and semantic analyses is particular and differs from the DIANA representation. These C language sources are still a source of inspiration, especially for the virtual machine and the runtime support, a system that can be compared to the Polish A-code.

### The theses of Poland
In 1990, within the ada/IIPS project of the Institute of Computer Science of Gliwice, four theses under the direction of Przemyslaw Szmal were written by M.Ciernak (DIANA translator to A-code, 6000 source lines in Pascal), M.Chlopek (Ada linker, 42 pages of Pascal source), D.Glowaki (runtime, 37 source files in C), A.Wierzinska (A-code translation into Intel 386 assembler, no source). The work of M.Ciernak is particularly interesting because it uses the DIANA intermediate representation to generate the A-code.

### The Ada-DIANA front-end translator from Peregrine Systems
It would have been desirable to produce an Ada 83 compiler in Ada 83. Unfortunately, no such source was made accessible.
The only system that came close to it, to our knowledge, was the Ada 83 to DIANA translator prototype produced by Peregrine Systems around 1988 under the direction of Bill Easton. This system was provided in a software suite composed of the two Walnut Creek CD-ROMs. It is apparently little known although it has interesting qualities.
It is a translator of Ada 83 source into DIANA intermediate representation structured in distinct phases and operating on a system of page/offset pages and pointers that allowed at the time to save on RAM by deporting the data to secondary storage as much as possible. It came with a complete LALR(1) analysis generator system and used an IDL (Interface Definition Language) in three different ways to generate the management structures of the LALR IDL, the DIANA IDL and the IDL itself. The original system appeared complicated because of this triple use.

It is this system that we have taken up here and largely modified to better bring out the structure by taking advantage of the availability of Gnat. Our hope is that this prototype, which has interesting characteristics, can serve as a basis for an Ada 83 compiler comparable to Ada-Ed, but with easier maintenance through the use of Ada 83 for its programming.
It would therefore be largely a matter of taking up the work of M.Ciernak and his Polish colleagues, while drawing inspiration from the work of JP.Rosen and P.Kruchten on Ada/Ed-C to reconstitute a compiler to the ANSI/MIL-STD_1815A-1983 standard.

## More technique now ! Start here

- [Introduction](https://framagit.org/VMo/ada-83-compiler-tools/-/blob/main/doc/markdown/introduction-eng.md?ref_type=heads)
