# ADA 83 'TLALOC' COMPILER QUICKSTAR

THIS IS AN EXPERIMENTAL ADA 83 COMPILER WORK IN PROGRESS, PLEASE BE INDULGENT.

THIS IS BEING DEVELOPPED ON LINUX UBUNTU 24.04 WITH GNAT 13.3.0 AND FASM (version g.kd3c) FOR A X86-64 MACHINE.

IF YOU ARE INTERESTED FIRST CLONE THE PROJECT TO HAVE A LOOK AT THIS THING.

# GO

To start quickly, first work in your cloned **bin** directory 
<pre> cd ./bin </pre>

In the bin directory, there is a bash script named **a83.sh**.


The **a83.sh** script launches the executable **ada_comp** (in the same bin directory) with 3 required parameters :

 - the path to a so-called projet directory containing an **ADA__LIB** sub-directory (start with "./" that is the bin directory where you are, it contains the development **ADA__LIB**)
 - the path from the executable to the Ada 83 source text (for example **./dis_bonjour.adb** which is a french hello world)
 - a single option letter in S, L, M, C, c, W, w, U, A, P (the normal choice is W)

So the first command in the **bin** directory is :

<pre> ./a83.sh  ./  ./dis_bonjour.adb  W  </pre>

Then enter the **bin/ADA__LIB** sub-directory

<pre> cd ./ADA__LIB </pre>

 It contains a **DIS_BONJOUR.fas**, a **DIS_BONJOUR.FINC** and the fasmg assembly engine executable.

Enter the command :

<pre>./fasmg ./DIS_BONJOUR.fas</pre>

This creates an ELF executable **DIS_BONJOUR** in the **ADA__LIB** where you are.

Now finally enter the command :

<pre>./DIS_BONJOUR</pre>

The program displays **" Bonjour "**.

Hope it works on your computer...

If it does and/or if you  are curious :


# [GO AHEAD](./doc/markdown/go_ahead-eng.md)

